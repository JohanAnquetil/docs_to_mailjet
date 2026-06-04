import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MailjetImageService {
  final String _apiKey = '825e3bd19c04f224d53476f7bd1959d9';
  final String _secretKey = '5b44621a24931e112930951059c68705';

  Future<String?> uploadImage(String googleUrl) async {
    try {
      // 1. Télécharger l'image depuis Google
      final imageResponse = await http.get(Uri.parse(googleUrl));
      if (imageResponse.statusCode != 200) return null;

      final imageBytes = imageResponse.bodyBytes;
      final contentType = imageResponse.headers['content-type'] ?? 'image/jpeg';
      final extension = contentType.contains('png')
          ? 'png'
          : contentType.contains('gif')
              ? 'gif'
              : 'jpg';

      final credentials = base64Encode(utf8.encode('$_apiKey:$_secretKey'));

      // 2. Upload sur MailJet
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.mailjet.com/v1/data/images'),
      );
      request.headers['Authorization'] = 'Basic $credentials';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename:
            'chez-pol-${DateTime.now().millisecondsSinceEpoch}.$extension',
        contentType: MediaType.parse(contentType),
      ));
      request.files.add(http.MultipartFile.fromString(
        'Metadata',
        jsonEncode({
          'Name': 'chez-pol-${DateTime.now().millisecondsSinceEpoch}',
          'Status': 'open',
        }),
        contentType: MediaType.parse('application/json'),
      ));

      final response = await request.send();
      final body = jsonDecode(await response.stream.bytesToString());
      final imageUrl = body['Data'][0]['ImageUrl'] as String;
      return imageUrl;
    } catch (e) {
      print('Erreur upload image: $e');
      return null;
    }
  }
}
