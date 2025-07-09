import 'commentaire.dart';

class Article {
  final int id;
  final String titre;
  final String? auteur;
  final int? nbre_commentaire;
  final String? url;
  final List<int>? id_com;
  final String? texte;
  final List<Commentaire> commentaires;
  final bool isFavori;

  Article({
    required this.id,
    required this.titre,
    this.auteur,
    this.nbre_commentaire,
    this.url,
    this.id_com,
    this.texte,
    this.commentaires = const [],
    this.isFavori = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      titre: json['title'] ?? 'pas de titre',
      auteur: json['by'],
      nbre_commentaire: json['descendants'],
      url: json['url'],
      id_com: (json['kids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      texte: json['text'],
    );
  }

  factory Article.fromDb(
    Map<String, dynamic> data,
    List<Commentaire> commentaires,
  ) {
    return Article(
      id: data['id'] as int,
      titre: data['titre'] as String,
      auteur: data['auteur'] as String?,
      nbre_commentaire: data['nbre_commentaire'] as int?,
      url: data['url'] as String?,
      texte: data['texte'] as String?,
      commentaires: commentaires,
      id_com: commentaires.map((c) => c.id).toList(),
      isFavori: (data['is_favori'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'nbre_commentaire': nbre_commentaire,
      'url': url,
      'texte': texte,
      'is_favori': isFavori ? 1 : 0,
    };
  }

  Article copyWith({bool? isFavori}) {
    return Article(
      id: id,
      titre: titre,
      auteur: auteur,
      nbre_commentaire: nbre_commentaire,
      url: url,
      texte: texte,
      id_com: id_com,
      commentaires: commentaires,
      isFavori: isFavori ?? this.isFavori,
    );
  }
}
