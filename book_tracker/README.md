# Book Tracker

A Flutter mobile application for tracking your reading progress and managing your book collection.

## Features

- Firebase Authentication (email + password)
- Book management with Firebase Firestore
- Push notifications via Firebase Cloud Messaging
- Multi-language support (English, Russian, Kazakh)
- Theme customization with local storage
- Book search using external API
- Beautiful animations and transitions
- Profile management

## Tech Stack

- Flutter & Dart
- BLoC Pattern for state management
- Firebase (Auth, Firestore, FCM)
- Retrofit for API integration
- SharedPreferences for local storage
- Custom animations
- Localization

## Project Structure

```
lib/
├── blocs/          # BLoC state management
├── components/     # Reusable UI components
├── config/         # App configuration
├── l10n/           # Localization files
├── models/         # Data models
├── screens/        # UI screens
├── services/       # API and Firebase services
└── utils/          # Helper functions and constants
```

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and add configuration files
4. Run the app:
   ```bash
   flutter run
   ```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
