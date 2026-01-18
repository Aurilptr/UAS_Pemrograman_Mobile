# PAWMATE - Mobile Commerce Application for Pet Supplies

PAWMATE adalah aplikasi *mobile commerce* berbasis Android yang dikembangkan untuk mempermudah pengguna dalam melakukan pembelian kebutuhan hewan peliharaan secara *online*. Aplikasi ini dikembangkan sebagai tugas besar mata kuliah *Pemrograman Mobile* dengan menerapkan konsep *client-server* dan *RESTful API*.

Aplikasi PAWMATE menyediakan berbagai fitur utama seperti manajemen produk, keranjang belanja, proses pemesanan, serta integrasi *public API* untuk menampilkan fakta menarik seputar kucing (*Cat Facts*).

---

## 👨‍💻 Tim Pengembang

Project ini dikembangkan oleh:

- **Auril Putri Amanda**  
  NRP: 1502023023  

- **Rizky Aqil Hibatullah**  
  NRP: 152023052  

---

## 🎓 Tujuan Pengembangan

Aplikasi PAWMATE dikembangkan untuk:
- Memenuhi tugas besar mata kuliah *Pemrograman Mobile*
- Menerapkan konsep pengembangan aplikasi *mobile commerce*
- Mengimplementasikan integrasi *Client* dan *Admin*
- Memahami penggunaan *RESTful API* dalam aplikasi mobile

---

## 📱 Fitur Aplikasi

### 👤 Client (Pengguna)
- Registrasi dan login akun
- Melihat API Public mengenai fakta unik kucing
- Melihat daftar produk kebutuhan hewan peliharaan
- Melihat detail produk
- Menambahkan produk ke keranjang belanja
- Melakukan proses *checkout* dan pembayaran
- Melihat riwayat pesanan
- Tab Profil:
  - Melihat riwayat pesanan
  - Edit profil pengguna
  - Melihat halaman tentang aplikasi
  - Logout
- Halaman Cat Facts (integrasi *public API*)

### 🧑‍💼 Admin
- Login admin
- Dashboard admin
- Manajemen produk (*Create, Read, Update, Delete*)
- Manajemen pesanan
- Verifikasi pembayaran
- Melihat daftar pengguna
- Melihat laporan bisnis sederhana

---

## 🛠️ Teknologi yang Digunakan

### Frontend
- Bahasa Pemrograman: Dart
- *Framework*: Flutter
- UI Design: *Material Design*
- *State Management*: Stateful Widget
- HTTP Client: `http`

### Backend
- Bahasa Pemrograman: Python
- *Framework*: Flask
- Arsitektur: *RESTful API*

### Database
- MySQL

### API Eksternal
- *Public API*: Cat Facts API  
  (Digunakan langsung pada sisi frontend Flutter)

---

## 🏗️ Arsitektur Sistem

Aplikasi PAWMATE menggunakan arsitektur *client-server*:
- Flutter bertindak sebagai *client*
- Flask sebagai *backend server*
- MySQL sebagai database
- Frontend berkomunikasi dengan backend melalui *HTTP request* berbasis JSON
- Integrasi Cat Facts API dilakukan langsung oleh frontend

---

## 📌 Catatan

Project ini dibuat untuk keperluan akademik dan masih dapat dikembangkan lebih lanjut, seperti:
- Integrasi *payment gateway*
- Penambahan notifikasi *real-time*
- Peningkatan keamanan sistem
- Pengembangan versi iOS

---
