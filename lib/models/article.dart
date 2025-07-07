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

  Article({
    required this.id,
    required this.titre,
    this.auteur,
    this.nbre_commentaire,
    this.url,
    this.id_com,
    this.texte,
    this.commentaires = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      titre: json['title'] ?? 'pas de titre',
      auteur: json['by'],
      nbre_commentaire: json['descendants'],
      url: json['url'],
      id_com: (json['kids'] as List?)?.cast<int>(),
      texte: json['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'nbre_commentaire': nbre_commentaire,
      'url': url,
    };
  }
}
