import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_tracker/blocs/auth/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:book_tracker/components/animated_widgets.dart';
import 'package:book_tracker/screens/home/book_list_screen.dart';
import 'package:book_tracker/screens/home/profile_page.dart';
import 'package:book_tracker/blocs/user/user_bloc.dart';
import 'package:book_tracker/services/firestore_service.dart';
import 'package:book_tracker/blocs/book/book_bloc.dart';
import 'package:book_tracker/services/book_service.dart';
import 'package:book_tracker/services/service_locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FadeSlideAnimation(
          key: ValueKey<int>(_currentIndex),
          child: IndexedStack(
            index: _currentIndex,
            children: [
              BlocProvider(
                create: (context) => BookBloc(ServiceLocator.get<BookService>())..add(LoadBooks()),
                child: const BookListScreen(),
              ),
              Center(
                child: Text(
                  'Search Screen',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Center(
                child: Text(
                  'Add Book Screen',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              BlocProvider(
                create: (context) {
                  final authState = context.read<AuthBloc>().state;
                  final userBloc = UserBloc(FirestoreService());
                  if (authState is Authenticated) {
                    userBloc.add(LoadUser(authState.user.id));
                  }
                  return userBloc;
                },
                child: const ProfilePage(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.book),
            label: l10n.myBooks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add),
            label: l10n.addToLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
