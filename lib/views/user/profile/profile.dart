import 'package:flutter/material.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/auth/register_screen.dart';
import 'package:guideme/views/user/ticket/history_screen.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_divider.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_title.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoggedIn = false;

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
        child: Container(
          color: Colors.white,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TitlePage(title: 'Your Profile', subtitle: 'Log in to start planning your trip'),
              SizedBox(height: 16), // Space before the divider

              // Profile Logo with ListTile below
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section with avatar and name
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isLoading) {
                        return CircularProgressIndicator();
                      } else if (authProvider.isLoggedIn) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.secondaryColor,
                                  backgroundImage: authProvider.profilePicture != null
                                      ? NetworkImage(authProvider.profilePicture!)
                                      : AssetImage('assets/images/profile.jpg') as ImageProvider,
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authProvider.username ?? 'Guest',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      authProvider.email ?? 'guest@example.com',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.chevron_right)
                          ],
                        );
                      } else {
                        // Tampilan ketika belum login
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: ProfileButton(
                                label: 'Login',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: ProfileButton(
                                label: 'Register',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16), // Space after the divider
              Text(
                'Settings',
                style: AppTextStyles.bodyBold,
              ),
              SizedBox(height: 8), // Space after the divider

              ListTile(
                dense: true,
                leading: Icon(Icons.history),
                title: Text(
                  'History',
                  style: AppTextStyles.mediumStyle,
                ),
                trailing: Icon(Icons.chevron_right), // Chevron icon
                onTap: () async {
                  final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);

                  // Tunggu hingga data pengguna selesai diambil
                  await authProvider.fetchCurrentUser();

                  if (authProvider.isLoggedIn) {
                    if (authProvider.isUser) {
                      // Jika pengguna sudah login dengan role 'user', lanjutkan ke HistoryScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
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
              ),

              // ListTile(
              //   dense: true,
              //   leading: Icon(Icons.history),
              //   title: Text(
              //     'History',
              //     style: AppTextStyles.mediumStyle,
              //   ),
              //   trailing: Icon(Icons.chevron_right), // Chevron icon
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => HistoryScreen(),
              //       ),
              //     );
              //   },
              // ),
              greyDivider(),
              ListTile(
                dense: true,
                leading: Icon(Icons.language),
                title: Text(
                  'Languages',
                  style: AppTextStyles.mediumStyle,
                ),
                trailing: Icon(Icons.chevron_right), // Chevron icon
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>  ChooseLanguage(),
                  //   ),
                  // );
                },
              ),
              greyDivider(),
              ListTile(
                dense: true,
                leading: Icon(Icons.notifications),
                title: Text(
                  'Notification',
                  style: AppTextStyles.mediumStyle,
                ),
                trailing: Icon(Icons.chevron_right), // Chevron icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),
              greyDivider(),
              ListTile(
                dense: true,
                leading: Icon(Icons.question_mark),
                title: Text(
                  'Get Help',
                  style: AppTextStyles.mediumStyle,
                ),
                trailing: Icon(Icons.chevron_right), // Chevron icon
                onTap: () {
                  // Handle logout
                },
              ),
              greyDivider(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 4),
    );
  }
}
