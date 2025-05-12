import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_tracker/services/book_service.dart';
import 'package:book_tracker/services/auth_service.dart';


class ServiceLocator {
  static late final SharedPreferences _prefs;
  static late final BookService bookService;
  static late final AuthService authService;

  static Future<void> init() async {
    try {
      // Initialize shared preferences and services
      _prefs = await SharedPreferences.getInstance();
      bookService = BookService(_prefs);
      authService = AuthService();
    } catch (e) {
      print('Error initializing services: $e');
      rethrow;
    }
  }

  static T get<T>() {
    if (T == AuthService) {
      return authService as T;
    } else if (T == BookService) {
      return bookService as T;
    } else if (T == SharedPreferences) {
      return _prefs as T;
    }
    throw UnimplementedError('Service $T not found');
  }
}
