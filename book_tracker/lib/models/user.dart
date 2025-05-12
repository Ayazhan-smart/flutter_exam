import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final int booksRead;
  final String? favoriteGenre;
  final DateTime joinedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.booksRead = 0,
    this.favoriteGenre,
    required this.joinedAt,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      bio: map['bio'],
      booksRead: map['booksRead'] ?? 0,
      favoriteGenre: map['favoriteGenre'],
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'booksRead': booksRead,
      'favoriteGenre': favoriteGenre,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  User copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    int? booksRead,
    String? favoriteGenre,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      booksRead: booksRead ?? this.booksRead,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      joinedAt: joinedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, avatarUrl, bio, booksRead, favoriteGenre, joinedAt];
}
