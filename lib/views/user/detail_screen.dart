import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/review_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_text.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:guideme/widgets/custom_carousel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class RatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingSelected;

  RatingWidget({required this.initialRating, required this.onRatingSelected});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  // int _selectedRating = 0;
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = index + 1;
            });
            widget.onRatingSelected(_selectedRating);
          },
          child: Icon(
            AppIcons.rating,
            color: index < _selectedRating ? AppColors.primaryColor : AppColors.tertiaryColor,
            size: 20,
          ),
        );
      }),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final dynamic data;
  final String collectionName;

  const DetailScreen({Key? key, required this.data, required this.collectionName}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final MapController _mapController = MapController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController reviewController = TextEditingController();
  final EventController _eventController = EventController();
  final DestinationController _destinationController = DestinationController();

  // late String dataModel;
  late AuthProvider authProvider;
  late String collectionName;
  late String uid;
  late String name;
  late String customerName;
  late String location;
  late double rating;
  late int price;
  late String description;
  late String information;
  late double latitude;
  late double longitude;
  late String imageUrl;
  late String imageName;
  late List<String> images = [];

  var isMapExpanded = true;
  var targetLocation;
  var currentLocation;

  String review = '';
  int selectedRating = 0;

  @override
  void initState() {
    isMapExpanded = false;
    super.initState();
    collectionName = widget.collectionName;
    // Inisialisasi nilai collectionName
    name = capitalizeEachWord(widget.data.name.toString());
    location = capitalizeEachWord(widget.data.location.toString());
    rating = widget.data.rating;
    price = widget.data.price;
    description = widget.data.description;
    latitude = widget.data.latitude;
    longitude = widget.data.longitude;
    imageUrl = widget.data.imageUrl;
    targetLocation = LatLng(latitude, longitude);
    _loadImages();

    // Ambil nilai default dari Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    uid = authProvider.uid ?? 'not found';
    customerName = authProvider.username ?? 'not found';

    reviewController.addListener(() {
      setState(() {
        review = reviewController.text; // Perbarui nilai nameValue
      });
    });
  }

  Future<void> _loadImages() async {
    imageName = name.toLowerCase();
    final querySnapshot = await FirebaseFirestore.instance.collection('galleries').where('name', isEqualTo: imageName).get();

    List<String> loadedImages = [];
    for (var doc in querySnapshot.docs) {
      loadedImages.add(doc['imageUrl']);
    }

    // Menampilkan log untuk memastikan gambar yang didapat
    print("Loaded Images: $loadedImages");

    setState(() {
      images = loadedImages;
    });
  }

  Future<void> _openGoogleMaps() async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    final Uri googleMapsUri = Uri.parse(googleMapsUrl);

    // Periksa apakah URL dapat diluncurkan
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication, // Pastikan menggunakan aplikasi eksternal
      );
    } else {
      throw "Could not open Google Maps.";
    }
  }

  Future<void> saveReview() async {
    // if (_formKey.currentState!.validate()) {
    // Validasi form
    if (reviewController != 'not found' && selectedRating != 0) {
      print(review);
      ReviewModel dataReview = ReviewModel(
        uid: uid, // Replace with actual uid
        customerName: customerName, // Replace with actual customer name
        name: name.toLowerCase(),
        review: review,
        // category: 'category', // Replace with actual category
        // subcategory: 'subcategory', // Replace with actual subcategory
        rating: selectedRating.toDouble(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      try {
        // Memanggil fungsi addHistory untuk menyimpan event dan galeri ke Firestore
        await FirebaseFirestore.instance.collection('reviews').add(dataReview.toMap());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Review created successfully'),
        ));

        if (collectionName == 'destinations') {
          await _destinationController.updateDestination(
            widget.data, // Pastikan widget.data adalah tipe DestinationModel
            imageUrl, // Pastikan imageUrl adalah tipe String
            newRating: selectedRating.toDouble(), // Pastikan selectedRating adalah tipe double
          );
        } else if (collectionName == 'events') {
          await _eventController.updateEvent(
            widget.data, // Pastikan widget.data adalah tipe DestinationModel
            imageUrl, // Pastikan imageName adalah tipe String
            newRating: selectedRating.toDouble(), // Pastikan selectedRating adalah tipe double
          );
        }
        // Mengarahkan ke halaman DetailScreen dan mengganti halaman saat ini
        setState(() {
          rating = selectedRating.toDouble();
          reviewController.clear(); // Bersihkan reviewController
          selectedRating = 0; // Reset selectedRating
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create ticket: $e'),
        ));
      }
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please complete all fields'),
      ));
    }
  }

  Future<void> _updateAverageRating() async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance.collection('reviews').where('name', isEqualTo: name.toLowerCase()).get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += doc['rating'];
        }
        double averageRating = totalRating / reviewsSnapshot.docs.length;
        averageRating = double.parse(averageRating.toStringAsFixed(1)); // Round to 1 decimal place

        if (collectionName == 'destinations') {
          await _destinationController.updateDestination(
            widget.data,
            imageUrl,
            newRating: averageRating,
          );
        } else if (collectionName == 'events') {
          await _eventController.updateEvent(
            widget.data,
            imageUrl,
            newRating: averageRating,
          );
        }

        setState(() {
          rating = averageRating;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update average rating: $e'),
      ));
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: 'Back'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan teks menggunakan data
            CustomTitle(
              firstText: 'Hi, Tourist!',
              secondText: "Discover Everything About $name",
            ),
            const SizedBox(
              height: 16,
            ),
            if (images.isNotEmpty) DynamicCarouselWidget(imageAssets: images),
            if (images.isEmpty) Center(child: CircularProgressIndicator()), // Menampilkan carousel dengan gambar
            // Jika images kosong, bisa menampilkan widget loading atau lainnya
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: MainCard(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.subtitleBold,
                            ),
                            Row(
                              children: [
                                Icon(
                                  AppIcons.rating,
                                  size: 16,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '${widget.data.rating}',
                                  style: AppTextStyles.bodyBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              location,
                              style: AppTextStyles.mediumBold,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Start from',
                                  style: AppTextStyles.smallStyle,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(price)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        LimitedTextWidget(description: '${description}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: MainCard(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMapExpanded = !isMapExpanded;
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 4,
                          width: double.infinity,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(latitude, longitude),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Updated URL without subdomains
                              ),
                              if (targetLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: targetLocation!,
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        AppIcons.pin,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: AppColors.primaryColor, // Warna latar belakang
                        onPressed: () {
                          setState(() {
                            isMapExpanded = !isMapExpanded;
                          });
                        },
                        child: Icon(
                          isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: AppColors.backgroundColor, // Warna ikon
                        ),
                      ),
                    ),

                    // Tombol untuk membuka Google Maps
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _openGoogleMaps, // Panggil fungsi _openGoogleMaps
                        backgroundColor: AppColors.blueColor,
                        child: Icon(AppIcons.map, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20, // Ukuran avatar
                        backgroundImage: AssetImage('assets/images/profile.jpg'), // Memuat gambar dari assets
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSmallTextFormField(
                              controller: reviewController,
                              hintText: 'Write your review here',
                              maxLines: null, // Allow unlimited lines
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a review';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RatingWidget(
                                  initialRating: selectedRating,
                                  onRatingSelected: (rating) {
                                    setState(() {
                                      selectedRating = rating;
                                    });
                                    print('Rating yang dipilih: $rating $review $selectedRating');
                                  },
                                ),
                                SizedBox(width: 8),
                                //   IconSmallButton(
                                //     icon: Icons.send,
                                //     onPressed: saveReview,
                                //   ),
                                // SizedBox(width: 8),
                                IconSmallButton(
                                  icon: Icons.send,
                                  onPressed: () async {
                                    if (uid == 'not found' || customerName == 'not found' || uid.isEmpty || customerName.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Please log in to submit a review.'),
                                      ));
                                      await Future.delayed(Duration(seconds: 1));
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    final existingReview = await FirebaseFirestore.instance
                                        .collection('reviews')
                                        .where('name', isEqualTo: name.toLowerCase())
                                        .where('uid', isEqualTo: uid)
                                        .get();

                                    if (existingReview.docs.isEmpty) {
                                      await saveReview();
                                      await _updateAverageRating();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('You have already submitted a review.'),
                                      ));
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  // Container()
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('reviews').where('name', isEqualTo: name.toLowerCase()).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Please leave your review.'),
                        ));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var reviewData = snapshot.data!.docs[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(reviewData['uid']).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (userSnapshot.hasError) {
                                return Center(child: Text('Error: ${userSnapshot.error}'));
                              }
                              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                return Center(child: Text('User not found.'));
                              }

                              var userData = userSnapshot.data!;
                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 14, // Ukuran avatar lebih kecil
                                      backgroundImage: NetworkImage(userData['profilePicture'] ?? 'assets/images/profile.jpg'),
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData['username'] ?? 'Anonymous',
                                          style: AppTextStyles.mediumBold,
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(reviewData['createdAt'].toDate()),
                                          style: AppTextStyles.tinyStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              AppIcons.rating,
                                              color: starIndex < reviewData['rating'] ? AppColors.primaryColor : AppColors.tertiaryColor,
                                              size: 14,
                                            );
                                          }),
                                        ),
                                        SizedBox(height: 4),
                                        Text(reviewData['review'], style: AppTextStyles.smallStyle),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
