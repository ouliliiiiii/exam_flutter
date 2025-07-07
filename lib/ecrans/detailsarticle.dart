import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/commentaire.dart';
import '../services/api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/db_helper.dart';

class DetailsArticle extends StatefulWidget {
  final Article article;

  const DetailsArticle({super.key, required this.article});

  @override
  State<DetailsArticle> createState() => _DetailsArticleState();
}

class _DetailsArticleState extends State<DetailsArticle> {
  final Api api = Api();
  final DbHelper dbHelper = DbHelper();
  List<Commentaire> commentaires = [];
  Set<int> expandedComments = {};

  /////////////////je charge ici les commentaires
  @override
  void initState() {
    super.initState();
    fetchCommentaires();
  }

  /////////////////je recupere les commentaires
  Future<void> fetchCommentaires() async {
    if (widget.article.id_com == null) return;

    List<Commentaire> loaded = [];

    for (var id in widget.article.id_com!) {
      final c = await api.fetchCommentWithReplies(id);
      if (c != null) loaded.add(c);
    }

    setState(() {
      commentaires = loaded;
    });
  }

  //////////////////et je les affiche ici
  Widget buildComment(Commentaire com, {int depth = 0}) {
    final isExpanded = expandedComments.contains(com.id);

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.grey[100],
            child: ListTile(
              title: Text(com.auteur ?? 'Anonyme'),
              subtitle: Text(
                com.texte?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          if (com.reponses.isNotEmpty && !isExpanded)
            TextButton(
              onPressed: () {
                setState(() {
                  expandedComments.add(com.id);
                });
              },
              child: const Text("Voir les réponses"),
            ),
          if (isExpanded)
            ...com.reponses
                .map((rep) => buildComment(rep, depth: depth + 1))
                .toList(),
        ],
      ),
    );
  }

  /////////////enregistrer l article que je veux dans ma base
  Future<void> enregistrerArticle() async {
    final existing = await dbHelper.getArticle(widget.article.id);

    if (existing != null) {
      // L'article est déjà en base
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article déjà enregistré'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    await dbHelper.insertArticle(widget.article);
    await dbHelper.insertCommentaires(commentaires, widget.article.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Article enregistré avec succès'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

          //////////le lien si l article  n est pas dispo
          if ((widget.article.url != null && widget.article.url!.isNotEmpty) &&
              (widget.article.texte == null || widget.article.texte!.isEmpty))
            TextButton(
              onPressed: () async {
                final url = Uri.parse(widget.article.url!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impossible d’ouvrir le lien'),
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

          //////////////////Liste des autres commentaires
          ...commentaires.map((c) => buildComment(c)).toList(),
        ],
      ),
    );
  }
}
