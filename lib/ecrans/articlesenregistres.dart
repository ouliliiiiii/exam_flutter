import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/db_helper.dart';
import 'detailsarticle.dart';

class ArticlesEnregistres extends StatefulWidget {
  @override
  _ArticlesEnregistresState createState() => _ArticlesEnregistresState();
}

class _ArticlesEnregistresState extends State<ArticlesEnregistres> {
  final DbHelper _dbHelper = DbHelper();
  List<Article> savedArticles = [];

  @override
  void initState() {
    super.initState();
    loadSavedArticles();
  }

  Future<void> loadSavedArticles() async {
    final articles = await _dbHelper.getAllArticles();
    setState(() {
      savedArticles = articles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Articles sauvegardés")),
      body: ListView.builder(
        itemCount: savedArticles.length,
        itemBuilder: (context, index) {
          final article = savedArticles[index];
          return ListTile(
            title: Text(article.titre),
            subtitle: Text(article.auteur ?? 'Auteur inconnu'),
            onTap: () {
              // Par exemple, ouvrir la page de détail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsArticle(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
