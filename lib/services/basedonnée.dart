import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

class BaseD {
  static final BaseD _instance = BaseD._internal();
  static Database? _database;

  BaseD._internal();

  factory BaseD() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'articles.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE articles (
            id INTEGER PRIMARY KEY,
            titre TEXT,
            auteur TEXT,
            nbre_commentaire INTEGER,
            url TEXT,
            isFavorite INTEGER
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> insertArticle(Article article, {bool isFavorite = false}) async {
    final db = await database;
    await db.insert('articles', {
      ...article.toMap(),
      'isFavorite': isFavorite ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Article>> getArticles() async {
    final db = await database;
    final maps = await db.query('articles');
    return maps
        .map(
          (e) => Article(
            id: e['id'] as int,
            titre: e['titre'] as String,
            auteur: e['auteur'] as String?,
            nbre_commentaire: e['nbre_commentaire'] as int?,
            url: e['url'] as String?,
          ),
        )
        .toList();
  }

  Future<void> deleteNonFavoriteIfMissing(List<int> apiIds) async {
    final db = await database;
    await db.delete(
      'articles',
      where: 'isFavorite = 0 AND id NOT IN (${apiIds.join(',')})',
    );
  }

  Future<void> updateFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'articles',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Article>> getFavorites() async {
    final db = await database;
    final maps = await db.query('articles', where: 'isFavorite = 1');
    return maps
        .map(
          (e) => Article(
            id: e['id'] as int,
            titre: e['titre'] as String,
            auteur: e['auteur'] as String?,
            nbre_commentaire: e['nbre_commentaire'] as int?,
            url: e['url'] as String?,
          ),
        )
        .toList();
  }
}
