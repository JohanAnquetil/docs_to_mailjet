import 'dart:io';

import 'package:googleapis/docs/v1.dart';

import '../utils/build_html.dart';

class ExportHtml {
  final String htmlName;
  final Document document;

  ExportHtml(this.htmlName, this.document);

  Future<void> exportHtml() async {
    final html = buildHtml(
      document.body?.content ?? [],
      document.inlineObjects ?? {},
    );

    final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
    h1 { font-size: 24px; }
    h2 { font-size: 18px; }
    img { max-width: 100%; height: auto; }
  </style>
</head>
<body>
$html
</body>
</html>''';

    await Directory('export').create(recursive: true);
    await File('export/$htmlName.html').writeAsString(fullHtml);
  }
}
