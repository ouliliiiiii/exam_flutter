import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/commentaire.dart';
import '../services/api.dart';
import '../services/commentaireservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailsArticle extends StatefulWidget {
  final Article article;

  const DetailsArticle({super.key, required this.article});

  @override
  State<DetailsArticle> createState() => _DetailsArticleState();
}

class _DetailsArticleState extends State<DetailsArticle> {
  final Api api = Api();
  List<Commentaire> commentaires = [];

  // Gère les commentaires dont on affiche les réponses
  Set<int> commentairesAvecReponsesVisibles = {};

  // Gère les textes complets affichés (pour "Lire la suite")
  Set<int> commentairesAvecTexteComplet = {};

  // Gère affichage complet du texte de l'article
  bool articleTexteComplet = false;

  final int maxLinesPreview = 3;

  @override
  void initState() {
    super.initState();
    fetchCommentaires(widget.article.id);
  }

  Future<void> fetchCommentaires(int articleId) async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/$articleId.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<int> commentIds = (data['kids'] as List?)?.cast<int>() ?? [];

      final commentaires = await CommentaireService.getCommentaires(commentIds);

      if (!mounted) return;
      setState(() {
        this.commentaires = commentaires;
      });
    } else {
      throw Exception("Erreur chargement article $articleId");
    }
  }

  Widget buildComment(Commentaire com, {int depth = 0}) {
    final texteNettoye = (com.texte ?? '').replaceAll(RegExp(r'<[^>]*>'), '');
    final bool showFullText = commentairesAvecTexteComplet.contains(com.id);
    final bool isLongText = texteNettoye.length > 150;

    bool showReplies = commentairesAvecReponsesVisibles.contains(com.id);

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.grey[100],
            child: ListTile(
              title: Text(com.auteur ?? 'Anonyme'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texteNettoye,
                    maxLines: showFullText ? null : maxLinesPreview,
                    overflow: showFullText
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (isLongText)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (showFullText) {
                            commentairesAvecTexteComplet.remove(com.id);
                          } else {
                            commentairesAvecTexteComplet.add(com.id);
                          }
                        });
                      },
                      child: Text(showFullText ? 'Réduire' : 'Lire la suite'),
                    ),
                ],
              ),
            ),
          ),
          if (com.reponses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (showReplies) {
                      commentairesAvecReponsesVisibles.remove(com.id);
                    } else {
                      commentairesAvecReponsesVisibles.add(com.id);
                    }
                  });
                },
                child: Text(
                  showReplies
                      ? 'Cacher les réponses (${com.reponses.length})'
                      : 'Voir les réponses (${com.reponses.length})',
                ),
              ),
            ),
          if (showReplies)
            ...com.reponses
                .map((rep) => buildComment(rep, depth: depth + 1))
                .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texteNettoye = (widget.article.texte ?? '').replaceAll(
      RegExp(r'<[^>]*>'),
      '',
    );
    final bool articleHasText = texteNettoye.isNotEmpty;

    final bool showArticleFullText = articleTexteComplet || !articleHasText;

    return Scaffold(
      appBar: AppBar(title: Text(widget.article.titre)),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Text(
            widget.article.titre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Auteur : ${widget.article.auteur ?? "Neant"}'),
          const SizedBox(height: 8),

          if (articleHasText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texteNettoye,
                  maxLines: articleTexteComplet ? null : maxLinesPreview,
                  overflow: articleTexteComplet
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                if (texteNettoye.length > 150)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        articleTexteComplet = !articleTexteComplet;
                      });
                    },
                    child: Text(
                      articleTexteComplet ? 'Réduire' : 'Lire la suite',
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 12),

          if (commentaires.isEmpty &&
              widget.article.url != null &&
              widget.article.url!.trim().isNotEmpty &&
              widget.article.url! != "null")
            TextButton(
              onPressed: () async {
                final uri = Uri.tryParse(widget.article.url!);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Impossible d'ouvrir le lien."),
                    ),
                  );
                }
              },
              child: const Text("Voir l'article au complet"),
            ),

          const Divider(),
          const Text(
            "Commentaires :",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          if (commentaires.isEmpty)
            const Center(
              child: Text(
                "Aucun commentaire à afficher.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else
            ...commentaires.map((c) => buildComment(c)).toList(),
        ],
      ),
    );
  }
}
