import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guideme/controllers/purchase_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/history_model.dart';
import 'package:guideme/views/user/ticket/history_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:guideme/core/services/midtrans_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatelessWidget {
  final String paymentUrl;
  const PaymentWebView({required this.paymentUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Deteksi jika user kembali atau pembayaran selesai
            if (request.url.contains('success') ||
                request.url.contains('finish') ||
                request.url.contains('cancel') ||
                request.url.contains('error')) {
              // Redirect ke home screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false, // Hapus semua route sebelumnya
              );

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            // Deteksi jika halaman selesai loading dan ada indikasi pembayaran selesai
            if (url.contains('success') || url.contains('finish')) {
              // Tampilkan snackbar sukses
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pembayaran berhasil!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Redirect ke home setelah delay
              Future.delayed(Duration(seconds: 2), () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
                );
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            // Jika user tutup WebView, redirect ke home
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final dynamic data;

  const PaymentScreen({super.key, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final PurchaseController _purchaseController = PurchaseController();

  late AuthProvider authProvider;
  late String ticketId;
  late String uid;
  late String name;
  late String organizer;
  late String location;
  late String imageUrl;
  late double rating;
  late String category;
  late String subcategory;
  late int price;
  late int stock;
  late Timestamp openingTime;
  late Timestamp closingTime;

  late String formattedOpeningDate; // Tambahkan variabel di sini
  late String formattedOpeningTime;
  late String formattedClosingDate;
  late String formattedClosingTime;

  TextEditingController quantityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int quantity = 1; // Tambahkan variabel quantity
  double totalPrice = 0.0;

  // String? _selectedOption = 'credit_card'; // Opsi default
  // String? _selectedCreditCard = null; // Opsi default
  // String? _selectedOption = null; // Opsi default
  String customerName = '';
  String customerEmail = '';
  // late TextEditingController nameController;
  // late TextEditingController emailController;

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    ticketId = widget.data.ticketId;
    name = widget.data.name;
    organizer = widget.data.organizer;
    location = widget.data.location;
    imageUrl = widget.data.imageUrl;
    category = widget.data.category;
    subcategory = widget.data.subcategory;
    rating = widget.data.rating;
    price = widget.data.price;
    stock = widget.data.stock;
    openingTime = widget.data.openingTime;
    closingTime = widget.data.closingTime;

    final DateTime openingDateTime = openingTime.toDate();
    final DateTime closingDateTime = closingTime.toDate();

    formattedOpeningDate = formatDate(openingDateTime);
    formattedOpeningTime = formatTime(openingDateTime);

    formattedClosingDate = formatDate(closingDateTime);
    formattedClosingTime = formatTime(closingDateTime);

    quantityController.text =
        quantity.toString(); // Set nilai awal untuk TextField
    calculateTotalPrice(); // Hitung total price saat pertama kali diinisialisasi

    // Ambil nilai default dari Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    uid = authProvider.uid ?? 'not found';
    customerName = authProvider.username ?? 'not found';
    customerEmail = authProvider.email ?? 'not found';

    // Inisialisasi TextEditingController dengan nilai default
    nameController = TextEditingController(text: customerName);
    emailController = TextEditingController(text: customerEmail);

    // Tambahkan listener ke nameController
    nameController.addListener(() {
      setState(() {
        customerName = nameController.text; // Perbarui nilai nameValue
      });
    });
    emailController.addListener(() {
      setState(() {
        customerEmail = emailController.text; // Perbarui nilai nameValue
      });
    });
  }

  // Fungsi untuk menghitung total harga
  void calculateTotalPrice() {
    setState(() {
      totalPrice = price * quantity.toDouble();
    });
  }

  void increaseQuantity() {
    if (quantity < stock) {
      setState(() {
        quantity++;
        quantityController.text = quantity.toString();
        calculateTotalPrice();
      });
    } else {
      null;
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        quantityController.text = quantity.toString();
        calculateTotalPrice();
      });
    }
  }

  void updateQuantity(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0 && newQuantity <= stock) {
      setState(() {
        quantity = newQuantity;
        quantityController.text = value;
        calculateTotalPrice();
      });
    } else {
      // Jika input tidak valid, kembalikan ke nilai terakhir yang valid
      quantityController.text = quantity.toString();
    }
  }

  Future<void> handlePurchase() async {
    setState(() {
      isProcessing = true;
    });
    try {
      String paymentUrl = await MidtransService().getPaymentLink(
        orderId: 'order${DateTime.now().millisecondsSinceEpoch}',
        amount: price * quantity,
        customerName: customerName,
        customerEmail: customerEmail,
      );
      setState(() {
        isProcessing = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(paymentUrl: paymentUrl),
        ),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan payment link: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Hapus listener dan bersihkan controller
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Image.network(
                                      imageUrl, // URL gambar
                                      width: 110, // Lebar mengikuti lebar layar
                                      height: 110, // Tinggi gambar
                                      fit: BoxFit
                                          .cover, // Menyesuaikan gambar agar sesuai kotak
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeEachWord(name),
                                    style: AppTextStyles.bodyBold,
                                    maxLines: 2, // Membatasi hanya dua baris
                                    overflow: TextOverflow
                                        .ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
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
                                        capitalizeEachWord(organizer),
                                        style: AppTextStyles.smallBold,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        AppIcons.pin,
                                        size: 12,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        capitalizeEachWord(location),
                                        style: AppTextStyles.smallStyle,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.date,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedOpeningDate,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.time,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedOpeningTime,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                formattedClosingDate,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                formattedClosingTime,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        formatRupiah(price),
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Purchase details',
                                    style: AppTextStyles.bodyBold,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      cursorColor: AppColors.primaryColor,
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        labelStyle: AppTextStyles.mediumBlack,
                                        isDense:
                                            true, // Ukuran kotak lebih kecil      isDense: isDense ?? true, // Ukuran kotak lebih kecil
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                8.0), // Mengatur padding konten agar lebih kecil
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors
                                                .primaryColor, // Warna border
                                            width:
                                                2.0, // Menambahkan ketebalan border
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(
                                            r'[a-zA-Z ]')), // Hanya huruf dan spasi
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null; // Input valid
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                children: [
                                  // Input Email
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: AppColors.primaryColor,
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: AppTextStyles.mediumBlack,
                                        isDense:
                                            true, // Ukuran kotak lebih kecil     isDense: isDense ?? true, // Ukuran kotak lebih kecil
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                8.0), // Mengatur padding konten agar lebih kecil
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors
                                                .primaryColor, // Warna border
                                            width:
                                                2.0, // Menambahkan ketebalan border
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(
                                            r'[a-zA-Z0-9@._-]')) // Hanya karakter yang sah untuk email
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an email address';
                                        }
                                        // Regex untuk email
                                        String pattern =
                                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
                                        RegExp regex = RegExp(pattern);
                                        if (!regex.hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null; // Valid email
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Spasi antar elemen
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantity:',
                                    style: AppTextStyles.mediumBlack,
                                  ),
                                  // const SizedBox(width: 16),
                                  // Quantity controls
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      // border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Tombol kurangi
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: quantity > 0
                                                  ? decreaseQuantity
                                                  : null, // Tombol hanya aktif jika quantity > 0
                                            ),
                                            SizedBox(
                                              width: 40,
                                              height: 30,
                                              child: Center(
                                                // alignment: Alignment.center,
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.primaryColor,
                                                  controller:
                                                      quantityController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  onChanged: updateQuantity,
                                                  style:
                                                      AppTextStyles.mediumBlack,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  decoration: InputDecoration(
                                                    // isDense: true,
                                                    border:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors
                                                            .primaryColor, // Warna border
                                                        width:
                                                            2.0, // Menambahkan ketebalan border
                                                      ),
                                                    ),
                                                    isDense:
                                                        true, // Ukuran kotak lebih kecil
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 4.0,
                                                            horizontal:
                                                                8.0), // Mengatur padding konten agar lebih kecil
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Tombol tambah
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: quantity < stock
                                                  ? increaseQuantity
                                                  : null, // Tombol hanya aktif jika quantity < stock
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Text(
                                            'Available stock: $stock',
                                            style: AppTextStyles.smallStyle
                                                .copyWith(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Price details',
                                    style: AppTextStyles.bodyBold,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8), // Spasi antar elemen
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${quantity} items',
                                        style: AppTextStyles.smallStyle,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${formatRupiah(totalPrice.toInt())}',
                                        style: AppTextStyles.smallStyle,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 8), // Spasi antar elemen
                              const Divider(
                                  thickness: 1,
                                  color: Colors.grey), // Divider below text
                              const SizedBox(height: 8), // Spasi antar elemen
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Total',
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${formatRupiah(totalPrice.toInt())}',
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Purchase summary',
                                    style: AppTextStyles.bodyBold,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Name:')],
                                      ),
                                      Column(
                                        children: [Text(customerName)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Email:')],
                                      ),
                                      Column(
                                        children: [Text(customerEmail)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Ticket Name:')],
                                      ),
                                      Column(
                                        children: [Text(name)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Organizer:')],
                                      ),
                                      Column(
                                        children: [Text(organizer)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Location:')],
                                      ),
                                      Column(
                                        children: [Text(location)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Date:')],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                              '${formattedOpeningDate} to ${formattedClosingDate}')
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Time:')],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                              '${formattedOpeningTime} to ${formattedClosingTime}')
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Ticket Price:')],
                                      ),
                                      Column(
                                        children: [
                                          Text('${formatRupiah(price)}')
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Quantity:')],
                                      ),
                                      Column(
                                        children: [Text('${quantity} items')],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                      thickness: 1,
                                      color: Colors.grey), // Divider below text
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Total:',
                                            style: AppTextStyles.mediumBold,
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${formatRupiah(totalPrice.toInt())}',
                                            style: AppTextStyles.mediumBold,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      MainCard(
                        child: // Button Purchase
                            LargeButton(
                          label: 'Purchase',
                          onPressed: () {
                            // Validasi Form
                            if (stock != 0) {
                              if (_formKey.currentState?.validate() == true) {
                                // Nonaktifkan validasi payment method dan modal lama
                                // if (_selectedCreditCard == null) {
                                //   DangerTopFloatingSnackBar.show(
                                //       context: context,
                                //       message: 'Please select a payment method.');
                                // } else {
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         backgroundColor: AppColors.backgroundColor,
                                //         contentPadding: EdgeInsets.all(8),
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //         ),
                                //         content: Container(
                                //           width: MediaQuery.of(context).size.width * 0.9,
                                //           child: PaymentFormModal(
                                //               totalPrice: totalPrice,
                                //               savePurchase: handlePurchase),
                                //         ),
                                //       );
                                //     },
                                //   );
                                // }
                                // Ganti dengan langsung panggil handlePurchase
                                handlePurchase();
                              } else {
                                DangerTopFloatingSnackBar.show(
                                    context: context,
                                    message:
                                        'Please fill in all required fields');
                              }
                            } else {
                              DangerFloatingSnackBar.show(
                                  context: context,
                                  message: 'Ticket out of stock.');
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 1),
    );
  }
}

class PaymentFormModal extends StatefulWidget {
  final double totalPrice; // Tambahkan parameter totalPrice
  final Function savePurchase;

  PaymentFormModal({required this.totalPrice, required this.savePurchase});
  // get totalPrice => totalPrice;

  @override
  _PaymentFormModalState createState() => _PaymentFormModalState();
}

class _PaymentFormModalState extends State<PaymentFormModal> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _grossAmountController = TextEditingController();

  // Formatter untuk memasukkan dash setiap 4 angka
  final TextInputFormatter _cardNumberFormatter =
      TextInputFormatter.withFunction(
    (oldValue, newValue) {
      String text = newValue.text;
      // Menghilangkan karakter non-numeric
      text = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Memformat dengan dash setelah setiap 4 digit
      String formattedText = '';
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && i % 4 == 0) {
          formattedText += '-';
        }
        formattedText += text[i];
      }

      // Mengembalikan nilai baru dengan format
      return newValue.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length));
    },
  );

  // URL backend
  final String url =
      'http://192.168.1.3:3000/process-payment'; // IP wifi // Ganti dengan IP dan port backend Anda
  // final String url = 'http://192.168.98.214:3000/process-payment'; // IP hospot fixcelt
  // final String url = 'http://192.168.74.17:3000/process-payment'; // IP hospot fixcelt

  late double totalPrice;
  // Tambahkan state untuk memantau status loading
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _grossAmountController.text =
        formatPrice(widget.totalPrice.toInt()); // Set nilai awal
    totalPrice = widget.totalPrice;
    // print(_grossAmountController.text);
  }

  // Fungsi untuk mengirimkan data ke backend
  Future<void> processPayment() async {
    final cardNumber = _cardNumberController.text;
    final expMonth = _expMonthController.text;
    final expYear = _expYearController.text;
    final cvv = _cvvController.text;
    final grossAmount = totalPrice;
    // final grossAmount = 1000000;

    if (cardNumber.isEmpty ||
        expMonth.isEmpty ||
        expYear.isEmpty ||
        cvv.isEmpty ||
        grossAmount == 0) {
      // Validasi input kosong
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() {
      isProcessing = true; // Menandakan bahwa proses sedang berlangsung
    });

    try {
      // Membuat data yang akan dikirim
      final Map<String, dynamic> data = {
        'card_number': cardNumber,
        'card_exp_month': expMonth,
        'card_exp_year': expYear,
        'card_cvv': cvv,
        'gross_amount': grossAmount,
      };

      // Mengirimkan data ke backend dengan POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data), // Mengirimkan data dalam format JSON
      );
      setState(() {
        isProcessing = false; // Menghentikan indikator loading setelah selesai
      });

      if (response.statusCode == 200) {
        // Jika berhasil
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment processed successfully')));
        widget.savePurchase();

        print('Payment processed successfully: $responseBody');
      } else {
        // Jika gagal
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to process payment')));
        print('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul
              Text(
                'Enter Credit Card',
                style: AppTextStyles.subtitleStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Card Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      prefixIcon: Icon(AppIcons.creditCard),
                      labelStyle: AppTextStyles.mediumBlack,
                      isDense: true, // Ukuran kotak lebih kecil
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor, // Warna border
                          width: 2.0, // Menambahkan ketebalan border
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      _cardNumberFormatter,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null; // Input valid
                    },
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Example: 5264-2210-3887-4659',
                    style: AppTextStyles.smallStyle
                        .copyWith(color: AppColors.secondaryColor),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Expiry Date and CVV Row
              Row(
                children: [
                  // Expiration Date
                  Expanded(
                    child: TextField(
                      controller: _expMonthController,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        labelText: 'MM',
                        hintText: 'Month',
                        hintStyle: AppTextStyles.bodyBlack.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor),
                        labelStyle: AppTextStyles.mediumBlack,
                        isDense: true, // Ukuran kotak lebih kecil
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryColor, // Warna border
                            width: 2.0, // Menambahkan ketebalan border
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _expYearController,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        labelText: 'YYYY',
                        hintText: 'Year',
                        hintStyle: AppTextStyles.bodyBlack.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor),
                        labelStyle: AppTextStyles.mediumBlack,
                        isDense: true, // Ukuran kotak lebih kecil
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryColor, // Warna border
                            width: 2.0, // Menambahkan ketebalan border
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        hintStyle: AppTextStyles.bodyBlack.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor),
                        labelStyle: AppTextStyles.mediumBlack,
                        isDense: true, // Ukuran kotak lebih kecil
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryColor, // Warna border
                            width: 2.0, // Menambahkan ketebalan border
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Gross Amount (Read Only)
              TextField(
                controller: _grossAmountController,
                decoration: InputDecoration(
                  labelText: 'Gross Amount',
                  labelStyle: AppTextStyles.mediumBlack,
                  isDense: true, // Ukuran kotak lebih kecil
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor, // Warna border
                      width: 2.0, // Menambahkan ketebalan border
                    ),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 25),

              // Process Payment Button
              isProcessing
                  ? LargeButton(
                      label: '', // Kosongkan label jika sedang loading
                      onPressed:
                          () {}, // Tidak melakukan apapun karena sedang memproses
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors
                              .backgroundColor, // Sesuaikan warna dengan aplikasi Anda
                        ),
                      ),
                    )
                  : LargeButton(
                      label: 'Purchase',
                      onPressed: () {
                        setState(() {
                          isProcessing =
                              true; // Mengubah status menjadi sedang proses
                        });
                        processPayment(); // Panggil fungsi processPayment saat tombol ditekan
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
