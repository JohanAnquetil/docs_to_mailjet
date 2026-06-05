import '../main.dart';

class Constants {
  static final googleDocumentId = env['googleDocumentId']!;

  static final String googleDocsUrl =
      "https://docs.google.com/document/d/$googleDocumentId/edit";

  static final String googleKeyCredentialPath = env['google_credentials']!;

  static final String apiKey = env['mailjet_api_key']!;

  static final String secretKey = env['mailjet_secret_key']!;
}
