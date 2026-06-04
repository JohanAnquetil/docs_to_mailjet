import 'package:googleapis/docs/v1.dart' as docs;

String buildHtml(
  List<docs.StructuralElement> content,
  Map<String, docs.InlineObject> inlineObjects,
) {
  final buffer = StringBuffer();
  bool inList = false;

  for (final element in content) {
    final paragraph = element.paragraph;

    if (paragraph != null) {
      final styleType = paragraph.paragraphStyle?.namedStyleType;
      final bullet = paragraph.bullet;

      // Début de liste
      if (bullet != null && !inList) {
        buffer.write('<ul>\n');
        inList = true;
      }

      if (bullet == null && inList) {
        buffer.write('</ul>\n');
        inList = false;
      }

      String tag = 'p';
      if (styleType == 'HEADING_1') tag = 'h1';
      if (styleType == 'HEADING_2') tag = 'h2';
      if (styleType == 'HEADING_3') tag = 'h3';

      final alignment = paragraph.paragraphStyle?.alignment;
      if (bullet != null && alignment != 'CENTER') tag = 'li';

      String alignStyle = '';
      if (alignment == 'CENTER') alignStyle = ' style="text-align:center;"';
      if (alignment == 'END') alignStyle = ' style="text-align:right;"';

      final innerBuffer = StringBuffer();

      for (final el in paragraph.elements ?? []) {
        // Image inline
        final inlineObjectElement = el.inlineObjectElement;
        if (inlineObjectElement != null) {
          final id = inlineObjectElement.inlineObjectId;
          if (id != null) {
            final inlineObject = inlineObjects[id];
            final uri = inlineObject?.inlineObjectProperties?.embeddedObject
                ?.imageProperties?.contentUri;
            if (uri != null) {
              innerBuffer.write(
                  '<img src="$uri" width="600" style="display:block; width:100%; max-width:600px;" />');
            }
          }
        }

        // Texte
        final textRun = el.textRun;
        if (textRun != null) {
          String text = textRun.content ?? '';
          if (text == '\n') {
            innerBuffer.write('<br>');
            continue;
          }

          final style = textRun.textStyle;
          final isBold = style?.bold ?? false;
          final isItalic = style?.italic ?? false;
          final isUnderline = style?.underline ?? false;
          final link = style?.link?.url;
          final color = style?.foregroundColor?.color?.rgbColor;
          final bgColor = style?.backgroundColor?.color?.rgbColor;
          final fontSize = style?.fontSize?.magnitude;

          // Échapper le HTML
          text = text
              .replaceAll('&', '&amp;')
              .replaceAll('<', '&lt;')
              .replaceAll('>', '&gt;');

          if (text.trim().startsWith('http') && text.trim().endsWith('.gif')) {
            final url = text.trim();
            innerBuffer.write(
                '<img src="$url" style="max-width:100%; display:block; margin: 0 auto;" />');
            continue;
          }

          if (link != null) text = '<a href="$link">$text</a>';
          if (color != null) {
            final r = ((color.red ?? 0) * 255).round();
            final g = ((color.green ?? 0) * 255).round();
            final b = ((color.blue ?? 0) * 255).round();
            text = '<span style="color: rgb($r,$g,$b)">$text</span>';
          }

          if (bgColor != null) {
            final r = ((bgColor.red ?? 0) * 255).round();
            final g = ((bgColor.green ?? 0) * 255).round();
            final b = ((bgColor.blue ?? 0) * 255).round();
            text = '<span style="background-color: rgb($r,$g,$b)">$text</span>';
          }
          if (fontSize != null) {
            final emailSize = (fontSize * 1.33).round();
            text = '<span style="font-size: ${emailSize}px">$text</span>';
          }

          if (isBold) text = '<b>$text</b>';
          if (isItalic) text = '<i>$text</i>';
          if (isUnderline) text = '<u>$text</u>';

          innerBuffer.write(text);
        }
      }

      final inner = innerBuffer.toString().trim();

      if (inner.isNotEmpty) {
        if (inner.startsWith('<img') &&
            inner.indexOf('<img') == inner.lastIndexOf('<img')) {
          // Image seule → bord à bord
          buffer.write('<p style="margin: 0 -32px;">$inner</p>\n');
        } else if (bullet != null && alignment == 'CENTER') {
          if (inList) {
            buffer.write('</ul>\n');
            inList = false;
          }
          buffer.write(
              '<p style="text-align:center;"><span style="color:#e8412a;">• </span>$inner</p>\n');
        } else {
          buffer.write('<$tag$alignStyle>$inner</$tag>\n');
        }
      }
    }

    final table = element.table;
    if (table != null) {
      buffer.write('<table style="width:100%;">\n');
      for (final row in table.tableRows ?? []) {
        buffer.write('<tr>\n');
        for (final cell in row.tableCells ?? []) {
          buffer.write('<td style="vertical-align:top; padding:8px;">\n');
          buffer.write(buildHtml(cell.content ?? [], inlineObjects));
          buffer.write('</td>\n');
        }
        buffer.write('</tr>\n');
      }
      buffer.write('</table>\n');
    }
  }
  if (inList) buffer.write('</ul>\n');
  return buffer.toString();
}
