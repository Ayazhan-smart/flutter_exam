import 'dart:core';
// ignore: unnecessary_import
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of books for a specific user
  Stream<List<Book>> streamBooks(String userId) {
    return _db
        .collection('books')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final books = <Book>[];
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              final book = Book.fromMap(data, doc.id);
              books.add(book);
            } catch (e) {
              // ignore: avoid_print
              print('Error parsing book: $e');
            }
          }
          return books;
        }).handleError((error) {
          // ignore: avoid_print
          print('Error streaming books: $error');
          return <Book>[];
        });
  }

  // Get a single book by id
  Future<Book?> getBookById(String bookId, String userId) async {
    try {
      final doc = await _db.collection('books').doc(bookId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      if (data['userId'] != userId) return null;
      return Book.fromMap(data, doc.id);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting book: $e');
      return null;
    }
  }

  // Add a new book
  Future<void> addBook(Book book, String userId) async {
    try {
      if (book.title.isEmpty || book.author.isEmpty) {
        throw ArgumentError('Book title and author cannot be empty');
      }

      final docRef = await _db.collection('books').add(book.toMap());
      final updatedBook = book.copyWith(id: docRef.id);
      await docRef.update(updatedBook.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error adding book: $e');
      rethrow;
    }
  }

  // Update an existing book
  Future<void> updateBook(Book book, String userId) async {
    try {
      if (book.id == null) {
        throw ArgumentError('Book ID cannot be null for update');
      }

      if (book.title.isEmpty || book.author.isEmpty) {
        throw ArgumentError('Book title and author cannot be empty');
      }

      final docRef = _db.collection('books').doc(book.id!);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw StateError('Book not found');
      }

      await docRef.update(book.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error updating book: $e');
      rethrow;
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId, String userId) async {
    try {
      final docRef = _db.collection('books').doc(bookId);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw StateError('Book not found');
      }

      await docRef.delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting book: $e');
      rethrow;
    }
  }

  // Get all books for a user
  Future<List<Book>> getBooks(String userId) async {
    try {
      final snapshot = await _db
          .collection('books')
          .where('userId', isEqualTo: userId)
          .get();

      final books = <Book>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final book = Book.fromMap(data, doc.id);
          books.add(book);
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing book: $e');
        }
      }
      return books;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting books: $e');
      return [];
    }
  }

  // User-related methods
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return User.fromMap(doc.data()!, doc.id);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<String> uploadUserAvatar(XFile image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await ref.putData(
        await image.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading avatar: $e');
      rethrow;
    }
  }
}
