import 'package:flutter/material.dart';
import '../models/article.dart';

class Titre extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const Titre({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          article.titre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Par ${article.auteur ?? "?"}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.comment, size: 20, color: Colors.indigo),
            const SizedBox(height: 4),
            Text(
              '${article.nbre_commentaire ?? 0}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
