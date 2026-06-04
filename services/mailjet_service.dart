import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MailjetService {
  final String _apiKey = '825e3bd19c04f224d53476f7bd1959d9';
  final String _secretKey = '5b44621a24931e112930951059c68705';

  Future<void> createCampaignDraft(Map<String, String> variables) async {
    final credentials = base64Encode(utf8.encode('$_apiKey:$_secretKey'));
    final template = await _loadTemplate();
    final htmlBody = _buildTemplateHtml(variables, template);

    // 1. Créer le brouillon de campagne
    final campaignResponse = await http.post(
      Uri.parse('https://api.mailjet.com/v3/REST/campaigndraft'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Locale': 'fr_FR',
        'Sender': 'Chez Pol', // ✅ champ Sender
        'SenderEmail': 'pedrolitau@hotmail.com',
        'EditMode': 'html2',
        'Subject':
            'Chez Pol du ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'ContactsListID': 10519270,
        'Title':
            'Chez Pol - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      }),
    );

    final campaignData = jsonDecode(campaignResponse.body); // ← monte ici
    final campaignId = campaignData['Data'][0]['ID'];

    // 2. Injecter le contenu HTML avec les variables

    await http.post(
      Uri.parse(
          'https://api.mailjet.com/v3/REST/campaigndraft/$campaignId/detailcontent'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Html-part': htmlBody,
        'Text-part': '',
      }),
    );
  }

  Future<String> _loadTemplate() async {
    return await File('assets/template.html').readAsString();
  }

  String _buildTemplateHtml(Map<String, String> variables, String template) {
    var html = template;
    variables.forEach((key, value) {
      html = html.replaceAll('{{$key}}', value);
    });
    return html;
  }
}
