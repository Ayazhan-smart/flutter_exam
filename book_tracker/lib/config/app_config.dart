// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get googleBooksApiKey => dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';

  static const supportedLocales = ['en', 'ru', 'kk'];
  static const defaultLocale = 'en';

  static const animationDuration = Duration(milliseconds: 300);
  
  static const bottomNavItems = [
    'home',
    'search',
    'library',
    'profile',
  ];
}
