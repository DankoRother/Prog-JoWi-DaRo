import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = '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';  // Hier deinen OpenAI API-Schlüssel einfügen
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    try {
      var response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',  // Oder 'gpt-3.5-turbo' falls du GPT-3.5 nutzen willst
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': message},
          ],
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var reply = jsonResponse['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('Error: ${response.body}');
        return 'Error: Could not fetch a response from OpenAI.';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error: Could not fetch a response from OpenAI.';
    }
  }
}
