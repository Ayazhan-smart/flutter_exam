import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:book_tracker/firebase_options.dart';
import 'package:book_tracker/utils/constants.dart';
import 'package:book_tracker/blocs/auth/auth_bloc.dart';
import 'package:book_tracker/blocs/locale/locale_bloc.dart';
import 'package:book_tracker/screens/auth/login_screen.dart';
import 'package:book_tracker/screens/home/home_screen.dart';
import 'package:book_tracker/services/service_locator.dart';
import 'package:book_tracker/services/auth_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    print('Initializing services...');
    await ServiceLocator.init();
    print('Services initialized successfully');
    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(authService: ServiceLocator.get<AuthService>())),
          BlocProvider(create: (context) => LocaleBloc()),
        ],
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Book Tracker',
              theme: ThemeData(
                colorScheme: ColorScheme.light(
                  // ignore: deprecated_member_use
                  background: kBackgroundColor,
                  primary: kPrimaryColor,
                  secondary: kAccentColor,
                  surface: kTextLightColor,
                  onSurface: kTextDarkColor,
                ),
                useMaterial3: true,
                textTheme: GoogleFonts.poppinsTextTheme(),
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
                Locale('kk'),
              ],
              locale: state.locale,
              home: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  print('Main: Auth state changed to $state');
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  print('Main: Building UI for state $state');
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is Authenticated) {
                    print('Main: User is authenticated, showing HomeScreen');
                    return const HomeScreen();
                  }
                  print('Main: User is not authenticated, showing LoginScreen');
                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

