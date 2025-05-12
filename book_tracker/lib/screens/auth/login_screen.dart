import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:book_tracker/blocs/auth/auth_bloc.dart';
import 'package:book_tracker/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:book_tracker/components/custom_button.dart';
import 'package:book_tracker/components/animated_widgets.dart';
import 'package:book_tracker/blocs/locale/locale_bloc.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Form validated successfully');
      final event = _isSignUp
          ? SignUp(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : SignIn(
              email: _emailController.text,
              password: _passwordController.text,
            );
      print('Submitting ${_isSignUp ? "SignUp" : "SignIn"} event');
      context.read<AuthBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('Auth state changed: $state');
          if (state is AuthError) {
            print('Auth error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            print('User authenticated, navigating to HomeScreen');
            // No need to navigate here as the main.dart BlocBuilder will handle it
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideAnimation(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Book Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: kTextLightColor,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: kTextDarkColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                          _isSignUp ? l10n.signUp : l10n.signIn,
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: kTextDarkColor,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        FadeSlideAnimation(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              filled: true,
                              // ignore: deprecated_member_use
                              fillColor: kBackgroundColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryColor),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.emailRequired;
                              }
                              if (!value.contains('@')) {
                                return l10n.invalidEmail;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideAnimation(
                          duration: const Duration(milliseconds: 700),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              filled: true,
                              // ignore: deprecated_member_use
                              fillColor: kBackgroundColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryColor),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        FadeSlideAnimation(
                          duration: const Duration(milliseconds: 900),
                          child: CustomButton(
                            onPressed: _submitForm,
                            text: _isSignUp ? l10n.signUp : l10n.signIn,
                            backgroundColor: kPrimaryColor,
                            textColor: kTextLightColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        FadeSlideAnimation(
                          duration: const Duration(milliseconds: 1100),
                          child: CustomButton(
                            onPressed: () {
                            
                            },
                            text: l10n.signInWithGoogle,
                            backgroundColor: kAccentColor,
                            textColor: kTextDarkColor,
                            icon: SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: Image.asset('assets/images/google_logo.jpg', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        FadeSlideAnimation(
                          duration: const Duration(milliseconds: 1300),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                            child: Text(
                              _isSignUp ? l10n.haveAccount : l10n.noAccount,
                              style: GoogleFonts.poppins(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: BlocBuilder<LocaleBloc, LocaleState>(
                            builder: (context, state) {
                              return PopupMenuButton<String>(
                                initialValue: state.locale.languageCode,
                                onSelected: (String code) {
                                  context.read<LocaleBloc>().add(ChangeLocale(code));
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state.locale.languageCode.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                                    ],
                                  ),
                                ),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'ru',
                                    child: Text(l10n.russian),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'en',
                                    child: Text(l10n.english),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'kk',
                                    child: Text(l10n.kazakh),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
