import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/ticket_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/ticket/payment_screen.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_search.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  String page = 'ticket';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final UserController _userController = UserController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoggedIn = false;
  String _searchQuery = '';

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

  // // Menangani logout
  // Future<void> _handleLogout() async {
  //   await _userController.logout(); // Pastikan logout dipanggil dari controller

  //   // Menampilkan SnackBar setelah logout berhasil
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Logout successful")),
  //   );

  //   // Navigasi ke halaman login setelah logout
  //   Navigator.pushReplacement(
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 4,
          ),
          CustomTitle(firstText: 'Hi, Tourist!', secondText: "Discover the Ticket We've Selected for You"),
          SizedBox(
            height: 16,
          ),
          SearchWidget(onSearchChanged: _onSearchChanged),
          SizedBox(
            height: 16,
          ),
          TicketScreenContent(
            searchQuery: _searchQuery,
          ),
        ],
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 1),
    );
  }
}

class TicketScreenContent extends StatelessWidget {
  final String searchQuery;
  TicketScreenContent({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      stream: searchQuery.isEmpty
          ? FirebaseFirestore.instance.collection('tickets').orderBy('createdAt', descending: true).snapshots()
          : FirebaseFirestore.instance
              .collection('tickets')
              .where('name', isGreaterThanOrEqualTo: searchQuery)
              .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
              .orderBy('name') // Cocok dengan kolom pencarian
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Pastikan data tidak null
        var docs = snapshot.data!.docs;
        return Expanded(
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              try {
                TicketModel ticket = TicketModel.fromMap(data, doc.id);

                String formattedDate = '';
                String formattedTime = '';
                if (ticket.openingTime != null) {
                  DateTime openingTime = ticket.openingTime!.toDate();

                  // Memformat tanggal
                  formattedDate = DateFormat('dd MMM yyyy').format(openingTime); // Contoh: 11 Jun 2024

                  // Memformat waktu
                  formattedTime = DateFormat('hh:mm a').format(openingTime); // Contoh: 07.00 PM
                }

                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 5,
                      color: AppColors.backgroundColor, // Background untuk card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.network(
                                    ticket.imageUrl ?? 'Image not found', // URL gambar
                                    width: 120, // Lebar mengikuti lebar layar
                                    height: 120, // Tinggi gambar
                                    fit: BoxFit.cover, // Menyesuaikan gambar agar sesuai kotak
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        capitalizeEachWord(ticket.name ?? 'Name not found'),
                                        style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2, // Membatasi hanya dua baris
                                        overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            AppIcons.rating,
                                            size: 12,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            '${ticket.rating}',
                                            style: AppTextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'organized by',
                                        style: AppTextStyles.smallStyle,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        capitalizeEachWord(ticket.organizer ?? 'Organizer not found'),
                                        style: AppTextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.date,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedDate,
                                                style: AppTextStyles.tinyStyle,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.time,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedTime,
                                                style: AppTextStyles.tinyStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.pin,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                capitalizeEachWord(ticket.location ?? ''),
                                                style: AppTextStyles.tinyStyle,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${formatRupiah(ticket.price ?? 0)}',
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Column(
                                  //   children: [
                                  //     Text(
                                  //       'Starts from',
                                  //       style: AppTextStyles.tinyStyle.copyWith(color: AppColors.secondaryColor),
                                  //     ),
                                  //   ],
                                  // ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [],
                                      ),
                                      Column(
                                        children: [
                                          SmallButton(
                                            onPressed: () async {
                                              final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);

                                              // Tunggu hingga data pengguna selesai diambil
                                              await authProvider.fetchCurrentUser();

                                              if (authProvider.isLoggedIn) {
                                                if (authProvider.isUser) {
                                                  // Jika pengguna sudah login dengan role 'user', lanjutkan ke PaymentScreen
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PaymentScreen(data: ticket),
                                                    ),
                                                  );
                                                } else {
                                                  // Jika role bukan 'user', tampilkan pesan atau arahkan ke halaman lain
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('You must be a user to access this page'),
                                                      duration: Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Jika pengguna belum login, tampilkan SnackBar dan arahkan ke LoginScreen
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('You must login first to access this page')),
                                                );

                                                // Setelah menampilkan SnackBar, arahkan ke halaman login
                                                Future.delayed(Duration(seconds: 1), () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginScreen(), // Ganti dengan LoginScreen Anda
                                                    ),
                                                  );
                                                });
                                              }
                                            },
                                            label: 'Purchase',
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } catch (e) {
                return Center(child: Text('Error parsing ticket data: $e'));
              }
            },
          ),
        );
      },
    );
  }
}
