import 'package:flutter/material.dart';
// import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/constants.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSearchChanged;

  const SearchWidget({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        cursorColor: AppColors.primaryColor,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          labelText: 'Search...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            // borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryColor, // Warna border
              width: 2.0, // Menambahkan ketebalan border
            ),
          ),
          prefixIcon: Icon(AppIcons.searchBold),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

class buttonSearch extends StatefulWidget {
  final Function(String) onSearchChanged;

  const buttonSearch({super.key, required this.onSearchChanged});

  @override
  _buttonSearchState createState() => _buttonSearchState();
}

class _buttonSearchState extends State<buttonSearch> {
  bool _isSearchActive = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: _isSearchActive
          ? TextField(
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            )
          : IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchActive = true; // Menyembunyikan tombol pencarian dan menampilkan TextField
                });
              },
            ),
    );
  }
}

class SearchWidget2 extends StatelessWidget {
  final Function(String) onSearchChanged;

  const SearchWidget2({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        labelText: 'Search...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        prefixIcon: Icon(Icons.search),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }
}
