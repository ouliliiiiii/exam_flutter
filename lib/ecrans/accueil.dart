import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/article.dart';
import 'detailsarticle.dart';
import '../services/db_helper.dart';
import 'affichefav.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final Api api = Api();
  final DbHelper _dbHelper = DbHelper();

  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    fetchTopArticles();
  }

  Future<void> fetchTopArticles() async {
    List<int> ids = await api.fetchTopStories();
    List<Article> fetched = [];
    for (int i = 0; i < 10; i++) {
      final art = await api.fetchArticle(ids[i]);
      if (art != null) fetched.add(art);
    }
    setState(() {
      articles = fetched;
    });
  }

  Future<void> toggleFavori(int articleId) async {
    final index = articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final current = articles[index];
      final newStatus = !current.isFavori;
      await _dbHelper.updateFavori(articleId, newStatus);
      setState(() {
        articles[index] = current.copyWith(isFavori: newStatus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            tooltip: 'Voir les favoris',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AfficheFav()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                article.titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auteur : ${article.auteur ?? 'Inconnu'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${article.nbre_commentaire ?? 0} commentaires',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  article.isFavori ? Icons.star : Icons.star_border,
                  color: article.isFavori ? Colors.amber : Colors.grey,
                ),
                onPressed: () => toggleFavori(article.id),
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
