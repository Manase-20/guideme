import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/history_model.dart';

class PurchaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addHistory(HistoryModel dataPurchase) async {
        await _firestore.collection('histories').add(dataPurchase.toMap());
  }
}
