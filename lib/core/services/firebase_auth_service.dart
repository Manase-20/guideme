import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi login
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error during login: $e");
    }
    return null;
  }

  // Fungsi untuk mendapatkan pengguna yang sedang login
  Future<Map<String, String>?> getCurrentUser() async {
    // Mengambil user yang sedang login
    User? user = _auth.currentUser;

    if (user != null) {
      // Mengambil data pengguna berdasarkan UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Mengambil username dan role dari dokumen pengguna
        String username = userDoc['username'];
        String role = userDoc['role'];

        return {
          'username': username,
          'role': role,
        };
      } else {
        // Jika data pengguna tidak ada di Firestore
        return null;
      }
    } else {
      // Jika tidak ada pengguna yang login
      return null;
    }
  }
  // Future<User?> getCurrentUser() async {
  //   return _auth.currentUser; // Mengembalikan user jika sedang login
  // }

  // Mengecek status login pengguna
  Future<bool> isLoggedIn() async {
    var user = await getCurrentUser();
    return user != null;
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  // Fungsi register
  Future<UserModel?> registerUser(String email, String password, String username) async {
    try {
      // Mendaftarkan pengguna di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Menyimpan data pengguna ke Firestore dengan role dan tanggal pembuatan akun
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'role': 'user', // role default
          'profilePicture': 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
          'createdAt': Timestamp.now(), // Tanggal pembuatan akun
        });

        // Mengambil data pengguna dari Firestore dan mengonversinya menjadi UserModel
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print("Register failed: $e");
    }
    return null;
  }
}
