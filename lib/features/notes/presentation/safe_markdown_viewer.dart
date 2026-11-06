import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:yamintto/features/notes/domain/hybrid_markdown_parser.dart';

/// Native Flutter renderer for the allowlisted hybrid Markdown AST.
class SafeMarkdownViewer extends StatelessWidget {
  const SafeMarkdownViewer({
    required this.source,
    this.fontSize = 15,
    super.key,
  });

  final String source;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final MarkdownParseResult parsed;
    try {
      parsed = const HybridMarkdownParser().parse(source);
    } on MarkdownParseException catch (error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview unavailable: ${error.message}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(source),
        ],
      );
    } catch (_) {
      return const Text('Preview unavailable. The original source is preserved.');
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: parsed.nodes.map((node) => _block(context, node, 0)).toList(),
      ),
    );
  }

  Widget _block(BuildContext context, md.Node node, int depth) {
    if (depth > HybridMarkdownParser.maxNestingDepth) {
      return SelectableText(node.textContent);
    }
    if (node is md.Text) {
      return SelectableText(node.text);
    }
    if (node is! md.Element) return const SizedBox.shrink();
    final children = node.children ?? const <md.Node>[];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize);

    switch (node.tag) {
      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(children: children.map((child) => _inline(context, child, textStyle)).toList()),
            style: textStyle,
          ),
        );
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final level = int.parse(node.tag.substring(1));
        final styles = [
          theme.textTheme.headlineMedium,
          theme.textTheme.headlineSmall,
          theme.textTheme.titleLarge,
          theme.textTheme.titleMedium,
          theme.textTheme.titleSmall,
          theme.textTheme.bodyLarge,
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text.rich(
            TextSpan(children: children.map((child) => _inline(context, child, textStyle)).toList()),
            style: styles[level - 1]?.copyWith(fontSize: fontSize + (7 - level) * 1.5),
          ),
        );
      case 'pre':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor),
          ),
          child: SelectableText(
            node.textContent,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: fontSize - 1,
            ),
          ),
        );
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children.map((child) => _block(context, child, depth + 1)).toList(),
          ),
        );
      case 'ul':
      case 'ol':
        return _list(context, node, depth);
      case 'li':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((child) => _block(context, child, depth + 1)).toList(),
        );
      case 'hr':
        return const Divider(height: 20);
      case 'table':
        return _table(context, node, depth);
      case 'details':
        final summary = children.whereType<md.Element>().where((e) => e.tag == 'summary').firstOrNull;
        final body = children.whereType<md.Element>().where((e) => e.tag == 'div').firstOrNull;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(summary?.textContent ?? 'Details'),
            children: body == null
                ? const []
                : (body.children ?? const <md.Node>[])
                    .map((child) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _block(context, child, depth + 1),
                        ))
                    .toList(),
          ),
        );
      case 'div':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children.map((child) => _block(context, child, depth + 1)).toList(),
        );
      default:
        // Unknown elements never become widgets with user-controlled behavior.
        return SelectableText(node.textContent, style: textStyle);
    }
  }

  Widget _list(BuildContext context, md.Element list, int depth) {
    final ordered = list.tag == 'ol';
    final items = (list.children ?? const <md.Node>[]).whereType<md.Element>().where((e) => e.tag == 'li').toList();
    final start = int.tryParse(list.attributes['start'] ?? '1') ?? 1;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++)
            _listItem(context, items[index], ordered ? '${start + index}.' : '•', depth),
        ],
      ),
    );
  }

  Widget _listItem(BuildContext context, md.Element item, String marker, int depth) {
    final children = item.children ?? const <md.Node>[];
    final checkbox = children.whereType<md.Element>().where((e) => e.tag == 'input').firstOrNull;
    final content = children.where((child) => !(child is md.Element && child.tag == 'input')).toList();
    final checked = checkbox?.attributes.containsKey('checked') ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (checkbox != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Checkbox(
                value: checked,
                onChanged: null,
                visualDensity: VisualDensity.compact,
                semanticLabel: checked ? 'Completed task' : 'Incomplete task',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Text(marker),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content.map((child) => _block(context, child, depth + 1)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(BuildContext context, md.Element table, int depth) {
    final rows = <md.Element>[];
    void collect(md.Element element) {
      for (final child in element.children ?? const <md.Node>[]) {
        if (child is md.Element && child.tag == 'tr') {
          rows.add(child);
        } else if (child is md.Element) {
          collect(child);
        }
      }
    }
    collect(table);
    if (rows.length > HybridMarkdownParser.maxTableRows) {
      return SelectableText(table.textContent);
    }
    final firstCells = rows.isEmpty
        ? const <md.Element>[]
        : (rows.first.children ?? const <md.Node>[]).whereType<md.Element>().where((e) => e.tag == 'th' || e.tag == 'td').toList();
    if (firstCells.length > HybridMarkdownParser.maxTableColumns) {
      return SelectableText(table.textContent);
    }
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: theme.dividerColor),
        children: rows.map((row) {
          final cells = (row.children ?? const <md.Node>[]).whereType<md.Element>().where((e) => e.tag == 'th' || e.tag == 'td').toList();
          return TableRow(
            children: [
              for (final cell in cells)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text.rich(
                    TextSpan(children: (cell.children ?? const <md.Node>[]).map((child) => _inline(context, child, theme.textTheme.bodySmall)).toList()),
                    style: cell.tag == 'th' ? theme.textTheme.labelLarge : theme.textTheme.bodySmall,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  InlineSpan _inline(BuildContext context, md.Node node, TextStyle? inherited) {
    if (node is md.Text) return TextSpan(text: node.text, style: inherited);
    if (node is! md.Element) return const TextSpan();
    final children = (node.children ?? const <md.Node>[])
        .map((child) => _inline(context, child, inherited))
        .toList();
    final theme = Theme.of(context);
    final base = inherited ?? theme.textTheme.bodyMedium;
    switch (node.tag) {
      case 'strong':
      case 'b':
        return TextSpan(children: children, style: base?.copyWith(fontWeight: FontWeight.bold));
      case 'em':
      case 'i':
        return TextSpan(children: children, style: base?.copyWith(fontStyle: FontStyle.italic));
      case 'del':
      case 's':
      case 'strike':
        return TextSpan(children: children, style: base?.copyWith(decoration: TextDecoration.lineThrough));
      case 'ins':
        return TextSpan(children: children, style: base?.copyWith(decoration: TextDecoration.underline));
      case 'code':
        return TextSpan(
          children: children,
          style: base?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        );
      case 'kbd':
        return TextSpan(
          text: '[${node.textContent}]',
          style: base?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w600),
        );
      case 'br':
        return const TextSpan(text: '\n');
      case 'span':
        if (node.attributes['data-semantic-color'] == 'danger') {
          return TextSpan(children: children, style: base?.copyWith(color: theme.colorScheme.error));
        }
        return TextSpan(children: children);
      case 'a':
        final destination = node.attributes['href'] ?? '';
        if (HybridMarkdownParser.isAllowedUrl(destination)) {
          return TextSpan(
            children: children,
            style: base?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          );
        }
        return TextSpan(children: children);
      case 'img':
        final alt = node.attributes['alt'] ?? 'Image unavailable';
        return TextSpan(text: '[Image: $alt]');
      case 'input':
        return const TextSpan();
      default:
        return TextSpan(children: children);
    }
  }
}
