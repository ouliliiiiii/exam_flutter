import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';
import 'package:exam_flutter/models/commentaire.dart';
import 'package:http/http.dart' as http;

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'articles.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE articles (
            id INTEGER PRIMARY KEY,
            titre TEXT,
            auteur TEXT,
            nbre_commentaire INTEGER,
            url TEXT,
            texte TEXT,
            is_favori INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE commentaires (
            id INTEGER PRIMARY KEY,
            id_article INTEGER,
            auteur TEXT,
            texte TEXT,
            parent_id INTEGER,
            FOREIGN KEY (id_article) REFERENCES articles (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE articles ADD COLUMN is_favori INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> insertCommentaires(
    List<Commentaire> commentaires,
    int idArticle,
  ) async {
    final db = await database;
    for (var com in commentaires) {
      await db.insert('commentaires', {
        'id': com.id,
        'id_article': idArticle,
        'auteur': com.auteur,
        'texte': com.texte,
        'parent_id': com.parentId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> insertArticle(Article article) async {
    final db = await database;
    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFavori(int articleId, bool isFavori) async {
    final db = await database;
    await db.update(
      'articles',
      {'is_favori': isFavori ? 1 : 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<Article?> getArticle(int id) async {
    final db = await database;
    final maps = await db.query('articles', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final data = maps.first;
      final commentMaps = await db.query(
        'commentaires',
        where: 'id_article = ?',
        whereArgs: [id],
      );
      List<Commentaire> commentaires = commentMaps
          .map(
            (comData) => Commentaire(
              id: comData['id'] as int,
              auteur: comData['auteur'] as String?,
              texte: comData['texte'] as String?,
              parentId: comData['parent_id'] as int?,
              reponses: [],
              enfants_com: [],
            ),
          )
          .toList();

      return Article.fromDb(data, commentaires);
    }
    return null;
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;

    // Récupérer tous les articles
    final articlesMaps = await db.query('articles');

    List<Article> articles = [];

    for (var articleData in articlesMaps) {
      final commentMaps = await db.query(
        'commentaires',
        where: 'id_article = ?',
        whereArgs: [articleData['id']],
      );

      // Convertir les commentaires en objets Commentaire
      List<Commentaire> commentaires = commentMaps.map((comData) {
        return Commentaire(
          id: comData['id'] as int,
          auteur: comData['auteur'] as String?,
          texte: comData['texte'] as String?,
          parentId: comData['parent_id'] as int?,
          reponses: [],
          enfants_com: [],
        );
      }).toList();

      articles.add(Article.fromDb(articleData, commentaires));
    }

    return articles;
  }

  Future<void> nettoyerArticlesInaccessibles() async {
    final db = await database;
    final articles = await db.query('articles', where: 'is_favori = 0');

    for (var article in articles) {
      final id = article['id'];
      final response = await http.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'),
      );

      if (response.statusCode != 200 || response.body == 'null') {
        await db.delete('articles', where: 'id = ?', whereArgs: [id]);
        await db.delete(
          'commentaires',
          where: 'id_article = ?',
          whereArgs: [id],
        );
        print("Article $id supprimé (inaccessible et non favori)");
      }
    }
  }

  Future<List<Article>> getFavoris() async {
    final db = await database;
    final maps = await db.query('articles', where: 'is_favori = 1');
    List<Article> favoris = [];

    for (var data in maps) {
      final commentaires = await db.query(
        'commentaires',
        where: 'id_article = ?',
        whereArgs: [data['id']],
      );
      final coms = commentaires
          .map(
            (e) => Commentaire(
              id: e['id'] as int,
              auteur: e['auteur'] as String?,
              texte: e['texte'] as String?,
              parentId: e['parent_id'] as int?,
              enfants_com: [],
              reponses: [],
            ),
          )
          .toList();

      favoris.add(Article.fromDb(data, coms));
    }
    return favoris;
  }
}
