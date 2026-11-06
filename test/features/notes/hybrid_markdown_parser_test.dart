import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' show Element, Node, Text;
import 'package:yamintto/features/notes/domain/hybrid_markdown_parser.dart';

void main() {
  const parser = HybridMarkdownParser();

  bool containsTag(List<Node> nodes, String tag) {
    for (final node in nodes) {
      if (node is Element) {
        if (node.tag == tag || containsTag(node.children ?? const [], tag)) {
          return true;
        }
      }
    }
    return false;
  }

  String textContent(List<Node> nodes) => nodes.map((node) {
    if (node is Text) return node.text;
    if (node is Element) return textContent(node.children ?? const []);
    return node.textContent;
  }).join();

  group('HybridMarkdownParser', () {
    test('parses modern Markdown and GFM structures into an AST', () {
      const source = '''
# Heading

A **bold**, _italic_, ~~struck~~ and `inline code` paragraph.

- parent
  - nested
1. ordered
   1. nested ordered

> quoted

| A | B |
|---|---|
| one | two |

- [ ] open task
- [x] done task

```dart
void main() {}
```
''';
      final result = parser.parse(source);
      expect(result.source, source);
      expect(containsTag(result.nodes, 'h1'), isTrue);
      expect(containsTag(result.nodes, 'strong'), isTrue);
      expect(containsTag(result.nodes, 'em'), isTrue);
      expect(containsTag(result.nodes, 'del'), isTrue);
      expect(containsTag(result.nodes, 'code'), isTrue);
      expect(containsTag(result.nodes, 'ul'), isTrue);
      expect(containsTag(result.nodes, 'ol'), isTrue);
      expect(containsTag(result.nodes, 'blockquote'), isTrue);
      expect(containsTag(result.nodes, 'table'), isTrue);
      expect(containsTag(result.nodes, 'input'), isTrue);
      expect(containsTag(result.nodes, 'pre'), isTrue);
    });

    test('supports only verified safe legacy inline and details syntax', () {
      const source = '''
<details>
<summary>Keyboard help</summary>
Press <kbd>Ctrl</kbd>, <ins>added</ins>, <del>removed</del><br>
<span style="color: red">important</span>
</details>
''';
      final result = parser.parse(source);
      expect(containsTag(result.nodes, 'details'), isTrue);
      expect(containsTag(result.nodes, 'summary'), isTrue);
      expect(containsTag(result.nodes, 'kbd'), isTrue);
      expect(containsTag(result.nodes, 'ins'), isTrue);
      expect(containsTag(result.nodes, 'del'), isTrue);
      expect(containsTag(result.nodes, 'br'), isTrue);
      expect(containsTag(result.nodes, 'span'), isTrue);
    });

    test('keeps unsupported HTML inert and source unchanged', () {
      const source = '<script>alert(1)</script> <img src=x onerror=alert(1)>';
      final result = parser.parse(source);
      expect(result.source, source);
      expect(containsTag(result.nodes, 'script'), isFalse);
      expect(containsTag(result.nodes, 'img'), isFalse);
      expect(textContent(result.nodes), contains('<script>'));
      expect(textContent(result.nodes), contains('onerror'));
    });

    test('maps no arbitrary CSS or unapproved span colors', () {
      const source = '<span style="color: #ff00ff">unsafe color</span>';
      final result = parser.parse(source);
      expect(containsTag(result.nodes, 'span'), isFalse);
      expect(textContent(result.nodes), contains('color: #ff00ff'));
    });

    test('validates URL schemes and rejects URL tricks', () {
      expect(HybridMarkdownParser.isAllowedUrl('https://example.com/a'), isTrue);
      expect(HybridMarkdownParser.isAllowedUrl('http://example.com'), isTrue);
      expect(HybridMarkdownParser.isAllowedUrl('mailto:help@example.com'), isTrue);
      for (final url in [
        'javascript:alert(1)',
        'data:text/html,<script>',
        'file:///etc/passwd',
        'content://private/item',
        'intent://open',
        'https://',
        'https://user:pass@example.com',
        'https://example.com/${'x' * 2100}',
      ]) {
        expect(HybridMarkdownParser.isAllowedUrl(url), isFalse, reason: url);
      }
    });

    test('rejects oversized source before parsing', () {
      expect(
        () => parser.parse('x' * (HybridMarkdownParser.maxSourceBytes + 1)),
        throwsA(isA<MarkdownParseException>()),
      );
    });

    test('rejects excessive nesting and table dimensions', () {
      final deeplyNested = List.generate(
        40,
        (index) => '${' ' * (index * 4)}- nested',
      ).join('\n');
      expect(() => parser.parse(deeplyNested), throwsA(isA<MarkdownParseException>()));

      final header = List.generate(21, (index) => 'c$index').join(' | ');
      final separator = List.generate(21, (_) => '---').join(' | ');
      final row = List.generate(21, (_) => 'x').join(' | ');
      expect(
        () => parser.parse('| $header |\n| $separator |\n| $row |'),
        throwsA(isA<MarkdownParseException>()),
      );
    });

    test('preserves malformed details source as inert text', () {
      const source = '<details>\n<summary>missing close';
      final result = parser.parse(source);
      expect(result.source, source);
      expect(textContent(result.nodes), contains('<details>'));
    });
  });
}
