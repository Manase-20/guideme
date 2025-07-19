import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _createEventScreenState createState() => _createEventScreenState();
}

class _createEventScreenState extends State<CreateEventScreen> {
  final EventController _eventController = EventController();
  // final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();

  // Input field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController(text: '0.0');
  final TextEditingController _priceController = TextEditingController();

  // Waktu buka dan tutup
  Timestamp? _openingTime;
  Timestamp? _closingTime;

  String _imageUrl = '';
  bool _isMapExpanded = true;
  LatLng? _selectedLocation;
  String? _selectedCategory = 'event';
  String? _selectedSubcategory;
  String? selectedStatus;

  File? _imageFile;

  // mereset map setiap membuat halaman
  @override
  void initState() {
    super.initState();
    _isMapExpanded = false;
  }

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
    final name = _nameController.text;
    final category = _selectedCategory ?? 'uncategorized';

    final fileName = '${name}_${category}_${DateTime.now().millisecondsSinceEpoch}';
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
          saveEvent();
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

  Future<void> saveEvent() async {
    if (_formKey.currentState!.validate()) {
      // Validasi form
      if (_imageUrl.isNotEmpty && _openingTime != null && _closingTime != null && _selectedLocation != null && _selectedCategory != null && selectedStatus != null) {
        double _rating = double.tryParse(_ratingController.text) ?? 0.0;

        // Lanjutkan dengan menyimpan event
        EventModel dataEvent = EventModel(
          eventId: '',
          name: _nameController.text.toLowerCase(),
          location: _locationController.text.toLowerCase(),
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          imageUrl: _imageUrl,
          organizer: _organizerController.text.toLowerCase(),
          category: _selectedCategory!,
          subcategory: _selectedSubcategory!,
          description: _descriptionController.text,
          information: _informationController.text,
          rating: _rating,
          price: int.tryParse(_priceController.text) ?? 0,
          status: selectedStatus!,
          openingTime: _openingTime!,
          closingTime: _closingTime!,
          createdAt: Timestamp.now(),
        );

        try {
          // Memanggil fungsi addEvent untuk menyimpan event dan galeri ke Firestore
          await _eventController.addEvent(dataEvent, _imageUrl);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event created successfully'),
          ));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to create event: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please complete all fields and upload an image'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please complete all fields correctly'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: 'Back',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormTitle(firstText: 'Create Event', secondText: 'Design your data exactly you want it.'),
                // Nama Event
                TextForm(
                  controller: _nameController,
                  label: 'Event Name',
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                  onChanged: (value) {
                    _nameController.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _nameController.selection,
                    );
                  },
                ),
                SizedBox(height: 16),

                // lokasi Event
                TextForm(
                  controller: _locationController,
                  label: 'Event Location',
                  validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                  onChanged: (value) {
                    _locationController.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _locationController.selection,
                    );
                  },
                ),
                SizedBox(height: 16),

                // map
                MainCard(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMapExpanded = !_isMapExpanded;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 4,
                          width: double.infinity,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(1.1024563877808338, 104.03884839012828),
                              onTap: (_, point) {
                                setState(() {
                                  _selectedLocation = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Updated URL without subdomains
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_pin, color: Colors.red),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMapExpanded = !_isMapExpanded;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // organizer Event
                TextForm(
                  label: 'Event Organizer',
                  controller: _organizerController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Organizer is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _organizerController.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _organizerController.selection,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Dropdown untuk memilih category
                StreamBuilder<List<String>>(
                  stream: _categoryController.getCategories(), // Aliran kategori
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return TextDropdown(
                      label: 'Category',
                      items: ['event'], // Hanya memiliki satu item tetap
                      value: _selectedCategory, // Menampilkan nilai _selectedCategory
                      enabled: false, // Dropdown dapat dipilih (diubah)
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'event'; // Memperbarui _selectedCategory ketika ada perubahan
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16),

                // Dropdown untuk memilih subcategory berdasarkan kategori yang dipilih
                if (_selectedCategory != null)
                  StreamBuilder<List<String>>(
                    stream: _categoryController.getSubcategories(_selectedCategory!), // Ambil subcategories berdasarkan kategori
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return TextDropdown(
                        label: 'Subcategory',
                        items: snapshot.data!, // Menggunakan subcategories yang diterima
                        onChanged: (value) {
                          setState(() {
                            _selectedSubcategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a subcategory';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                SizedBox(height: _selectedCategory != null ? 16 : 0),

                // deskripsi Event

                TextArea(
                  controller: _descriptionController,
                  label: 'Event Description',
                  validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                ),
                SizedBox(height: 16),

                // informasi Event

                TextArea(
                  controller: _informationController,
                  label: 'Event Information',
                  validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
                ),
                SizedBox(height: 16),

                // price Event
                TextForm(
                  controller: _priceController,
                  label: 'Event Price',
                  keyboardType: TextInputType.number, // Hanya angka yang dapat dimasukkan
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Membatasi input hanya angka
                  ],
                  validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
                ),
                SizedBox(height: 16),

                TextDropdown(
                  label: 'Status',
                  items: ['open', 'close'],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                NewUploadImageWithPreview(
                  imageFile: _imageFile,
                  imageUrl: _imageUrl, // Gantilah dengan URL gambar yang dipilih
                  onPressed: _pickImage, // Fungsi untuk memilih gambar
                ),

                // Waktu Buka
                DateTimePicker(
                  title: 'Opening Date Time',
                  subtitle: _openingTime != null ? _openingTime!.toDate().toString() : 'Select opening time',
                  selectedTime: _openingTime, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _openingTime = selectedTime; // Mengupdate openingTimeNotifier
                    });
                  },
                ),

                SizedBox(height: 16),

                // Waktu Tutup
                DateTimePicker(
                  title: 'Closing Date Time',
                  subtitle: _closingTime != null ? _closingTime!.toDate().toString() : 'Select closing time',
                  selectedTime: _closingTime, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _closingTime = selectedTime; // Mengupdate closingTimeNotifier
                    });
                  },
                ),
                SizedBox(height: 60),

                // Tombol Simpan Event
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: MediumButton(
                //     onPressed: uploadImage, // Memanggil fungsi saveEvent ketika tombol ditekan
                //     label: 'Save',
                //   ),
                // ),
                // SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: uploadImage,
        label: 'Save Event',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 2),
    );
  }
}









































































































// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/category_controller.dart';
// import 'package:guideme/controllers/event_controller.dart';
// import 'package:guideme/controllers/gallery_controller.dart';
// import 'package:guideme/models/event_model.dart';
// import 'dart:io';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:guideme/widgets/custom_form.dart';
// import 'package:guideme/widgets/widgets.dart';
// import 'package:latlong2/latlong.dart';
// // import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

// class CreateEventScreen extends StatefulWidget {
//   const CreateEventScreen({super.key});

//   @override
//   _CreateEventScreenState createState() => _CreateEventScreenState();
// }

// // class NumberEditingController extends TextEditingController {
// //   int get number => int.tryParse(text) ?? 0;

// //   set number(int value) {
// //     text = value.toString();
// //   }
// // }

// class _CreateEventScreenState extends State<CreateEventScreen> {
//   final EventController _eventController = EventController();
//   final GalleryController _galleryController = GalleryController();
//   final CategoryController _categoryController = CategoryController();
//   final MapController _mapController = MapController();
//   final _formKey = GlobalKey<FormState>();

//   // Input field controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _organizerController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _informationController = TextEditingController();
//   final TextEditingController _ratingController = TextEditingController(text: '0.0');
//   final TextEditingController _priceController = TextEditingController();

//   // Waktu buka dan tutup
//   Timestamp? _openingTime;
//   Timestamp? _closingTime;

//   String _imageUrl = '';
//   bool _isMapExpanded = true;
//   LatLng? _selectedLocation;
//   String? selectedCategory;
//   String? selectedSubcategory;
//   String? selectedStatus;

//   // mereset map setiap membuat halaman
//   @override
//   void initState() {
//     super.initState();
//     _isMapExpanded = false;
//   }

//   // Fungsi untuk memilih gambar dan memperbarui UI
//   Future<void> _pickImage() async {
//     String? imagePath = await _galleryController.pickImage();
//     if (imagePath != null) {
//       setState(() {
//         _imageUrl = imagePath;
//       });
//     }
//   }

//   Future<void> saveEvent() async {
//     if (_formKey.currentState!.validate()) {
//       // Validasi form
//       if (_imageUrl.isNotEmpty && _openingTime != null && _closingTime != null && _selectedLocation != null) {
//         // Lanjutkan dengan menyimpan event
//         File imageFile = File(_imageUrl);
//         // String localImagePath = await _galleryController.saveImageLocally(imageFile);
//         double rating = double.tryParse(_ratingController.text) ?? 0.0;

//         EventModel newEvent = EventModel(
//           eventId: '',
//           name: _nameController.text.toLowerCase(),
//           location: _locationController.text.toLowerCase(),
//           latitude: _selectedLocation!.latitude,
//           longitude: _selectedLocation!.longitude,
//           imageUrl: 'localImagePath',
//           organizer: _organizerController.text.toLowerCase(),
//           category: selectedCategory!,
//           subcategory: selectedSubcategory!,
//           description: _descriptionController.text,
//           information: _informationController.text,
//           rating: rating,
//           price: int.tryParse(_priceController.text) ?? 0,
//           status: selectedStatus!,
//           openingTime: _openingTime!,
//           closingTime: _closingTime!,
//           createdAt: Timestamp.now(),
//         );

//         try {
//           // Memanggil fungsi addEvent untuk menyimpan event dan galeri ke Firestore
//           await _eventController.addEvent(newEvent, imageFile, 'localImagePath');

//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Event created successfully'),
//           ));
//           Navigator.pop(context);
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Failed to create event: $e'),
//           ));
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Please complete all fields and upload an image'),
//         ));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please complete all fields correctly'),
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BackAppBar(
//         title: 'Back',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Nama Event
//                 TextForm(
//                   controller: _nameController,
//                   label: 'Event Name',
//                   validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
//                   onChanged: (value) {
//                     _nameController.value = TextEditingValue(
//                       text: value.toLowerCase(),
//                       selection: _nameController.selection,
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // lokasi Event
//                 TextForm(
//                   controller: _locationController,
//                   label: 'Event Location',
//                   validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
//                   onChanged: (value) {
//                     _locationController.value = TextEditingValue(
//                       text: value.toLowerCase(),
//                       selection: _locationController.selection,
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // map
//                 Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _isMapExpanded = !_isMapExpanded;
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 300),
//                         height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 4,
//                         width: double.infinity,
//                         child: FlutterMap(
//                           mapController: _mapController,
//                           options: MapOptions(
//                             initialCenter: LatLng(1.054507, 104.004120),
//                             onTap: (_, point) {
//                               setState(() {
//                                 _selectedLocation = point;
//                               });
//                             },
//                           ),
//                           children: [
//                             TileLayer(
//                               urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Updated URL without subdomains
//                             ),
//                             if (_selectedLocation != null)
//                               MarkerLayer(
//                                 markers: [
//                                   Marker(
//                                     point: _selectedLocation!,
//                                     width: 40,
//                                     height: 40,
//                                     child: Icon(Icons.location_pin, color: Colors.red),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 10,
//                       right: 10,
//                       child: IconButton(
//                         icon: Icon(
//                           _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _isMapExpanded = !_isMapExpanded;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),

//                 // // preview gambar
//                 // _imageUrl.isNotEmpty
//                 //     ? Image.file(File(_imageUrl))
//                 //     : Container(),
//                 // SizedBox(height: 20),

//                 // // Pilihan Gambar
//                 // UploadImageButton(
//                 //   onPressed:
//                 //       _pickImage, // Ganti dengan fungsi untuk memilih gambar
//                 //   label: 'Pick an Image', // Teks tombol
//                 // ),
//                 // SizedBox(height: 20),

//                 // organizer Event
//                 TextForm(
//                   label: 'Event Organizer',
//                   controller: _organizerController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Organizer is required';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     _organizerController.value = TextEditingValue(
//                       text: value.toLowerCase(),
//                       selection: _organizerController.selection,
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Dropdown untuk memilih category
//                 StreamBuilder<List<String>>(
//                   stream: _categoryController.getCategories(), // Aliran kategori
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return CircularProgressIndicator();
//                     }
//                     return TextDropdown(
//                       label: 'Category',
//                       items: snapshot.data!, // Menggunakan data kategori yang diterima
//                       onChanged: (value) {
//                         setState(() {
//                           selectedCategory = value;
//                           selectedSubcategory = null; // Reset subcategory ketika kategori berubah
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a category';
//                         }
//                         return null;
//                       },
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Dropdown untuk memilih subcategory berdasarkan kategori yang dipilih
//                 if (selectedCategory != null)
//                   StreamBuilder<List<String>>(
//                     stream: _categoryController.getSubcategories(selectedCategory!), // Ambil subcategories berdasarkan kategori
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return CircularProgressIndicator();
//                       }
//                       return TextDropdown(
//                         label: 'Subcategory',
//                         items: snapshot.data!, // Menggunakan subcategories yang diterima
//                         onChanged: (value) {
//                           setState(() {
//                             selectedSubcategory = value;
//                           });
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select a subcategory';
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),
//                 SizedBox(height: 20),

//                 // deskripsi Event
//                 TextForm(
//                   controller: _descriptionController,
//                   label: 'Event Description',
//                   validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
//                 ),
//                 SizedBox(height: 20),

//                 // informasi Event
//                 TextForm(
//                   controller: _informationController,
//                   label: 'Event Information',
//                   validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
//                 ),
//                 SizedBox(height: 20),

//                 // rating Event
//                 // TextForm(
//                 //   controller: _ratingController,
//                 //   decoration: InputDecoration(label: 'Event Rating'),
//                 //   validator: (value) => value == null || value.isEmpty
//                 //       ? 'Rating is required'
//                 //       : null,
//                 // ),
//                 // SizedBox(height: 20),

//                 // price Event
//                 TextForm(
//                   controller: _priceController,
//                   label: 'Event Price',
//                   keyboardType: TextInputType.number, // Hanya angka yang dapat dimasukkan
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly, // Membatasi input hanya angka
//                   ],
//                   validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
//                 ),
//                 SizedBox(height: 20),

//                 TextDropdown(
//                   label: 'Status',
//                   items: ['open', 'close'],
//                   onChanged: (value) {
//                     setState(() {
//                       selectedStatus = value;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Status is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 UploadImageWithPreview(
//                   imageUrl: _imageUrl, // Gantilah dengan URL gambar yang dipilih
//                   onPressed: _pickImage, // Fungsi untuk memilih gambar
//                 ),

//                 // Waktu Buka
//                 ListTile(
//                   title: Text('Opening Time'),
//                   subtitle: Text(_openingTime != null ? _openingTime!.toDate().toString() : 'Select opening time'),
//                   trailing: Icon(Icons.access_time),
//                   onTap: () async {
//                     // Menampilkan DatePicker untuk memilih tanggal
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2101),
//                     );

//                     // Jika tanggal dipilih, lanjutkan memilih waktu
//                     if (selectedDate != null) {
//                       TimeOfDay? time = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );

//                       // Jika waktu dipilih, gabungkan dengan tanggal dan simpan
//                       if (time != null) {
//                         setState(() {
//                           _openingTime = Timestamp.fromDate(DateTime(
//                             selectedDate.year,
//                             selectedDate.month,
//                             selectedDate.day,
//                             time.hour,
//                             time.minute,
//                           ));
//                         });
//                       }
//                     }
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Waktu Tutup
//                 ListTile(
//                   title: Text('Closing Time'),
//                   subtitle: Text(_closingTime != null ? _closingTime!.toDate().toString() : 'Select closing time'),
//                   trailing: Icon(Icons.access_time),
//                   onTap: () async {
//                     // Menampilkan DatePicker untuk memilih tanggal
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2101),
//                     );

//                     // Jika tanggal dipilih, lanjutkan memilih waktu
//                     if (selectedDate != null) {
//                       TimeOfDay? time = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );

//                       // Jika waktu dipilih, gabungkan dengan tanggal dan simpan
//                       if (time != null) {
//                         setState(() {
//                           _closingTime = Timestamp.fromDate(DateTime(
//                             selectedDate.year,
//                             selectedDate.month,
//                             selectedDate.day,
//                             time.hour,
//                             time.minute,
//                           ));
//                         });
//                       }
//                     }
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Tombol Simpan Event
//                 LargeButton(
//                   onPressed: saveEvent, // Memanggil fungsi saveEvent ketika tombol ditekan
//                   label: 'Save Event',
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }










































