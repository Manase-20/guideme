import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/ticket_model.dart';

class TicketController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getTicketNames(String category, String subcategory) {
    var collectionName = category + 's';

    // switch (category) {
    //   case 'event':
    //     collectionName = 'events';
    //     break;
    //   case 'destination':
    //     collectionName = 'destinations';
    //     break;
    //   case 'restaurants':
    //     collectionName = 'restaurants';
    //     break;
    //   default:
    //     collectionName = 'defaultCollection';
    // }

    return _firestore.collection(collectionName).where('subcategory', isEqualTo: subcategory).snapshots().map((snapshot) {
      // print("Documents fetched: ${snapshot.docs.length}");
      snapshot.docs.forEach((doc) {
        // print("Document data: ${doc.data()}");
      });
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<Map<String, dynamic>?> getTicketData(String category, String name) async {
    try {
      // Ambil data berdasarkan kategori dan subkategori
      var collectionName = category + 's';
      var snapshot = await _firestore
          .collection(collectionName)
          // .where('subcategory', isEqualTo: subcategory)
          .where('name', isEqualTo: name)
          .get();

      // Cek apakah data ditemukan
      if (snapshot.docs.isNotEmpty) {
        // Ambil data pertama dari hasil pencarian
        var doc = snapshot.docs.first;
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching ticket data: $e');
    }
    return null;
  }

  Future<void> addTicket(TicketModel ticket) async {
    await _firestore.collection('tickets').add(ticket.toMap());
    // await docRef.update({'galleryId': docRef.id});
  }
}
