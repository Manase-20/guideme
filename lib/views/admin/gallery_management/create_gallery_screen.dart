// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/category_controller.dart';
// import 'package:guideme/controllers/gallery_controller.dart';
// import 'package:guideme/models/gallery_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:guideme/widgets/custom_form.dart';
// import 'package:guideme/widgets/custom_button.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

// class CreateGalleryManagementScreen extends StatefulWidget {
//   const CreateGalleryManagementScreen({super.key});

//   @override
//   _CreateGalleryManagementScreenState createState() => _CreateGalleryManagementScreenState();
// }

// class _CreateGalleryManagementScreenState extends State<CreateGalleryManagementScreen> {
//   final GalleryController _galleryController = GalleryController();
//   final CategoryController _categoryController = CategoryController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   String _imageUrl = '';
//   String? selectedCategory;
//   String? selectedSubcategory;

//   // Fungsi untuk memilih gambar dan memperbarui UI
//   Future<void> _pickImage() async {
//     String? imagePath = await _galleryController.pickImage();
//     if (imagePath != null) {
//       setState(() {
//         _imageUrl = imagePath;
//       });
//     }
//   }

//   // Fungsi untuk menyimpan galeri ke Firestore
//   Future<void> _saveGallery() async {
//     if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _imageUrl.isNotEmpty) {
//       File imageFile = File(_imageUrl);

//       // Menyimpan gambar secara lokal terlebih dahulu
//       String localImagePath = await _galleryController.saveImageLocally(imageFile);

//       // Membuat objek GalleryModel dengan path gambar lokal
//       GalleryModel newGallery = GalleryModel(
//         galleryId: '',
//         name: _nameController.text,
//         category: selectedCategory!,
//         subcategory: selectedSubcategory!,
//         description: _descriptionController.text,
//         imageUrl: localImagePath,
//         createdAt: Timestamp.now(),
//       );

//       // Menyimpan atau memperbarui galeri ke Firestore
//       await _galleryController.addGallery(newGallery);

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please fill all fields and upload an image.'),
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Create New Gallery')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               //nama galeri
//               CustomTextField(
//                 controller: _nameController,
//                 label: 'Name',
//               ),
//               SizedBox(height: 16),

//               // Dropdown untuk memilih category
//               StreamBuilder<List<String>>(
//                 stream: _categoryController.getCategories(), // Aliran kategori
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return CircularProgressIndicator();
//                   }
//                   return CustomDropdown(
//                     label: 'Category',
//                     items: snapshot.data!, // Menggunakan data kategori yang diterima
//                     onChanged: (value) {
//                       setState(() {
//                         selectedCategory = value;
//                         selectedSubcategory = null; // Reset subcategory ketika kategori berubah
//                       });
//                     },
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please select a category';
//                       }
//                       return null;
//                     },
//                   );
//                 },
//               ),
//               SizedBox(height: 16),

//               // Dropdown untuk memilih subcategory berdasarkan kategori yang dipilih
//               if (selectedCategory != null)
//                 StreamBuilder<List<String>>(
//                   stream: _categoryController.getSubcategories(selectedCategory!), // Ambil subcategories berdasarkan kategori
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return CircularProgressIndicator();
//                     }
//                     return CustomDropdown(
//                       label: 'Subcategory',
//                       items: snapshot.data!, // Menggunakan subcategories yang diterima
//                       onChanged: (value) {
//                         setState(() {
//                           selectedSubcategory = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a subcategory';
//                         }
//                         return null;
//                       },
//                     );
//                   },
//                 ),
//               SizedBox(height: 16),

//               //deskripsi galeri
//               CustomTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//               ),
//               SizedBox(height: 16),

//               // UploadImageWithPreview(
//               //   imageUrl: _imageUrl, // Gantilah dengan URL gambar yang dipilih
//               //   onPressed: _pickImage, // Fungsi untuk memilih gambar
//               // ),

//               // LargeButton(
//               //   onPressed: _saveGallery,
//               //   label: 'Save Gallery',
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateGalleryManagementScreen extends StatefulWidget {
  const CreateGalleryManagementScreen({super.key});

  @override
  _CreateGalleryManagementScreenState createState() => _CreateGalleryManagementScreenState();
}

class _CreateGalleryManagementScreenState extends State<CreateGalleryManagementScreen> {
  final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();
  // final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _imageUrl = ''; // Menyimpan URL gambar yang sudah diunggah
  String? selectedCategory;
  String? selectedName;
  String? selectedSubcategory;

  File? _imageFile;

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Menyimpan file gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Supabase
  Future uploadImage() async {
    if (_imageFile == null) return;

    // Ambil teks dari field 'name' dan buat format nama file
    final name = selectedName;
    final category = selectedCategory ?? 'uncategorized';

    // if (name.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please provide a name before uploading.')),
    //   );
    //   return;
    // }

    final fileName = '${name}_gallery_${category}_${DateTime.now().millisecondsSinceEpoch}';
    final path = 'uploads/$fileName';

    try {
      // Mengunggah gambar ke Supabase
      final uploadPath = await Supabase.instance.client.storage.from('images').upload(path, _imageFile!);

      if (uploadPath.isNotEmpty) {
        // Mendapatkan URL publik untuk gambar yang diunggah
        final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(path);

        if (publicUrl.isNotEmpty) {
          setState(() {
            _imageUrl = publicUrl; // Simpan URL publik ke variabel
          });

          // Simpan data galeri setelah berhasil mengunggah
          _saveGallery();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to retrieve public URL for the image.')),
          );
        }
      } else {
        throw Exception('Upload failed: No valid upload path returned.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $error')),
      );
    }
  }

  // Fungsi untuk menyimpan galeri ke Firestore
  Future<void> _saveGallery() async {
    if (selectedCategory == null || selectedSubcategory == null || selectedName == null || _descriptionController.text.isEmpty || _imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and upload an image.'),
      ));
      return;
    }

    GalleryModel dataGallery = GalleryModel(
      galleryId: '',
      name: selectedName!,
      category: selectedCategory!,
      subcategory: selectedSubcategory!,
      description: _descriptionController.text,
      imageUrl: _imageUrl,
      createdAt: Timestamp.now(),
    );

    await _galleryController.addGallery(dataGallery);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: ''),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormTitle(firstText: 'Create Gallery', secondText: 'Design your data exactly how you want it.'),
              // Dropdown untuk memilih kategori
              StreamBuilder<List<String>>(
                stream: _categoryController.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return CustomDropdown(
                    label: 'Category',
                    items: snapshot.data ?? [],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value; // Simpan kategori yang dipilih
                        selectedSubcategory = null; // Reset subkategori
                        selectedName = null; // Reset name
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              // Dropdown untuk memilih subkategori
              if (selectedCategory != null)
                StreamBuilder<List<String>>(
                  stream: _categoryController.getSubcategories(selectedCategory!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return CustomDropdown(
                      label: 'Subcategory',
                      items: snapshot.data ?? [],
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                          selectedName = null;
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: selectedCategory != null ? 16 : 0),

              // Dropdown untuk memuat dokumen berdasarkan kategori
              if (selectedCategory != null)
                StreamBuilder<List<String>>(
                  stream: _galleryController.getNamesByCategory(selectedCategory!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return CustomDropdown(
                      label: 'Name',
                      items: snapshot.data ?? [],
                      onChanged: (value) {
                        setState(() {
                          selectedName = value; // Simpan nama yang dipilih
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: selectedCategory != null ? 16 : 0),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter gallery description here...',
              ),
              SizedBox(height: 16),

              // Preview gambar dengan tombol untuk memilih gambar
              NewUploadImageWithPreview(
                imageFile: _imageFile, // Menampilkan preview gambar
                onPressed: _pickImage, // Pilih gambar
              ),

              Align(
                alignment: Alignment.bottomRight, // Memposisikan ke kanan bawah
                child: SmallButton(
                  onPressed: uploadImage, // Fungsi untuk mengunggah gambar
                  label: 'Upload',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
