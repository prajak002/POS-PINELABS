# EventPOS Flutter Application

Flutter POS application with dual user roles: topup_user and stall_user, integrated with Pine Labs for payment processing.

## Project Status
- [x] ✅ Clarify Project Requirements - Flutter POS app with Riverpod, Dio, SharedPreferences for JWT, Hive for persistence
- [x] ✅ Scaffold the Project - Flutter project created with proper folder structure
- [x] ✅ Customize the Project - Authentication system, routing, and basic dashboard implemented
- [x] ✅ Install Required Extensions - No specific extensions required for this project
- [x] ✅ Compile the Project - Dependencies installed and code generation completed
- [x] ✅ Create and Run Task - Flutter run task created and app launching
- [x] ✅ Launch the Project - App successfully launching on Chrome
- [x] ✅ Ensure Documentation is Complete - README updated with comprehensive documentation

## Tech Stack
- State Management: Riverpod
- Networking: Dio
- JWT Storage: SharedPreferences
- Local Persistence: Hive (transactions, card balances, menu cache)
- Excel Export: excel package
- Routing: GoRouter

## Features
- Dual role authentication (topup_user/stall_user)
- Card management with NFC
- Payment processing via Pine Labs
- Menu management for stalls
- Transaction tracking and sync
- Excel export functionality
- Offline support with sync

## Launch Instructions
1. Run `flutter pub get` to install dependencies
2. Run `dart run build_runner build` for code generation
3. Run `flutter run -d chrome` to launch on web
4. Use demo credentials: topup_user/password123 or stall_user/password123

## Next Steps
To continue development, implement the following features:
1. Issue New Card functionality in TopupDashboard
2. Top-up Card with Pine Labs integration
3. New Order flow in StallDashboard
4. Menu management with API integration
5. Transaction sync service
6. Excel export functionality
