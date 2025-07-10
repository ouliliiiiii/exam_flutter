import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/commentaire.dart';
import '../services/api.dart';
import '../services/commentaireservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/db_helper.dart';

class DetailsArticle extends StatefulWidget {
  final Article article;

  const DetailsArticle({super.key, required this.article});

  @override
  State<DetailsArticle> createState() => _DetailsArticleState();
}

class _DetailsArticleState extends State<DetailsArticle> {
  final Api api = Api();
  List<Commentaire> commentaires = [];
  late bool isFavori;
  final DbHelper _dbHelper = DbHelper();
  Set<int> commentairesAvecReponsesVisibles = {};
  Set<int> commentairesAvecTexteComplet = {};
  bool articleTexteComplet = false;
  final int maxLinesPreview = 3;

  @override
  void initState() {
    super.initState();
    fetchCommentaires(widget.article.id);
    isFavori = widget.article.isFavori;
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                com.auteur ?? 'Anonyme',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                texteNettoye,
                maxLines: showFullText ? null : maxLinesPreview,
                overflow: showFullText
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
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
              if (com.reponses.isNotEmpty)
                TextButton(
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
              if (showReplies)
                ...com.reponses
                    .map((rep) => buildComment(rep, depth: depth + 1))
                    .toList(),
            ],
          ),
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.titre),
        actions: [
          IconButton(
            icon: Icon(
              isFavori ? Icons.star : Icons.star_border,
              color: Colors.amberAccent,
              size: 28,
            ),
            onPressed: () async {
              setState(() {
                isFavori = !isFavori;
              });
              await _dbHelper.updateFavori(widget.article.id, isFavori);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.article.titre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text("Auteur : ${widget.article.auteur ?? "Inconnu"}"),
          const SizedBox(height: 12),

          if (articleHasText)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
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
              ),
            ),

          if (commentaires.isEmpty &&
              widget.article.url != null &&
              widget.article.url!.trim().isNotEmpty &&
              widget.article.url! != "null")
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.open_in_new),
                label: const Text("Voir l'article complet"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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
