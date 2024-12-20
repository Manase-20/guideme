import 'package:flutter/material.dart';
import 'dart:io'; // Menambahkan import untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:guideme/views/admin/gallery_management/create_gallery_screen.dart';
import 'package:guideme/views/admin/gallery_management/modify_gallery_screen.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_title.dart';

class GalleryManagementScreen extends StatefulWidget {
  const GalleryManagementScreen({super.key});

  @override
  _GalleryManagementScreenState createState() => _GalleryManagementScreenState();
}

class _GalleryManagementScreenState extends State<GalleryManagementScreen> {
  String page = 'gallery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery Management"),
      ),
      body: GalleryManagementScreenContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 4),
    );
  }
}

class GalleryManagementScreenContent extends StatelessWidget {
  final GalleryController _galleryController = GalleryController();

  GalleryManagementScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('galleries').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              Map<String, List<GalleryModel>> groupedByName = {};
              for (var doc in snapshot.data!.docs) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                GalleryModel galleryModel = GalleryModel.fromMap(data, doc.id);

                if (groupedByName[galleryModel.name] == null) {
                  groupedByName[galleryModel.name] = [];
                }
                groupedByName[galleryModel.name]!.add(galleryModel);
              }

              return Column(
                children: groupedByName.entries.map((entry) {
                  String name = entry.key;
                  List<GalleryModel> galleries = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          capitalizeEachWord(name),
                          style: AppTextStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: galleries.map((galleryModel) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 1 - 24,
                                child: Card(
                                  color: AppColors.backgroundColor,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                                        child: galleryModel.imageUrl.startsWith('/')
                                            ? Image.file(
                                                File(galleryModel.imageUrl),
                                                fit: BoxFit.cover,
                                                height: 150,
                                                width: double.infinity,
                                              )
                                            : Image.network(
                                                galleryModel.imageUrl,
                                                fit: BoxFit.cover,
                                                height: 150,
                                                width: double.infinity,
                                              ),
                                      ),
                                      SizedBox(height: 4),
                                      Center(
                                        child: Text(
                                          capitalizeEachWord(galleryModel.name),
                                          style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Menambahkan Row untuk posisi tombol Detail dan tombol Aksi
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Tombol Detail di pojok kiri
                                          TextButton(
                                            onPressed: () {
                                              // Menampilkan dialog dengan informasi lengkap
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor: AppColors.backgroundColor,
                                                    title: Text(capitalizeEachWord(galleryModel.name)),
                                                    content: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        // Menampilkan imageUrl sebagai teks
                                                        Text('Image URL: ${galleryModel.imageUrl}'),
                                                        SizedBox(height: 8),
                                                        Text('Category: ${galleryModel.category}'),
                                                        Text('Subcategory: ${galleryModel.subcategory}'),
                                                        Text('Uploaded At: ${galleryModel.createdAt.toDate()}'),
                                                      ],
                                                    ),
                                                    actions: [
                                                      SmallButton(
                                                        label: 'Close',
                                                        onPressed: () {
                                                          // Menutup dialog
                                                          Navigator.pop(context);
                                                        },
                                                      )
                                                    ],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'Detail',
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                            ),
                                          ),
                                          // Tombol Action di pojok kanan
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                EditButton(data: galleryModel, page: 'gallery'),
                                                SizedBox(width: 8),
                                                DeleteButton(
                                                  itemId: galleryModel.galleryId,
                                                  itemType: 'gallery',
                                                  controller: _galleryController,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 60),
        ],
      ),
    );

    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     Row(
    //       children: [
    //         CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
    //       ],
    //     ),
    //     SizedBox(
    //       height: 16,
    //     ),
    //     Expanded(
    //       child: StreamBuilder(
    //         stream: FirebaseFirestore.instance.collection('galleries').snapshots(),
    //         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

    //           // Mengelompokkan data berdasarkan nama
    //           Map<String, List<GalleryModel>> groupedByName = {};
    //           for (var doc in snapshot.data!.docs) {
    //             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //             GalleryModel galleryModel = GalleryModel.fromMap(data, doc.id);

    //             // Kelompokkan berdasarkan name
    //             if (groupedByName[galleryModel.name] == null) {
    //               groupedByName[galleryModel.name] = [];
    //             }
    //             groupedByName[galleryModel.name]!.add(galleryModel);
    //           }

    //           return Column(
    //             children: [
    //               Expanded(
    //                 child: ListView.builder(
    //                   padding: const EdgeInsets.only(bottom: 60.0), // Tambahkan jarak bawah
    //                   itemCount: groupedByName.entries.length,
    //                   itemBuilder: (context, index) {
    //                     var entry = groupedByName.entries.toList()[index];
    //                     String name = entry.key; // Mendapatkan name untuk judul grup
    //                     List<GalleryModel> galleries = entry.value;

    //                     return Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         // Judul untuk setiap grup berdasarkan name
    //                         Padding(
    //                           padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
    //                           child: Text(
    //                             capitalizeEachWord(name), // Menampilkan name sebagai title
    //                             style: AppTextStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
    //                           ),
    //                         ),
    //                         // Membuat SingleChildScrollView untuk menggulir horizontal
    //                         SingleChildScrollView(
    //                           scrollDirection: Axis.horizontal,
    //                           child: Row(
    //                             children: galleries.map((galleryModel) {
    //                               return Padding(
    //                                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
    //                                 child: SizedBox(
    //                                   width: MediaQuery.of(context).size.width * 1 - 24,
    //                                   child: Card(
    //                                     color: AppColors.backgroundColor,
    //                                     elevation: 3,
    //                                     shape: RoundedRectangleBorder(
    //                                       borderRadius: BorderRadius.circular(5),
    //                                     ),
    //                                     child: Column(
    //                                       children: [
    //                                         ClipRRect(
    //                                           borderRadius: BorderRadius.vertical(
    //                                             top: Radius.circular(5),
    //                                           ),
    //                                           child: galleryModel.imageUrl.startsWith('/')
    //                                               ? Image.file(
    //                                                   File(galleryModel.imageUrl),
    //                                                   fit: BoxFit.cover,
    //                                                   height: 150,
    //                                                   width: double.infinity,
    //                                                 )
    //                                               : Image.network(
    //                                                   galleryModel.imageUrl,
    //                                                   fit: BoxFit.cover,
    //                                                   height: 150,
    //                                                   width: double.infinity,
    //                                                 ),
    //                                         ),
    //                                         SizedBox(height: 4),
    //                                         Center(
    //                                           child: Text(
    //                                             capitalizeEachWord(galleryModel.name),
    //                                             style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold),
    //                                           ),
    //                                         ),
    //                                         // Menambahkan Row untuk posisi tombol Detail dan tombol Aksi
    //                                         Row(
    //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                           children: [
    //                                             // Tombol Detail di pojok kiri
    //                                             TextButton(
    //                                               onPressed: () {
    //                                                 // Menampilkan dialog dengan informasi lengkap
    //                                                 showDialog(
    //                                                   context: context,
    //                                                   builder: (BuildContext context) {
    //                                                     return AlertDialog(
    //                                                       backgroundColor: AppColors.backgroundColor,
    //                                                       title: Text(capitalizeEachWord(galleryModel.name)),
    //                                                       content: Column(
    //                                                         crossAxisAlignment: CrossAxisAlignment.start,
    //                                                         mainAxisSize: MainAxisSize.min,
    //                                                         children: [
    //                                                           // Menampilkan imageUrl sebagai teks
    //                                                           Text('Image URL: ${galleryModel.imageUrl}'),
    //                                                           SizedBox(height: 8),
    //                                                           Text('Category: ${galleryModel.category}'),
    //                                                           Text('Subcategory: ${galleryModel.subcategory}'),
    //                                                           Text('Uploaded At: ${galleryModel.createdAt.toDate()}'),
    //                                                         ],
    //                                                       ),
    //                                                       actions: [
    //                                                         SmallButton(
    //                                                           label: 'Close',
    //                                                           onPressed: () {
    //                                                             // Menutup dialog
    //                                                             Navigator.pop(context);
    //                                                           },
    //                                                         )
    //                                                       ],
    //                                                       shape: RoundedRectangleBorder(
    //                                                         borderRadius: BorderRadius.circular(5),
    //                                                       ),
    //                                                     );
    //                                                   },
    //                                                 );
    //                                               },
    //                                               child: Text(
    //                                                 'Detail',
    //                                                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    //                                               ),
    //                                             ),
    //                                             // Tombol Action di pojok kanan
    //                                             Padding(
    //                                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //                                               child: Row(
    //                                                 children: [
    //                                                   EditButton(data: galleryModel, page: 'gallery'),
    //                                                   SizedBox(width: 8),
    //                                                   DeleteButton(
    //                                                     itemId: galleryModel.galleryId,
    //                                                     itemType: 'gallery',
    //                                                     controller: _galleryController,
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                             )
    //                                           ],
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ),
    //                               );
    //                             }).toList(),
    //                           ),
    //                         ),
    //                         SizedBox(height: 16), // Spasi antar grup
    //                       ],
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ],
    //           );
    //         },
    //       ),
    //     ),
    //   ],
    // );
  }
}
