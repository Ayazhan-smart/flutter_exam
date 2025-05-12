import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

enum BookGenre {
  fiction,
  nonFiction,
  scienceFiction,
  mystery,
  romance,
  horror,
  biography,
  history,
  business,
  other
}

enum BookStatus {
  toRead,
  reading,
  completed,
  onHold,
  dropped
}

DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  } else if (value is String) {
    return DateTime.parse(value);
  } else if (value == null) {
    return DateTime.now();
  }
  throw FormatException('Invalid date format: $value');
}

@immutable
class Book extends Equatable {
  final String? id;
  final String title;
  final String author;
  final BookGenre genre;
  final BookStatus status;
  final String description;
  final String coverUrl;
  final double rating;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String userId;
  final double price;
  final int totalPages;
  final int currentPage;

  const Book({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    required this.description,
    required this.coverUrl,
    required this.rating,
    required this.addedAt,
    this.startedAt,
    this.completedAt,
    required this.userId,
    required this.price,
    required this.totalPages,
    required this.currentPage,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      genre: BookGenre.values.firstWhere(
        (g) => g.toString() == 'BookGenre.${map['genre'] as String? ?? 'other'}',
        orElse: () => BookGenre.other,
      ),
      status: BookStatus.values.firstWhere(
        (s) => s.toString() == 'BookStatus.${map['status'] as String? ?? 'toRead'}',
        orElse: () => BookStatus.toRead,
      ),
      description: map['description'] as String? ?? '',
      coverUrl: map['coverUrl'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      addedAt: _parseDateTime(map['addedAt'] ?? DateTime.now()),
      startedAt: map['startedAt'] != null ? _parseDateTime(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? _parseDateTime(map['completedAt']) : null,
      userId: map['userId'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      totalPages: map['totalPages'] as int? ?? 0,
      currentPage: map['currentPage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'genre': genre.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'coverUrl': coverUrl,
      'rating': rating,
      'addedAt': Timestamp.fromDate(addedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'userId': userId,
      'price': price,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    BookGenre? genre,
    BookStatus? status,
    String? description,
    String? coverUrl,
    double? rating,
    DateTime? addedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? userId,
    double? price,
    int? totalPages,
    int? currentPage,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      addedAt: addedAt ?? this.addedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      price: price ?? this.price,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        genre,
        status,
        description,
        coverUrl,
        rating,
        addedAt,
        startedAt,
        completedAt,
        userId,
        price,
        totalPages,
        currentPage,
      ];
}
