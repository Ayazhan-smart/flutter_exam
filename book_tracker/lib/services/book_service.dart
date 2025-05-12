import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_tracker/models/book.dart';
import 'package:uuid/uuid.dart';

class BookService {
  final SharedPreferences _prefs;
  final String _booksKey = 'books';
  final _uuid = const Uuid();

  BookService(this._prefs);

  Future<List<Book>> getBooks() async {
    try {
      final booksJson = _prefs.getStringList(_booksKey) ?? [];
      return booksJson.map((json) {
        try {
          final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;
          return Book.fromMap(data, data['id'] as String);
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing book: $e');
          return null;
        }
      }).whereType<Book>().toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting books: $e');
      return [];
    }
  }

  Future<Book?> getBookById(String id) async {
    try {
      final books = await getBooks();
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting book by id: $e');
      return null;
    }
  }

  Future<void> addBook(Book book) async {
    try {
      if (book.title.isEmpty || book.author.isEmpty) {
        throw ArgumentError('Book title and author cannot be empty');
      }

      final books = await getBooks();
      final newBook = book.copyWith(id: _uuid.v4());
      books.add(newBook);
      await _saveBooks(books);
    } catch (e) {
      // ignore: avoid_print
      print('Error adding book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      if (book.id == null) {
        throw ArgumentError('Book ID cannot be null for update');
      }

      final books = await getBooks();
      final index = books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        books[index] = book;
        await _saveBooks(books);
      } else {
        throw StateError('Book not found');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      final books = await getBooks();
      final initialLength = books.length;
      books.removeWhere((book) => book.id == bookId);
      
      if (books.length == initialLength) {
        throw StateError('Book not found');
      }
      
      await _saveBooks(books);
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting book: $e');
      rethrow;
    }
  }

  Future<void> _saveBooks(List<Book> books) async {
    try {
      final booksJson = books
          .map((book) => jsonEncode(book.toMap()))
          .toList();
      final success = await _prefs.setStringList(_booksKey, booksJson);
      
      if (!success) {
        throw StateError('Failed to save books');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error saving books: $e');
      rethrow;
    }
  }
}