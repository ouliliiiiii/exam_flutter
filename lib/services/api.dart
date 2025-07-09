import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/commentaire.dart';
import 'db_helper.dart';

class Api {
  static const String _baseUrl = 'https://hacker-news.firebaseio.com/v0';
  final DbHelper _dbHelper = DbHelper();

  /// Récupère la liste des IDs des top stories
  Future<List<int>> fetchTopStories() async {
    final response = await http.get(Uri.parse('$_baseUrl/topstories.json'));
    if (response.statusCode == 200) {
      return List<int>.from(json.decode(response.body));
    } else {
      print('Erreur lors du chargement des top stories');
      return [];
    }
  }

  /// Récupère un article depuis la base locale, sinon via l'API
  Future<Article?> fetchArticle(int id) async {
    // Vérifier en local
    final localArticle = await _dbHelper.getArticle(id);
    if (localArticle != null) {
      print('Article $id chargé depuis la base locale');
      return localArticle;
    }

    // Sinon charger depuis API
    final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
    if (response.statusCode == 200) {
      final article = Article.fromJson(json.decode(response.body));
      await _dbHelper.insertArticle(article);
      print('Article $id chargé depuis l\'API et sauvegardé localement');
      return article;
    } else {
      print('Erreur de chargement article $id');
      return null;
    }
  }

  /// Récupère un commentaire et ses réponses récursivement
  Future<Commentaire?> fetchCommentWithReplies(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final commentaire = Commentaire.fromJson(data);

      if (commentaire.enfants_com != null &&
          commentaire.enfants_com!.isNotEmpty) {
        final List<Commentaire> replies = [];

        for (int childId in commentaire.enfants_com!) {
          final reply = await fetchCommentWithReplies(childId);
          if (reply != null) replies.add(reply);
        }

        commentaire.reponses = replies;
      }

      return commentaire;
    } else {
      print('Erreur chargement commentaire $id');
      return null;
    }
  }

  /// Récupère une liste de commentaires à partir d'une liste d'IDs
  Future<List<Commentaire>> fetchCommentaires(List<int> ids) async {
    final List<Commentaire> commentaires = [];

    for (int id in ids) {
      final commentaire = await fetchCommentWithReplies(id);
      if (commentaire != null) {
        commentaires.add(commentaire);
      }
    }

    return commentaires;
  }
}
