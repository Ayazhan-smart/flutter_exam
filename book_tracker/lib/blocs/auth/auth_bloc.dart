import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_tracker/services/auth_service.dart';

// Events
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class SignIn extends AuthEvent {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
}

class SignUp extends AuthEvent {
  final String email;
  final String password;

  SignUp({required this.email, required this.password});
}

class SignOut extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;

  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignOut>(_onSignOut);

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      print('Auth state changed: ${user != null ? 'authenticated' : 'unauthenticated'}');
      if (user != null) {
        print('User authenticated: ${user.email}');
        add(CheckAuthStatus());
      } else {
        print('User is not authenticated');
        add(CheckAuthStatus());
      }
    });
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(SignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('Failed to sign in'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
    print('Starting sign up process...');
    emit(AuthLoading());
    try {
      print('Calling registerWithEmailAndPassword...');
      final user = await _authService.registerWithEmailAndPassword(
        event.email,
        event.password,
      );
      print('Registration result: ${user != null ? 'success' : 'failed'}');
      if (user != null) {
        print('User registered successfully: ${user.email}');
        emit(Authenticated(user));
      } else {
        print('Emitting AuthError: Failed to create account');
        emit(AuthError('Failed to create account'));
      }
    } catch (e) {
      print('Registration error: $e');
      final errorMessage = e.toString().contains('api-key-not-valid')
          ? 'Invalid API key. Please check your Firebase configuration.'
          : e.toString();
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    try {
      await _authService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }
}
