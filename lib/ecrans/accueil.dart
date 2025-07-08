import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/article.dart';
import 'detailsarticle.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final Api api = Api();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article.titre),
            subtitle: Text(article.auteur ?? ''),
            trailing: Text('${article.nbre_commentaire ?? 0} comments'),
            onTap: () {
              print('Titre: ${article.titre}');
              print('ID commentaires: ${article.id_com}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsArticle(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
