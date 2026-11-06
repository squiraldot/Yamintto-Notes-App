import 'dart:convert';

import 'package:markdown/markdown.dart' as md;

/// Bounded parser for the Yamintto hybrid Markdown dialect.
///
/// It returns AST nodes only. It never creates HTML or executes user content.
class HybridMarkdownParser {
  const HybridMarkdownParser();

  static const int maxSourceBytes = 256 * 1024;
  static const int maxAstNodes = 10000;
  static const int maxNestingDepth = 32;
  static const int maxDetailsDepth = 16;
  static const int maxTableColumns = 20;
  static const int maxTableRows = 100;
  static const int maxUrlLength = 2048;

  MarkdownParseResult parse(String source) {
    _validateSource(source);
    final extensions = md.ExtensionSet(
      <md.BlockSyntax>[
        _LegacyDetailsSyntax(),
        ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      ],
      <md.InlineSyntax>[
        _LegacyInlineSyntax(),
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes.where(
          (syntax) => syntax is! md.InlineHtmlSyntax,
        ),
      ],
    );
    final document = md.Document(extensionSet: extensions);
    final nodes = document.parse(source);
    _validateAst(nodes);
    return MarkdownParseResult(source: source, nodes: nodes);
  }

  static bool isAllowedUrl(String source) {
    if (source.isEmpty || source.length > maxUrlLength) return false;
    if (source.contains(RegExp(r'[\u0000-\u0020\u007f]'))) return false;
    final uri = Uri.tryParse(source);
    if (uri == null || !uri.hasScheme || uri.userInfo.isNotEmpty) return false;
    switch (uri.scheme.toLowerCase()) {
      case 'http':
      case 'https':
        return uri.host.isNotEmpty;
      case 'mailto':
        return uri.path.isNotEmpty && !uri.path.contains('..');
      default:
        return false;
    }
  }

  void _validateSource(String source) {
    if (utf8.encode(source).length > maxSourceBytes) {
      throw const MarkdownParseException('The document exceeds the preview size limit.');
    }
    if (source.split('\n').length > maxAstNodes) {
      throw const MarkdownParseException('The document contains too many lines to preview safely.');
    }

    var detailsDepth = 0;
    var maximumDetailsDepth = 0;
    for (final line in source.split('\n')) {
      final indent = line.length - line.trimLeft().length;
      if (indent > maxNestingDepth * 4) {
        throw const MarkdownParseException('The document nesting is too deep to preview safely.');
      }
      final trimmed = line.trim().toLowerCase();
      if (trimmed == '<details>') {
        detailsDepth++;
        if (detailsDepth > maximumDetailsDepth) {
          maximumDetailsDepth = detailsDepth;
        }
      } else if (trimmed == '</details>') {
        detailsDepth = (detailsDepth - 1).clamp(0, maxDetailsDepth);
      }
    }
    if (maximumDetailsDepth > maxDetailsDepth) {
      throw const MarkdownParseException('The document has too many nested details blocks.');
    }
  }

  void _validateAst(List<md.Node> roots) {
    final stack = <({md.Node node, int depth})>[
      for (final node in roots) (node: node, depth: 1),
    ];
    var count = 0;
    while (stack.isNotEmpty) {
      final entry = stack.removeLast();
      count++;
      if (count > maxAstNodes || entry.depth > maxNestingDepth) {
        throw const MarkdownParseException('The parsed document exceeds safe structural limits.');
      }
      final node = entry.node;
      if (node is! md.Element) continue;
      if (node.tag == 'table') {
        final rows = <md.Element>[];
        _collectRows(node, rows);
        if (rows.length > maxTableRows) {
          throw const MarkdownParseException('The table has too many rows to preview safely.');
        }
        final columns = rows.isEmpty
            ? 0
            : (rows.first.children ?? const <md.Node>[])
                  .whereType<md.Element>()
                  .where((cell) => cell.tag == 'th' || cell.tag == 'td')
                  .length;
        if (columns > maxTableColumns) {
          throw const MarkdownParseException('The table has too many columns to preview safely.');
        }
      }
      for (final child in node.children ?? const <md.Node>[]) {
        stack.add((node: child, depth: entry.depth + 1));
      }
    }
  }

  void _collectRows(md.Element element, List<md.Element> rows) {
    for (final child in element.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'tr') {
        rows.add(child);
      } else if (child is md.Element) {
        _collectRows(child, rows);
      }
    }
  }
}

class MarkdownParseResult {
  const MarkdownParseResult({required this.source, required this.nodes});

  /// Exact original source; never normalized or serialized from the AST.
  final String source;
  final List<md.Node> nodes;
}

class MarkdownParseException implements Exception {
  const MarkdownParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _LegacyInlineSyntax extends md.InlineSyntax {
  _LegacyInlineSyntax()
    : super(
        r'<kbd>.*?</kbd>|<ins>.*?</ins>|<del>.*?</del>|<br\s*/?>|<span\s+style="color:\s*red"\s*>.*?</span>',
        startCharacter: 60,
        caseSensitive: false,
      );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final value = match[0]!;
    final lower = value.toLowerCase();
    if (lower.startsWith('<br')) {
      parser.addNode(md.Element.empty('br'));
      return true;
    }
    final close = lower.startsWith('<kbd>')
        ? '</kbd>'
        : lower.startsWith('<ins>')
        ? '</ins>'
        : lower.startsWith('<del>')
        ? '</del>'
        : '</span>';
    final tag = close.substring(2, close.length - 1);
    final start = value.indexOf('>') + 1;
    final end = lower.lastIndexOf(close);
    final inner = start >= 1 && end >= start ? value.substring(start, end) : '';
    final children = parser.document.parseInline(inner);
    if (tag == 'span') {
      parser.addNode(
        md.Element('span', children, const {'data-semantic-color': 'danger'}),
      );
    } else {
      parser.addNode(md.Element(tag, children));
    }
    return true;
  }
}

class _LegacyDetailsSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\s*<details>\s*$', caseSensitive: false);

  @override
  md.Node parse(md.BlockParser parser) {
    final rawLines = <String>[];
    parser.advance();
    var depth = 1;
    var closed = false;
    while (!parser.isDone) {
      final line = parser.current.content;
      final normalized = line.trim().toLowerCase();
      if (normalized == '<details>') {
        depth++;
      } else if (normalized == '</details>') {
        depth--;
        if (depth == 0) {
          parser.advance();
          closed = true;
          break;
        }
      }
      rawLines.add(line);
      parser.advance();
    }
    if (!closed || rawLines.isEmpty) {
      return md.Text('<details>\n${rawLines.join('\n')}${closed ? '\n</details>' : ''}');
    }

    final summaryPattern = RegExp(
      r'^\s*<summary>(.*?)</summary>\s*$',
      caseSensitive: false,
    );
    final summaryMatch = summaryPattern.firstMatch(rawLines.first);
    if (summaryMatch == null) {
      return md.Text('<details>\n${rawLines.join('\n')}\n</details>');
    }
    final summary = parser.document.parseInline(summaryMatch[1] ?? '');
    final body = parser.document.parseLines(rawLines.skip(1).toList());
    return md.Element('details', <md.Node>[
      md.Element('summary', summary),
      md.Element('div', body),
    ]);
  }
}
