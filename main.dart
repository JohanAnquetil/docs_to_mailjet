import 'constants/constants.dart';
import 'models/google_client_account.dart';
import 'services/google_doc_service.dart';
import 'services/mailjet_service.dart';
import 'utils/parse_doc.dart';

Future<void> main() async {
  print("Transfert de la newsletter en cours...");
  Future.delayed(Duration(seconds: 5));
  final client = await GoogleClientAccount(
          credentialsPath: Constants.googleKeyCredentialPath)
      .getClient();
  try {
    final document =
        await GoogleDocsService(client).getDocument(Constants.googleDocumentId);
    final sections = await parseDoc(document);

    await MailjetService().createCampaignDraft(sections);

    print('Contenu envoyé à MailJet');
  } finally {
    client.close();
  }
}
