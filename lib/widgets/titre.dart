import 'package:flutter/material.dart';
import '../models/article.dart';

class Titre extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const Titre({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(article.titre),
        subtitle: Text('Par ${article.auteur ?? "?"}'),
        trailing: Text('${article.nbre_commentaire ?? 0} commentaires'),
        onTap: onTap,
      ),
    );
  }
}
