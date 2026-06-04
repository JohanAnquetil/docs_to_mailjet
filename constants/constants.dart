import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final googleDocumentId = dotenv.get('googleDocumentId');

  static final String googleDocsUrl =
      "https://docs.google.com/document/d/$googleDocumentId/edit";

  static final String googleKeyCredentialPath =
      dotenv.get('google_credentials');

  static final String apiKey = dotenv.get('mailjet_api_key');

  static final String secretKey = dotenv.get('mailjet_secret_key');
}
