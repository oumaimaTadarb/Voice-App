import 'dart:convert';
import 'package:http/http.dart' as http;

const openAIAPIKey = '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';

class OpenAIService {
  final List<Map<String, String>> messages = [];
//envoyer une requette POST à l'API
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        //Méthode POST
        Uri.parse('https://api.openai.com/v1/chat/completions'), //URL de l'API
        headers: {
          'Content-Type':
              'application/json', // Indique que le corps de la requête est au format JSON.
          'Authorization':
              'Bearer $openAIAPIKey', //Utilise la clé d'API pour l'authentification avec OpenA
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo", //Spécifie le modèle GPT-3.5 Turbo d'OpenAI
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
            }
          ], //Un tableau de messages où le premier message est défini comme un utilisateur ('role': 'user') avec le contenu de la question.
          //Le message demande si le texte doit générer une image AI, une œuvre d'art, ou quelque chose de similaire, et inclut le contenu de la variable $prompt.
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        //OK
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
// extrait le contenu de la réponse JSON, spécifiquement à partir de la propriété 'choices',
// puis du premier choix (indice 0), et enfin du contenu du message. Le contenu est ensuite débarrassé des espaces indésirables avec trim()
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error ';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      //ajouter le message des utilisateurs
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        //envoyer POST
        Uri.parse(
            'https://api.openai.com/v1/chat/completions'), // Indique que le corps de la requête est au format JSON.
        headers: {
          //Les en-têtes de la requête. Ces en-têtes incluent le type de contenu JSON
          'Content-Type':
              'application/json', // Indique que le corps de la requête est au format JSON.
          'Authorization': 'Bearer $openAIAPIKey', //autorisation via key l API
        },
        body: jsonEncode({
          "model":
              "gpt-3.5-turbo", //Spécifie le modèle GPT-3.5 Turbo d'OpenAI pour la requète
          "messages":
              messages, //la liste des messages qui représente la conversation
        }),
      );

      if (res.statusCode == 200) {
        //si OK
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        // extraire le contenu de la réponse JSON.
        //Le contenu est situé à l'intérieur de la propriété 'choices',
        //puis du premier choix (indice 0), et enfin du contenu du message.

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        //La réponse de l'assistant est ajoutée à la liste des messages avec le rôle 'assistant'
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
