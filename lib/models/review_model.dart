import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String uid;
  String customerName;
  String name;
  String review;
  // String? category;
  // String? subcategory;
  double rating;
  Timestamp createdAt;
  Timestamp? updatedAt;

  ReviewModel({
    required this.uid,
    required this.customerName,
    required this.name,
    required this.review,
    // this.category,
    // this.subcategory,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'customerName': customerName,
      'name': name,
      'review': review,
      // 'category': category,
      // 'subcategory': subcategory,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Membuat instance Event dari Map (data Firestore)
  factory ReviewModel.fromMap(Map<String, dynamic> map, String eventId) {
    return ReviewModel(
      uid: map['uid'],
      customerName: map['customerName'],
      name: map['name'],
      review: map['review'],
      // category: map['category'],
      // subcategory: map['subcategory'],
      rating: map['rating'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
