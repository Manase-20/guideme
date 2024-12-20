import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/review_model.dart';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(ReviewModel dataReview) async {
    await _firestore.collection('reviews').add(dataReview.toMap());
  }

  // Future<void> updateEvent(ReviewModel event, String finalImageUrl) async {}
}
