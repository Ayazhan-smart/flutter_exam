import 'package:flutter/material.dart';

// Colors
const kBackgroundColor = Color(0xFFA6CBCB); // Soft blue
const kAccentColor = Color(0xFFF7C942);    // Yellow
const kPrimaryColor = Color(0xFF006D6F);    // Teal
const kTextDarkColor = Color(0xFF333333);   // Dark text
const kTextLightColor = Color(0xFFFFFFFF);  // White text

// Padding
const kDefaultPadding = 20.0;
const kDefaultPaddingSmall = 10.0;

// Animation Duration
const kDefaultDuration = Duration(milliseconds: 300);

// API
const kGoogleBooksApiKey = 'YOUR_API_KEY';

// Firebase Collection Names
const kUsersCollection = 'users';
const kBooksCollection = 'books';

// SharedPreferences Keys
const kThemeModeKey = 'themeMode';
const kLanguageKey = 'language';

// Book Status
enum BookStatus {
  reading,
  completed,
  toRead,
}

// Routes
const String kHomeRoute = '/';
const String kLoginRoute = '/login';
const String kRegisterRoute = '/register';
const String kBookDetailRoute = '/book/:id';
const String kProfileRoute = '/profile';
