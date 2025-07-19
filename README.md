Guide Me - Aplikasi Panduan Wisata Berbasis Mobile

Deskripsi Proyek

Guide Me adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu wisatawan, khususnya di Kota Batam, dalam menavigasi dan mengeksplorasi tempat wisata. Aplikasi ini menyediakan fitur pencarian destinasi, navigasi dengan Google Maps, pembelian tiket wisata secara online, dan penyajian informasi wisata yang lengkap dan akurat. Dengan antarmuka ramah pengguna serta fitur offline, Guide Me memberikan pengalaman berwisata yang praktis, informatif, dan menyenangkan.


✨ Fitur Utama

- Pencarian dan eksplorasi destinasi wisata
- Integrasi Google Maps untuk navigasi
- Pembelian tiket wisata secara online
- Ulasan dan penilaian destinasi
- Simpan destinasi favorit
- Akses informasi offline
- Aksesibilitas inklusif 
- Kolaborasi komunitas lokal
- Riwayat perjalanan & analitik pengguna


Teknologi yang Digunakan

- Flutter: UI Framework utama
- Dart: Bahasa pemrograman
- Firebase: Autentikasi & Firestore untuk basis data
- Midtrans: Gateway pembayaran
- Google Maps API: Layanan peta dan navigasi
- Firebase Storage: Penyimpanan gambar


Arsitektur Sistem

Modular & berbasis komponen, terdiri dari:

- Authentication: Login/Daftar pengguna
- Destination: Tampilan dan detail destinasi wisata
- Ticketing: Pemesanan dan pembelian tiket
- Cart: Keranjang tiket
- Transaction History: Riwayat transaksi
- Offline Access: Cache data destinasi
- Review System: Rating dan ulasan destinasi



Instalasi & Setup

1. Clone repository
   bash
   git clone https://github.com/username/guide-me.git
   cd guide-me
   
2.Install dependencies
  flutter pub get
  
3.Setup Firebase
  Tambahkan file google-services.json ke direktori android/app
  Tambahkan file GoogleService-Info.plist ke direktori ios/Runner

4.Run di emulator atau perangkat fisik
  flutter run

