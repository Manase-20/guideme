import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/views/user/detail_screen.dart';
import 'package:guideme/widgets/custom_carousel.dart';
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/views/auth/login_screen.dart';
// import 'package:guideme/core/services/midtrans_service.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/views/user/list_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoggedIn = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar gambar yang akan ditampilkan di carousel
    List<String> images = [
      'assets/images/carousel.jpeg',
      'assets/images/carousel2.jpeg',
      'assets/images/carousel3.jpeg',
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: BurgerAppBar(
        scaffoldKey: _scaffoldKey,
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    // Panggil handleLogout dari auth_utils.dart
                    handleLogout(context);
                  },
                ),
              ]
            : [],
      ),
      drawer: CustomSidebar(
        isLoggedIn: _isLoggedIn,
        onLogout: () {
          // Panggil handleLogout juga di sini
          handleLogout(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitle(
              firstText: 'Hi, Tourist!',
              secondText: 'Start Your Best Experience With GuideME',
            ),
            SizedBox(height: 16),
            CarouselWidget(imageAssets: images), // Memanggil widget carousel
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row yang ada di dalam Padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Destination',
                        style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Kirimkan nama koleksi (destinations atau events) ke ListScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                data: 'Destinations', // Contoh mengirim koleksi 'destinations'
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View all',
                          style: AppTextStyles.smallStyle.copyWith(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // StreamBuilder untuk event
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('destinations')
                      .orderBy('createdAt', descending: true) // Urutkan berdasarkan timestamp (waktu)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        height: 200, // Tinggi yang sesuai untuk daftar horizontal
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, // Scroll horizontal
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
                            DestinationModel dataDestination = DestinationModel.fromMap(event, doc.id);

                            return Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.44, // 50% dari lebar layar
                                  // margin: EdgeInsets.symmetric(horizontal: 8.0), // Margin antar card
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            data: dataDestination,
                                            collectionName: 'destinations',
                                          ),
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
                                              bottom: Radius.circular(5),
                                            ),
                                            child: dataDestination.imageUrl.startsWith('/')
                                                ? Image.file(
                                                    File(dataDestination.imageUrl),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  )
                                                : Image.network(
                                                    dataDestination.imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Membatasi nama agar hanya setengah lebar dan berpindah ke baris berikutnya jika panjang
                                              Flexible(
                                                flex: 3, // Membuat nama mengambil 3/4 dari lebar
                                                child: Text(
                                                  capitalizeEachWord(dataDestination.name),
                                                  style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                                  maxLines: 2, // Membatasi hanya dua baris
                                                  overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                                ),
                                              ),
                                              // Spacer(), // Menambahkan ruang agar rating tetap sejajar dengan nama
                                              // Menampilkan rating
                                              Row(
                                                children: [
                                                  Icon(
                                                    AppIcons.rating,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    '${dataDestination.rating}',
                                                    style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                capitalizeEachWord(dataDestination.location),
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
                                              // Menampilkan harga
                                              Text(
                                                'Rp ${NumberFormat('#,##0', 'id_ID').format(dataDestination.price)}',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              // SmallButton(
                                              //   onPressed: () {
                                              //     // Navigator.push(
                                              //     //   context,
                                              //     //   MaterialPageRoute(
                                              //     //     builder: (context) => DetailScreen(data: 'destinations', id: doc.id),
                                              //     //   ),
                                              //     // );
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder: (context) => DetailScreen(data: dataDestination),
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
                                  ),
                                ),
                                if (index < snapshot.data!.docs.length - 1) // Jangan tambahkan pada Card terakhir
                                  SizedBox(width: 4.0), // Jarak antar Card
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row yang ada di dalam Padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Event',
                        style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Kirimkan nama koleksi (destinations atau events) ke ListScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                data: 'Events', // Contoh mengirim koleksi 'destinations'
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View all',
                          style: AppTextStyles.smallStyle.copyWith(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // StreamBuilder untuk event
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .orderBy('createdAt', descending: true) // Urutkan berdasarkan timestamp (waktu)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        height: 200, // Tinggi yang sesuai untuk daftar horizontal
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, // Scroll horizontal
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
                            EventModel dataEvent = EventModel.fromMap(event, doc.id);

                            return Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.44,
                                  // margin: EdgeInsets.symmetric(horizontal: 8.0), // Margin antar card
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            data: dataEvent,
                                            collectionName: 'events',
                                          ),
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
                                              bottom: Radius.circular(5),
                                            ),
                                            child: dataEvent.imageUrl.startsWith('/')
                                                ? Image.file(
                                                    File(dataEvent.imageUrl),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  )
                                                : Image.network(
                                                    dataEvent.imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Membatasi nama agar hanya setengah lebar dan berpindah ke baris berikutnya jika panjang
                                              Flexible(
                                                flex: 3, // Membuat nama mengambil 3/4 dari lebar
                                                child: Text(
                                                  capitalizeEachWord(dataEvent.name),
                                                  style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                                  maxLines: 2, // Membatasi hanya dua baris
                                                  overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                                ),
                                              ),
                                              // Spacer(), // Menambahkan ruang agar rating tetap sejajar dengan nama
                                              // Menampilkan rating
                                              Row(
                                                children: [
                                                  Icon(
                                                    AppIcons.rating,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    '${dataEvent.rating}',
                                                    style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                capitalizeEachWord(dataEvent.location),
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
                                              // Menampilkan harga
                                              Text(
                                                'Rp ${NumberFormat('#,##0', 'id_ID').format(dataEvent.price)}',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              // SmallButton(
                                              //   onPressed: () {
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder: (context) => DetailScreen(data: dataEvent),
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
                                  ),
                                ),
                                if (index < snapshot.data!.docs.length - 1) // Jangan tambahkan pada Card terakhir
                                  SizedBox(width: 4.0), // Jarak antar Card
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.tertiaryColor, // Warna border
                      width: 1.0, // Ketebalan border
                    ),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made by PBL-IF 12',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'GuideME',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 0),
    );
  }
}
