import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_tracker/models/user.dart';
import 'package:book_tracker/services/firestore_service.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

// Events
abstract class UserEvent {}

class LoadUser extends UserEvent {
  final String userId;
  LoadUser(this.userId);
}

class UpdateProfile extends UserEvent {
  final String name;
  final String? bio;
  UpdateProfile({required this.name, this.bio});
}

class UpdateAvatar extends UserEvent {
  final XFile image;
  UpdateAvatar(this.image);
}

// States
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreService _firestoreService;

  UserBloc(this._firestoreService) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateAvatar>(_onUpdateAvatar);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await _firestoreService.getUser(event.userId);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final updatedUser = currentState.user.copyWith(
        name: event.name,
        bio: event.bio,
      );
      
      emit(UserLoading());
      try {
        await _firestoreService.updateUser(updatedUser);
        emit(UserLoaded(updatedUser));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateAvatar(UpdateAvatar event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(UserLoading());
      try {
        final avatarUrl = await _firestoreService.uploadUserAvatar(event.image);
        final updatedUser = currentState.user.copyWith(avatarUrl: avatarUrl);
        await _firestoreService.updateUser(updatedUser);
        emit(UserLoaded(updatedUser));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }
}
