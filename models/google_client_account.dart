import 'dart:io';
import 'dart:convert';
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:googleapis_auth/auth_io.dart';

class GoogleClientAccount {
  final String credentialsPath;

  GoogleClientAccount({
    required this.credentialsPath,
  });

  Future<AuthClient> getClient() async {
    final serviceAccountJson =
        jsonDecode(await File(credentialsPath).readAsString());
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final scopes = [docs.DocsApi.documentsReadonlyScope];
    return await clientViaServiceAccount(credentials, scopes);
  }
}
