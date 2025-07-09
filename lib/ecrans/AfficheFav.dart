import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/db_helper.dart';
import 'detailsarticle.dart';

class AfficheFav extends StatefulWidget {
  @override
  _AfficheFavState createState() => _AfficheFavState();
}

class _AfficheFavState extends State<AfficheFav> {
  final DbHelper _dbHelper = DbHelper();
  List<Article> favoris = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerFavoris();
  }

  Future<void> chargerFavoris() async {
    final data = await _dbHelper.getFavoris();
    setState(() {
      favoris = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Articles Favoris')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoris.isEmpty
          ? const Center(
              child: Text(
                'Aucun article favori.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: favoris.length,
              itemBuilder: (context, index) {
                final article = favoris[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      article.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Auteur : ${article.auteur ?? "Inconnu"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsArticle(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
