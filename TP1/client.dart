import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Classe Produit similaire à celle du TD1
class Produit {
  String nom;
  double prix;
  int stock;
  String categorie;

  Produit(this.nom, this.prix, this.stock, this.categorie);

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prix': prix,
      'stock': stock,
      'categorie': categorie,
    };
  }

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      json['nom'],
      json['prix'] is int ? (json['prix'] as int).toDouble() : json['prix'],
      json['stock'],
      json['categorie'],
    );
  }

  void afficherDetails() {
    print("Produit: $nom | Prix: $prix DH | Stock: $stock | Catégorie: $categorie");
  }
}

// Classe pour représenter un élément de commande
class ElementCommande {
  String nom;
  int quantite;

  ElementCommande(this.nom, this.quantite);

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'quantite': quantite,
    };
  }
}

// Classe Commande similaire à celle du TD1
class Commande {
  int? id;
  List<ElementCommande> produits;
  double? total;
  String? date;

  Commande(this.produits);

  Map<String, dynamic> toJson() {
    return {
      'produits': produits.map((e) => e.toJson()).toList(),
    };
  }

  factory Commande.fromJson(Map<String, dynamic> json) {
    List<ElementCommande> produits = [];
    for (var item in json['produits']) {
      produits.add(ElementCommande(item['nom'], item['quantite']));
    }

    var commande = Commande(produits);
    commande.id = json['id'];
    commande.total = json['total'] is int ? (json['total'] as int).toDouble() : json['total'];
    commande.date = json['date'];
    return commande;
  }

  void afficherDetails() {
    print("Commande ID: $id | Date: $date");
    for (var element in produits) {
      print("${element.nom} x${element.quantite}");
    }
    print("Total: $total DH");
  }
}

// Récupérer tous les produits depuis l'API
Future<List<Produit>> getProducts(String baseUrl) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      List<Produit> products = [];
      
      for (var json in productsJson) {
        products.add(Produit.fromJson(json));
      }
      
      print('✅ Produits récupérés avec succès');
      return products;
    } else {
      print('❌ Erreur lors de la récupération des produits: ${response.statusCode}');
      throw Exception('Échec du chargement des produits');
    }
  } catch (e) {
    print('❌ Exception lors de la récupération des produits: $e');
    throw e;
  }
}

// Ajouter un nouveau produit via l'API
Future<bool> addProduct(String baseUrl, Produit produit) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(produit.toJson()),
    );

    if (response.statusCode == 201) {
      print('✅ Produit ajouté avec succès');
      return true;
    } else {
      print('❌ Erreur lors de l\'ajout du produit: ${response.statusCode}');
      print('Message d\'erreur: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Exception lors de l\'ajout du produit: $e');
    return false;
  }
}

// Récupérer toutes les commandes depuis l'API
Future<List<Commande>> getOrders(String baseUrl) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      List<dynamic> ordersJson = jsonDecode(response.body);
      List<Commande> orders = [];
      
      for (var json in ordersJson) {
        orders.add(Commande.fromJson(json));
      }
      
      print('✅ Commandes récupérées avec succès');
      return orders;
    } else {
      print('❌ Erreur lors de la récupération des commandes: ${response.statusCode}');
      throw Exception('Échec du chargement des commandes');
    }
  } catch (e) {
    print('❌ Exception lors de la récupération des commandes: $e');
    throw e;
  }
}

// Ajouter une nouvelle commande via l'API
Future<bool> addOrder(String baseUrl, Commande commande) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(commande.toJson()),
    );

    if (response.statusCode == 201) {
      print('✅ Commande créée avec succès');
      return true;
    } else {
      print('❌ Erreur lors de la création de la commande: ${response.statusCode}');
      print('Message d\'erreur: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Exception lors de la création de la commande: $e');
    return false;
  }
}

// Fonction principale pour tester toutes les fonctionnalités
void main() async {
  // URL de base du serveur API
  final String baseUrl = 'http://localhost:3000';
  
  try {
    // 1. Récupérer et afficher tous les produits
    print('\n=== RÉCUPÉRATION DES PRODUITS ===');
    List<Produit> products = await getProducts(baseUrl);
    for (var product in products) {
      product.afficherDetails();
    }
    
    // 2. Ajouter un nouveau produit
    print('\n=== AJOUT D\'UN NOUVEAU PRODUIT ===');
    Produit nouveauProduit = Produit('Casque Audio', 850.0, 15, 'Accessories');
    bool produitAjoute = await addProduct(baseUrl, nouveauProduit);
    
    if (produitAjoute) {
      // Vérifier que le produit a bien été ajouté
      products = await getProducts(baseUrl);
      print('\n=== PRODUITS APRÈS AJOUT ===');
      for (var product in products) {
        product.afficherDetails();
      }
    }
    
    // 3. Récupérer et afficher toutes les commandes
    print('\n=== RÉCUPÉRATION DES COMMANDES ===');
    List<Commande> orders = await getOrders(baseUrl);
    if (orders.isEmpty) {
      print('Aucune commande disponible.');
    } else {
      for (var order in orders) {
        order.afficherDetails();
      }
    }
    
    // 4. Créer une nouvelle commande
    print('\n=== CRÉATION D\'UNE NOUVELLE COMMANDE ===');
    Commande nouvelleCommande = Commande([
      ElementCommande('iPhone 13', 1),
      ElementCommande('AirPods', 2),
    ]);
    
    bool commandeAjoutee = await addOrder(baseUrl, nouvelleCommande);
    
    if (commandeAjoutee) {
      // Vérifier que la commande a bien été ajoutée
      orders = await getOrders(baseUrl);
      print('\n=== COMMANDES APRÈS AJOUT ===');
      for (var order in orders) {
        order.afficherDetails();
      }
      
      // Vérifier que les stocks ont été mis à jour
      print('\n=== STOCKS APRÈS COMMANDE ===');
      products = await getProducts(baseUrl);
      for (var product in products) {
        if (product.nom == 'iPhone 13' || product.nom == 'AirPods') {
          product.afficherDetails();
        }
      }
    }
    
  } catch (e) {
    print('❌ Erreur globale: $e');
  }
}
