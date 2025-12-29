import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- PALET WARNA PASTEL ---
const Color pastelBlue = Color(0xFFA7C7E7);   // Primary
const Color pastelPink = Color(0xFFF6B1C3);   // Accent 1 (Love/Promo)
const Color pastelGreen = Color(0xFFB7E4C7);  // Accent 2 (Success/Paid)
const Color pastelYellow = Color(0xFFFFF1A8); // Accent 3 (Pending/Warning)
const Color pastelOrange = Color(0xFFFFD6A5); // Accent 4 (Action/Completed)
const Color neutralWhite = Color(0xFFFAFAFA); // Background

// --- TEMA UTAMA ---
ThemeData pawmateTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: neutralWhite,
  primaryColor: pastelBlue,
  
  // Warna Utama (ColorScheme)
  colorScheme: ColorScheme.fromSeed(
    seedColor: pastelBlue,
    primary: pastelBlue,
    secondary: pastelPink,
    surface: Colors.white,
    background: neutralWhite,
  ),

  // Font Utama (Poppins biar modern)
  textTheme: GoogleFonts.poppinsTextTheme(),

  // Desain App Bar
  appBarTheme: AppBarTheme(
    backgroundColor: pastelBlue,
    foregroundColor: Colors.white, // Warna teks judul
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20, 
      fontWeight: FontWeight.bold,
      color: Colors.white
    ),
  ),

  // Desain Tombol (Elevated Button)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: pastelBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
  ),

  // Desain Input Teks
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: pastelBlue, width: 2),
    ),
  ),
);