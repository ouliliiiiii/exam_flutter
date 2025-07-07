class Commentaire {
  final int id;
  final String? auteur;
  final String? texte;
  final int? parentId;
  final List<int>? enfants_com;
  List<Commentaire> reponses;

  Commentaire({
    required this.id,
    this.auteur,
    this.texte,
    this.parentId,
    this.enfants_com,
    this.reponses = const [],
  });

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
      id: json['id'],
      auteur: json['by'],
      texte: json['text'],
      parentId: json['parent'],
      enfants_com: (json['kids'] as List?)?.cast<int>(),
    );
  }
}
