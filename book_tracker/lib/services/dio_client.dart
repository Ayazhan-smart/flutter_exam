import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.googleapis.com/books/v1';

  DioClient() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // Search books
  Future<Response> searchBooks(String query) async {
    try {
      final response = await _dio.get('/volumes', queryParameters: {
        'q': query,
        'maxResults': 20,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get book details by ID
  Future<Response> getBookDetails(String bookId) async {
    try {
      final response = await _dio.get('/volumes/$bookId');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
