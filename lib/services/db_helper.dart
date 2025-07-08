import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';
import 'package:exam_flutter/models/commentaire.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE articles (
            id INTEGER PRIMARY KEY,
            titre TEXT,
            auteur TEXT,
            nbre_commentaire INTEGER,
            url TEXT,
            texte TEXT
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
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE articles ADD COLUMN texte TEXT');
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

  Future<Article?> getArticle(int id) async {
    final db = await database;
    final maps = await db.query('articles', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final data = maps.first;
      return Article(
        id: data['id'] as int,
        titre: data['titre'] as String,
        auteur: data['auteur'] as String?,
        nbre_commentaire: data['nbre_commentaire'] as int?,
        url: data['url'] as String?,
        texte: data['texte'] as String?,
        id_com: [],
      );
    }
    return null;
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;

    // Récupérer tous les articles
    final articlesMaps = await db.query('articles');

    List<Article> articles = [];

    for (var articleData in articlesMaps) {
      // Récupérer les commentaires associés à cet article
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

      articles.add(
        Article(
          id: articleData['id'] as int,
          titre: articleData['titre'] as String,
          auteur: articleData['auteur'] as String?,
          nbre_commentaire: articleData['nbre_commentaire'] as int?,
          url: articleData['url'] as String?,
          id_com: commentaires.map((c) => c.id).toList(),
          commentaires: commentaires,
        ),
      );
    }

    return articles;
  }
}
