import 'package:googleapis/docs/v1.dart' as docs;
import '../services/mailjet_image_service.dart';
import 'build_html.dart';
import './rubriques.dart';

Future<Map<String, String>> parseDoc(docs.Document document) async {
  final Map<String, StringBuffer> buffers = {
    'hashtags': StringBuffer(),
    'intro': StringBuffer(),
    'sommaire': StringBuffer(),
    'au_comptoir': StringBuffer(),
    'youpol': StringBuffer(),
    'passion_archives': StringBuffer(),
    'ca_arrive': StringBuffer(),
    'laddition': StringBuffer(),
  };

  String currentKey = 'hashtags';
  final inlineObjects = document.inlineObjects ?? {};

  for (final element in document.body?.content ?? []) {
    final paragraph = element.paragraph;
    if (paragraph == null) continue;

    final styleType = paragraph.paragraphStyle?.namedStyleType;

    if (styleType == 'HEADING_1') {
      final text = paragraph.elements
              ?.map((e) => e.textRun?.content ?? '')
              .join()
              .trim()
              .toUpperCase() ??
          '';
      final matchedKey = rubriques[text];
      if (matchedKey != null) {
        currentKey = matchedKey;
        continue;
      }
    }

    final html = buildHtml([element], inlineObjects);
    if (currentKey == 'hashtags' && html.contains('<img')) {
      currentKey = 'intro';
    }
    if (html.trim().isNotEmpty) {
      buffers[currentKey]?.write(html);
    }
  }

  final imageService = MailjetImageService();
  final updatedResult = <String, String>{};
  final regex =
      RegExp(r'src="(https://lh\d+-rt\.googleusercontent\.com/[^"]+)"');

  for (final entry in buffers.entries) {
    String html = entry.value.toString();
    final matches = regex.allMatches(html);

    for (final match in matches) {
      final googleUrl = match.group(1)!;
      final mailjetUrl = await imageService.uploadImage(googleUrl);
      if (mailjetUrl != null) {
        html = html.replaceAll(googleUrl, mailjetUrl);
      }
    }

    updatedResult[entry.key] = html;
  }

  return updatedResult;
}
