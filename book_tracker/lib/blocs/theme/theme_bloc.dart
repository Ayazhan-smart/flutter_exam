import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

// States
class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;
  static const _themeKey = 'isDarkMode';

  ThemeBloc(this._prefs) : super(ThemeState(isDarkMode: false)) {
    on<ToggleTheme>(_onToggleTheme);
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    if (_prefs.getBool(_themeKey) ?? false) {
      add(ToggleTheme());
    }
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final newIsDarkMode = !state.isDarkMode;
    _prefs.setBool(_themeKey, newIsDarkMode);
    emit(ThemeState(isDarkMode: newIsDarkMode));
  }
}
