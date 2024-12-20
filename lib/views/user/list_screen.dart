import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/widgets/custom_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:guideme/views/user/detail_screen.dart';

class ListScreen extends StatefulWidget {
  final String data;
  const ListScreen({super.key, required this.data});

  @override
  createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserController _userController = UserController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoggedIn = false;
  String _searchQuery = '';
  String collectionName = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    collectionName = widget.data.toLowerCase();
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // // Menangani logout
  // Future<void> _handleLogout() async {
  //   await _userController.logout(); // Pastikan logout dipanggil dari controller

  //   // Menampilkan SnackBar setelah logout berhasil
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Logout successful")),
  //   );

  //   // Navigasi ke halaman login setelah logout
  //   Navigator.pushReplacement(
  //     // ignore: use_build_context_synchronously
  //     context,
  //     MaterialPageRoute(builder: (context) => LoginScreen()),
  //   );
  // }

  // Fungsi untuk menangani perubahan pencarian
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: BackAppBar(title: 'Back'),
      // drawer: CustomSidebar(
      //   isLoggedIn: _isLoggedIn,
      //   onLogout: _handleLogout,
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 4,
            ),
            CustomTitle(firstText: 'Hi, Tourist!', secondText: "Discover the ${widget.data} We've Selected for You"),
            SizedBox(
              height: 16,
            ),
            SearchWidget(onSearchChanged: _onSearchChanged),
            SizedBox(
              height: 16,
            ),
            // List dari destinasi atau acara yang akan diambil dari Firestore
            StreamBuilder(
              stream: _searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection(collectionName).orderBy('createdAt', descending: true).snapshots()
                  : FirebaseFirestore.instance
                      .collection(collectionName)
                      .where('name', isGreaterThanOrEqualTo: _searchQuery)
                      .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                      .orderBy('name') // Cocok dengan kolom pencarian
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.builder(
                    shrinkWrap: true, // Agar GridView tidak memakan ruang lebih
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Dua card per baris
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      // childAspectRatio: 0.9,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      // Model sesuai dengan koleksi yang diterima
                      var dataModel;
                      if (collectionName == 'destinations') {
                        dataModel = DestinationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      } else if (collectionName == 'events') {
                        dataModel = EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(data: dataModel, collectionName: collectionName),
                            ),
                          );
                        },
                        child: Card(
                          color: AppColors.backgroundColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                                child: dataModel.imageUrl.startsWith('/')
                                    ? Image.file(
                                        File(dataModel.imageUrl),
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: double.infinity,
                                      )
                                    : Image.network(
                                        dataModel.imageUrl,
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: double.infinity,
                                      ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: Text(
                                      capitalizeEachWord(dataModel.name),
                                      style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(AppIcons.rating, size: 16),
                                      SizedBox(width: 2),
                                      Text(
                                        '${dataModel.rating}',
                                        style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    capitalizeEachWord(dataModel.location),
                                    style: AppTextStyles.smallStyle.copyWith(color: AppColors.secondaryColor),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${NumberFormat('#,##0', 'id_ID').format(dataModel.price)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // SmallButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => DetailScreen(data: dataModel),
                                  //         // builder: (context) => DetailScreen(data: collectionName, id: doc.id),
                                  //       ),
                                  //     );
                                  //   },
                                  //   label: 'View',
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 0),
    );
  }
}
