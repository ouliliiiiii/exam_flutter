import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/commentaire.dart';

class CommentaireService {
  static Future<List<Commentaire>> getCommentaires(List<int> ids) async {
    final commentaires = <Commentaire>[];

    for (final id in ids) {
      final url = Uri.parse(
        'https://hacker-news.firebaseio.com/v0/item/$id.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final commentaire = Commentaire.fromJson(data);

        // Récupérer récursivement les réponses
        if (commentaire.enfants_com != null &&
            commentaire.enfants_com!.isNotEmpty) {
          commentaire.reponses = await getCommentaires(
            commentaire.enfants_com!,
          );
        }

        commentaires.add(commentaire);
      } else {
        print('Erreur chargement commentaire $id : ${response.statusCode}');
      }
    }

    return commentaires;
  }
}
