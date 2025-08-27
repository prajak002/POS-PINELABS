# eventpos

# EventPOS - Flutter POS Application

A Flutter-based Point of Sale (POS) application with dual user roles for event management. The app supports topup counters and stall counters with integrated Pine Labs payment processing.

## Features

### 🔐 Authentication
- JWT-based authentication stored in SharedPreferences
- Role-based access control (topup_user, stall_user)
- Automatic role-based navigation

### 💳 Topup Counter Features
- Issue new cards with initial balance
- Top-up existing cards
- Balance inquiry
- Transaction summary and export

### 🏪 Stall Counter Features
- Create food orders from menu
- Process payments using NFC cards
- Menu management (add/remove items)
- Sales summary and reporting

### 🔧 Technical Features
- **State Management**: Riverpod
- **Networking**: Dio with Retrofit
- **Local Storage**: Hive for transactions, menu, card data
- **JWT Handling**: SharedPreferences with automatic token management
- **Routing**: GoRouter with authentication guards
- **Export**: Excel export functionality
- **Offline Support**: Local-first with background sync

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run code generation**:
   ```bash
   dart run build_runner build
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Demo Credentials

- **Topup User**: `topup_user` / `password123`
- **Stall User**: `stall_user` / `password123`

## Architecture

The app follows a clean architecture with feature-based organization:

- `lib/core/` - Core configurations and themes
- `lib/features/` - Feature modules (auth, topup, stall, etc.)
- `lib/models/` - Data models with Hive and JSON serialization
- `lib/services/` - Business logic and API services

## Contributing

This is a demonstration Flutter POS application showcasing modern Flutter development practices with Riverpod, Hive, and Pine Labs integration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
