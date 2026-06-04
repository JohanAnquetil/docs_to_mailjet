import 'package:googleapis/docs/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleDocsService {
  final AuthClient client;

  GoogleDocsService(this.client); // le client est injecté

  Future<Document> getDocument(String documentId) async {
    final api = DocsApi(client);
    return await api.documents.get(documentId);
  }
}
