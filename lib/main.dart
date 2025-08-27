import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'models/transaction.dart';
import 'models/menu_item_simple.dart';
import 'router.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionStatusAdapter());
  Hive.registerAdapter(CardDataAdapter());
  Hive.registerAdapter(MenuItemSimpleAdapter());

  // Open Hive boxes
  await Hive.openBox<Transaction>(HiveBoxes.transactions);
  await Hive.openBox<CardData>(HiveBoxes.cards);
  await Hive.openBox<MenuItemSimple>(HiveBoxes.menu);

  // Initialize AuthService
  await AuthService.instance.init();

  runApp(
    const ProviderScope(
      child: EventPOSApp(),
    ),
  );
}

class EventPOSApp extends ConsumerWidget {
  const EventPOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EventPOS',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
