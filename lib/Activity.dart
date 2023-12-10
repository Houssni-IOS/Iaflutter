import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String id;
  String titre;
  String lieu;
  String categorie;
  String prix;
  int nbrPersonnes;
  String img;

  // Constructor
  Activity({
    required this.id,
    required this.titre,
    required this.lieu,
    required this.categorie,
    required this.prix,
    required this.nbrPersonnes,
    required this.img,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      titre: data['titre'] ?? '',
      lieu: data['lieu'] ?? '',
      categorie: data['categorie'] ?? '',
      prix: data['prix'] ?? '',
      nbrPersonnes: data['nbrPersonnes'] ?? 0,
      img: data['img'] ?? '',
    );
  }
}
