import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/commentaire.dart';
import 'db_helper.dart';

class Api {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';
  final DbHelper _dbHelper = DbHelper();

  Future<List<int>> fetchTopStories() async {
    final response = await http.get(Uri.parse('$_baseUrl/topstories.json'));
    if (response.statusCode == 200) {
      return List<int>.from(json.decode(response.body));
    }
    return [];
  }

  Future<Article?> fetchArticle(int id) async {
    // Ne pas chercher dans la base locale, charger toujours depuis l'API
    final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
    if (response.statusCode == 200) {
      final article = Article.fromJson(json.decode(response.body));

      // Sauvegarder en local si tu veux garder la copie
      await _dbHelper.insertArticle(article);

      print('Article chargé depuis l\'API et sauvegardé localement');
      return article;
    }
    return null;
  }

  ///////////////recuperation des commentaires
  Future<Commentaire?> fetchCommentWithReplies(int id) async {
    final response = await http.get(
      Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final commentaire = Commentaire.fromJson(data);

      if (commentaire.enfants_com != null &&
          commentaire.enfants_com!.isNotEmpty) {
        final List<Commentaire> replies = [];

        for (int childId in commentaire.enfants_com!) {
          final child = await fetchCommentWithReplies(childId);
          if (child != null) {
            replies.add(child);
          }
        }

        commentaire.reponses = replies;
      }

      return commentaire;
    }

    return null;
  }
}
