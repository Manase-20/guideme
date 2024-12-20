// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/home_controller.dart';
// import 'package:guideme/controllers/user_controller.dart';
// import 'package:guideme/views/auth/login_screen.dart';
// import 'package:guideme/widgets/custom_sidebar.dart';
// import 'package:guideme/widgets/widgets.dart';

// class GalleryScreen extends StatefulWidget {
//   const GalleryScreen({super.key});

//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final UserController _userController = UserController();
//   final HomeController _homeController = HomeController();

//   bool _isLoggedIn = false;

//   List<Map<String, dynamic>> galleries = [];

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//     _fetchGalleries();
//   }

//   // Memeriksa status login dan memperbarui state
//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await _homeController.isLoggedIn();
//     setState(() {
//       _isLoggedIn = loggedIn;
//     });
//   }

//   // Menangani logout
//   Future<void> _handleLogout() async {
//     await _userController.logout(); // Pastikan logout dipanggil dari controller

//     // Menampilkan SnackBar setelah logout berhasil
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Logout successful")),
//     );

//     // Navigasi ke halaman login setelah logout
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }

//   Future<void> _fetchGalleries() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('galleries').get();
//     setState(() {
//       galleries = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//     });
//   }

//   // Function to show the image in a full-screen modal
//   void _showImageModal(BuildContext context, String imagePath) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(10),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context); // Close the modal when tapped
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20.0),
//                 color: Colors.black,
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20.0),
//                 child: Image.asset(
//                   imagePath, // Load full-size image
//                   fit: BoxFit.contain, // Ensure the image is properly scaled
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const List<String> imagePaths = [
//       'assets/place_pictures/makam_abdul_jamal.jpg',
//       'assets/place_pictures/gpib_immanuel.jpg',
//       'assets/tickets/camp_vietnam.jpg',
//       'assets/place_pictures/makam_abdul_jamal/foto4.jpg',
//       'assets/tickets/ocarina.jpg',
//       'assets/place_pictures/makam_abdul_jamal/foto2.jpg',
//       'assets/tickets/raviola.jpeg',
//       'assets/place_pictures/ayam_bakar_de_peri.png',
//       'assets/place_pictures/dino_gate.jpeg',
//     ];

//     const double imageHeight = 100.0; // Adjust height as needed

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: BurgerAppBar(
//         scaffoldKey: _scaffoldKey,
//         actions: _isLoggedIn
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.logout),
//                   tooltip: 'Logout',
//                   onPressed: _handleLogout,
//                 ),
//               ]
//             : [],
//       ),
//       drawer: CustomSidebar(
//         isLoggedIn: _isLoggedIn,
//         onLogout: _handleLogout,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           color: Colors.white,
//           alignment: Alignment.topLeft,
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomTitle2(
//                 firstText: 'Hi, Tourist!',
//                 secondText: 'Start Your Best Experience With GuideME',
//               ),
//               const SizedBox(height: 10),
//               // Filter Box
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal, // Enable horizontal scrolling
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     // Filter Button
//                     MouseRegion(
//                       cursor: SystemMouseCursors.click,
//                       child: GestureDetector(
//                         onTap: () {
//                           // Navigate to the filter page here
//                           // Navigator.push(context, MaterialPageRoute(builder: (context) => FilterPage()));
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 10, bottom: 10),
//                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(20.0),
//                             border: Border.all(color: Colors.black, width: 1),
//                           ),
//                           child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 10),

//                     // Beach Button
//                     MouseRegion(
//                       cursor: SystemMouseCursors.click,
//                       child: GestureDetector(
//                         onTap: () {
//                           // Define the action for the Beach button here
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 10, bottom: 10),
//                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20.0),
//                             border: Border.all(color: Colors.black, width: 1),
//                           ),
//                           child: const Text(
//                             'Beach',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 10),

//                     // Natural Attractions Button
//                     MouseRegion(
//                       cursor: SystemMouseCursors.click,
//                       child: GestureDetector(
//                         onTap: () {
//                           // Define the action for the Natural Attractions button here
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 10, bottom: 10),
//                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20.0),
//                             border: Border.all(color: Colors.black, width: 1),
//                           ),
//                           child: const Text(
//                             'Natural Attractions',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 10),

//                     // Historical Sites Button
//                     MouseRegion(
//                       cursor: SystemMouseCursors.click,
//                       child: GestureDetector(
//                         onTap: () {
//                           // Define the action for the Historical Sites button here
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 10, bottom: 10),
//                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20.0),
//                             border: Border.all(color: Colors.black, width: 1),
//                           ),
//                           child: const Text(
//                             'Historical Sites',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   const SizedBox(width: 1),
//                   Expanded(
//                     child: Container(
//                       height: 40,
//                       padding: const EdgeInsets.only(right: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30.0),
//                         border: Border.all(color: Colors.black, width: 1),
//                       ),
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           prefixIcon: Icon(Icons.search, size: 20),
//                           prefixIconConstraints: BoxConstraints(minHeight: 25, minWidth: 50),
//                           contentPadding: EdgeInsets.only(left: 20, right: 20),
//                           border: InputBorder.none,
//                           hintText: 'Search GuideMe...',
//                           hintStyle: TextStyle(fontSize: 14),
//                         ),
//                         onChanged: (text) {
//                           // Handle the user's input here
//                           ('Search query: $text');
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
//                 shrinkWrap: true, // Make GridView take only the required space
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3, // 3 images in each row
//                   childAspectRatio: 1, // Adjust aspect ratio for square images
//                 ),
//                 itemCount: imagePaths.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return GestureDetector(
//                     onTap: () {
//                       // Show modal with full image when tapped
//                       _showImageModal(context, imagePaths[index]);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(4.0), // Padding between images
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10.0),
//                         child: Image.asset(
//                           imagePaths[index], // Load image from the path
//                           fit: BoxFit.cover,
//                           height: imageHeight, // Set the height of each image
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 30),

//               const Center(
//                 child: Text(
//                   'Guide Me',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               const Center(
//                 child: Text(
//                   'Made by PBL-IF-12',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: UserBottomNavBar(selectedIndex: 3),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/home_controller.dart';
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/widgets/custom_search.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserController _userController = UserController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<Map<String, dynamic>> galleries = [];
  Map<String, List<Map<String, dynamic>>> groupedGalleries = {};

  bool _isLoggedIn = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchGalleries();
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

  // Fetch galleries from Firestore and group by 'name'
  Future<void> _fetchGalleries() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('galleries').get();

    setState(() {
      galleries = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Group galleries by 'name'
      groupedGalleries = {};
      for (var gallery in galleries) {
        String name = gallery['name'] ?? 'Unknown';
        if (!groupedGalleries.containsKey(name)) {
          groupedGalleries[name] = [];
        }
        groupedGalleries[name]?.add(gallery);
      }
    });
  }

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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              CustomTitle2(
                firstText: 'Hi, Tourist!',
                secondText: "Discover the Gallery We've Selected for You",
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SearchWidget2(onSearchChanged: _onSearchChanged),
              ),
              const SizedBox(height: 10),
              ..._buildGalleryRows(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 3),
    );
  }

// Fungsi untuk membangun baris galeri
  List<Widget> _buildGalleryRows() {
    Map<String, List<Map<String, dynamic>>> groupedGalleries = {};

    // Mengelompokkan gambar berdasarkan 'name'
    for (var gallery in galleries) {
      final name = capitalizeEachWord(gallery['name'] as String? ?? 'Unknown');
      if (!groupedGalleries.containsKey(name)) {
        groupedGalleries[name] = [];
      }
      groupedGalleries[name]!.add(gallery);
    }

    // Membuat widget List berdasarkan kelompok
    return groupedGalleries.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120, // Sesuaikan tinggi ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final imageUrl = entry.value[index]['imageUrl'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 100);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }
}
