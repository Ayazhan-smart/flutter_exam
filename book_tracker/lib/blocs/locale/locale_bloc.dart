import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class LocaleEvent {}

class ChangeLocale extends LocaleEvent {
  final String languageCode;
  ChangeLocale(this.languageCode);
}

// States
class LocaleState {
  final Locale locale;
  LocaleState(this.locale);
}

// Bloc
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleState(const Locale('ru'))) {
    on<ChangeLocale>((event, emit) {
      emit(LocaleState(Locale(event.languageCode)));
    });
  }
}
