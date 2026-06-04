import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class MailjetService {
  Future<void> createCampaignDraft(Map<String, String> variables) async {
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';
    final name = dotenv.get('newsletter_name');
    final int contactListId = int.parse((dotenv.get('contact_id_list')));

    final credentials = base64Encode(
      utf8.encode('${Constants.apiKey}:${Constants.secretKey}'),
    );
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
        'Sender': dotenv.get('sender_name'),
        'SenderEmail': dotenv.get('sender_email'),
        'EditMode': 'html2',
        'Subject': '$name du $date',
        'ContactsListID': contactListId,
        'Title': '$name du $date',
      }),
    );

    final campaignData = jsonDecode(campaignResponse.body);
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
