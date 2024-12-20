import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
// konstanta
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/models/category_model.dart';

class CustomSmallTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool? isDense;
  final int? maxLines;

  CustomSmallTextFormField({
    required this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.isDense,
    this.maxLines = 1, // Default to 1 line, can be set to more for textarea
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primaryColor, // Anda bisa mengganti dengan warna yang diinginkan
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: AppTextStyles.smallStyle.copyWith(color: AppColors.secondaryColor),
        labelStyle: AppTextStyles.mediumStyle,
        isDense: isDense ?? true, // Ukuran kotak lebih kecil
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor, // Warna border saat fokus
            width: 2.0, // Menambahkan ketebalan border
          ),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
      maxLines: maxLines, // Set maxLines to allow for textarea
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String)? onChanged; // Tambahkan onChanged untuk menangani perubahan
  final String? hint; // Tambahkan hint sebagai parameter opsional

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.onChanged, // Menambahkan parameter onChanged
    this.hint, // Menambahkan parameter hint
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.only(bottom: 8),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: AppColors.primaryColor,
            ),
          ),
          hintText: hint ?? 'Enter your data here...', // Menambahkan hint
          hintStyle: AppTextStyles.mediumStyle.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.normal)),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged, // Menghubungkan onChanged ke widget TextFormField
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value; // Parameter untuk menampilkan nilai yang dipilih
  final String? Function(String?)? validator; // Validator opsional
  final ValueChanged<String?>? onChanged; // Fungsi callback untuk menangani perubahan nilai dropdown
  final String? hint;
  final bool? enabled;
  // final List<DropdownMenuItem<String>>? itemsDropdown;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    // this.itemsDropdown,
    this.value, // Menambahkan value untuk menampilkan pilihan yang sudah dipilih
    this.validator, // Validator opsional
    this.onChanged, // Menambahkan onChanged untuk menangani perubahan nilai
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // Menampilkan nilai yang dipilih
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ))
          .toList(),
      onChanged: enabled == true ? onChanged : null,
      hint: Text(hint ?? 'Select an option...', style: AppTextStyles.mediumStyle.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.normal)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textColor, // Sesuaikan dengan warna label
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
        contentPadding: const EdgeInsets.only(bottom: 8),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Border default
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primaryColor, // Border berubah warna saat fokus
          ),
        ),
      ),
      validator: validator, // Menambahkan validator di sini
    );
  }
}

class DropdownCategory extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;
  final List<CategoryModel> categories;
  final String label;
  final String? Function(String?)? validator;

  DropdownCategory({
    required this.selectedCategory,
    required this.onChanged,
    required this.categories,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: Text(
        'Select an category',
        style: AppTextStyles.mediumStyle.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.normal),
      ),
      value: selectedCategory,
      onChanged: onChanged,
      items: categories.map<DropdownMenuItem<String>>((CategoryModel category) {
        return DropdownMenuItem<String>(
          value: category.categoryId, // Menggunakan categoryId sebagai value
          child: Text(category.name), // Menampilkan name sebagai teks di dropdown
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black, // Sesuaikan dengan warna label
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
        contentPadding: const EdgeInsets.only(bottom: 8),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Border default
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.blue, // Border berubah warna saat fokus
          ),
        ),
      ),
      validator: validator, // Menambahkan validator di sini
    );
  }
}

class UploadImageWithPreview extends StatelessWidget {
  final String imageUrl; // Untuk menyimpan URL gambar yang dipilih
  final VoidCallback onPressed;

  const UploadImageWithPreview({
    super.key,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tombol Pilih Gambar
        UploadImageButton(
          onPressed: onPressed,
          label: 'Pick an image',
        ),
        SizedBox(height: 16), // Spacer di bawah tombol
        // Image Preview (Jika Gambar Tersedia)
        imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: onPressed, // Pilih gambar lagi saat gambar ditekan
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Sudut gambar melengkung
                  child: Container(
                    width: 200, // Lebar image
                    height: 200, // Tinggi image
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45, // Shadow untuk efek depth
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Image.file(
                      File(imageUrl), // Memuat gambar dari file
                      fit: BoxFit.cover, // Memastikan gambar penuh dalam kotak
                    ),
                  ),
                ),
              )
            : Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor, // Background abu-abu untuk preview kosong
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.image, // Ikon gambar jika belum ada gambar
                  size: 100,
                  color: AppColors.primaryColor,
                ),
              ),
        SizedBox(height: 16), // Spacer antara gambar dan tombol upload
      ],
    );
  }
}

class UploadImageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const UploadImageButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Warna latar belakang tombol hitam
        foregroundColor: Colors.white, // Warna teks putih
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Radius sudut tombol
        ),
      ),
      icon: Icon(
        Icons.upload_file, // Ikon untuk unggah
        color: Colors.white,
        size: 24, // Ukuran ikon
      ),
      label: Text(
        label, // Teks tombol
        style: TextStyle(fontSize: 16), // Ukuran font
      ),
    );
  }
}

class NewUploadImageWithPreview extends StatelessWidget {
  final File? imageFile; // Untuk menyimpan file gambar yang dipilih
  final String? imageUrl; // URL gambar yang akan ditampilkan jika tidak ada file
  final VoidCallback onPressed; // Fungsi untuk memilih gambar

  const NewUploadImageWithPreview({
    super.key,
    required this.imageFile,
    required this.onPressed,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tombol Pilih Gambar
        NewUploadImageButton(
          onPressed: onPressed,
          label: 'Pick an image',
        ),
        SizedBox(height: 8), // Spacer di bawah tombol
        // Image Preview (Jika Gambar Tersedia)
        imageFile != null || imageUrl != null
            ? GestureDetector(
                onTap: onPressed, // Pilih gambar lagi saat gambar ditekan
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5), // Sudut gambar melengkung
                  child: Container(
                    width: double.infinity, // Mengambil lebar penuh layar
                    height: 200, // Tinggi tetap untuk gambar
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiaryColor, // Shadow untuk efek depth
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: imageFile != null
                        ? Image.file(
                            imageFile!, // Memuat gambar dari file
                            fit: BoxFit.fitWidth, // Memastikan gambar menyesuaikan lebar tanpa cropping
                          )
                        : imageUrl != null
                            ? Image.network(
                                imageUrl!, // Ganti dengan URL gambar dari network
                                fit: BoxFit.fitWidth, // Memastikan gambar menyesuaikan lebar tanpa cropping
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error); // Menampilkan ikon error jika gagal memuat gambar
                                },
                              )
                            : Container(), // Jika tidak ada imageFile maupun imageUrl, kosong
                  ),
                ),
              )
            : Container(
                width: double.infinity, // Lebar penuh
                height: 200, // Tinggi tetap
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor, // Background abu-abu untuk preview kosong
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    AppIcons.gallery, // Ikon gambar jika belum ada gambar
                    size: 100,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
        SizedBox(height: 24), // Spacer antara gambar dan tombol upload
      ],
    );
  }
}

class NewUploadImageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const NewUploadImageButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Warna latar belakang tombol hitam
          foregroundColor: Colors.white, // Warna teks putih
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Radius sudut tombol
          ),
        ),
        icon: Icon(
          Icons.upload_file, // Ikon untuk unggah
          color: Colors.white,
          size: 16, // Ukuran ikon
        ),
        label: Text(label, // Teks tombol
            style: AppTextStyles.mediumStyle.copyWith(fontWeight: FontWeight.bold, color: AppColors.backgroundColor)),
      ),
    );
  }
}
