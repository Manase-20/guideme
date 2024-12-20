import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/views/admin/destination_management/modify_destination_screen.dart';
import 'package:guideme/views/admin/event_management/create_event_screen.dart';
import 'package:guideme/views/admin/destination_management/create_destination_screen.dart';
import 'package:guideme/views/admin/category_management/create_category_screen.dart';
import 'package:guideme/views/admin/gallery_management/create_gallery_screen.dart';
import 'package:guideme/views/admin/event_management/modify_event_screen.dart';
import 'package:guideme/views/admin/gallery_management/modify_gallery_screen.dart';
import 'package:guideme/views/admin/ticket_management/create_ticket_screen.dart';

class AddButton extends StatelessWidget {
  final String page;
  const AddButton(this.page, {super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Logika berdasarkan nilai page
        if (page == 'event') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
        } else if (page == 'destination') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateDestinationScreen()),
          );
        } else if (page == 'category') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCategoryScreen()),
          );
        } else if (page == 'gallery') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateGalleryManagementScreen()),
          );
        } else if (page == 'ticket') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTicketManagementScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Page not recognized!")),
          );
        }
      },
      backgroundColor: const Color(0xFF007BFF),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  final dynamic data; // Gunakan dynamic agar bisa menerima berbagai tipe model
  final String page;

  const EditButton({Key? key, required this.data, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.0, // Tentukan lebar tombol
      height: 30.0, // Tentukan tinggi tombol
      child: FloatingActionButton(
        onPressed: () {
          // Logika berdasarkan nilai page
          if (page == 'event') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModifyEventScreen(eventModel: data),
              ),
            );
          } else if (page == 'destination') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModifyDestinationScreen(destinationModel: data),
              ),
            );
          } else if (page == 'gallery') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModifyGalleryManagementScreen(galleryModel: data),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Edit page not recognized!")),
            );
          }
        },
        backgroundColor: Color(0xFFFFCC00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Set corner radius
        ),
        child: Icon(
          AppIcons.modify,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final String itemId; // ID untuk item yang akan dihapus
  final String itemType; // Tipe data yang akan dihapus (event, destination, category, gallery)
  final dynamic controller;

  // Konstruktor menerima itemId, itemType, dan controller terkait
  DeleteButton({required this.itemId, required this.itemType, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.0,
      height: 30.0,
      child: FloatingActionButton(
        onPressed: () async {
          // Menampilkan dialog konfirmasi penghapusan
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Delete $itemType'),
                content: Text('Are you sure you want to delete this $itemType?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );

          // Jika user mengonfirmasi penghapusan, lakukan penghapusan berdasarkan tipe
          if (confirmDelete == true) {
            switch (itemType) {
              case 'event':
                await (controller as EventController).deleteEvent(itemId);
                break;
              case 'destination':
                await (controller as DestinationController).deleteDestination(itemId);
                break;
              case 'category':
                await (controller as CategoryController).deleteCategory(itemId);
                break;
              case 'gallery':
                await (controller as GalleryController).deleteGallery(itemId);
                break;
              default:
                // Jika tidak ada tipe yang cocok, tampilkan error
                print("Invalid item type");
            }
          }
        },
        backgroundColor: Color(0xFFFF3B30), // Warna merah untuk tombol delete
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;

  const SmallButton({
    super.key,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
          foregroundColor: AppColors.backgroundColor, // Mengatur warna teks tombol
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Padding untuk tombol lebih kecil
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
          ),
          // minimumSize: Size(60, 20), // Mengatur ukuran minimum tombol (lebar dan tinggi)
        ),
        child: Text(
          label!,
          style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold, color: AppColors.backgroundColor), // Ukuran teks pada tombol
        ),
      ),
    );
  }
}

class IconSmallButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;

  const IconSmallButton({
    super.key,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
          foregroundColor: AppColors.backgroundColor, // Mengatur warna teks tombol
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Padding untuk tombol lebih kecil
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
          ),
          // minimumSize: Size(60, 20), // Mengatur ukuran minimum tombol (lebar dan tinggi)
        ),
        child: Icon(
          icon,
          color: AppColors.backgroundColor, // Warna ikon
        ),
      ),
    );
  }
}

// class LargeButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;

//   const LargeButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
//         foregroundColor: AppColors.backgroundColor, // Mengatur warna teks tombol
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0), // Padding untuk tombol lebih besar
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
//         ),
//         minimumSize: Size(double.infinity, 50), // Tombol memenuhi lebar layar dan tinggi tertentu
//       ),
//       child: Text(
//         label,
//         style: AppTextStyles.largeButtonStyle, // Ukuran teks pada tombol
//       ),
//     );
//   }
// }

class LargeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Membuat onPressed opsional
  final Widget? child; // Tambahkan child opsional

  const LargeButton({
    super.key,
    required this.label,
    this.onPressed, // onPressed sekarang opsional
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {}, // Jika onPressed null, gunakan fungsi kosong
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
        foregroundColor: AppColors.backgroundColor, // Mengatur warna teks tombol
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0), // Padding untuk tombol lebih besar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
        ),
        minimumSize: Size(double.infinity, 50), // Tombol memenuhi lebar layar dan tinggi tertentu
      ),
      child: child ??
          Text(
            label,
            style: AppTextStyles.largeButtonStyle, // Ukuran teks pada tombol
          ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Membuat onPressed opsional
  final Widget? child; // Tambahkan child opsional

  const ProfileButton({
    super.key,
    required this.label,
    this.onPressed, // onPressed sekarang opsional
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {}, // Jika onPressed null, gunakan fungsi kosong
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
        foregroundColor: AppColors.backgroundColor, // Mengatur warna teks tombol
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0), // Padding untuk tombol lebih besar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
        ),
        minimumSize: Size(double.infinity, 50), // Tombol memenuhi lebar layar dan tinggi tertentu
      ),
      child: child ??
          Text(
            label,
            style: AppTextStyles.bodyBold, // Ukuran teks pada tombol
          ),
    );
  }
}
