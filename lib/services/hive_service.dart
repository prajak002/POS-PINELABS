import 'package:hive_flutter/hive_flutter.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/transaction.dart';
import '../core/constants.dart';

class HiveService {
  // Menu operations
  static Future<void> saveMenuItem(MenuItem item) async {
    final box = await Hive.openBox<MenuItem>(AppConstants.menuBox);
    await box.put(item.menuId, item);
  }

  static Future<void> saveMenuItems(List<MenuItem> items) async {
    final box = await Hive.openBox<MenuItem>(AppConstants.menuBox);
    await box.clear();
    for (final item in items) {
      await box.put(item.menuId, item);
    }
  }

  static Future<List<MenuItem>> getAllMenuItems() async {
    final box = await Hive.openBox<MenuItem>(AppConstants.menuBox);
    return box.values.toList();
  }

  static Future<void> deleteMenuItem(String food, String vendorName) async {
    final box = await Hive.openBox<MenuItem>(AppConstants.menuBox);
    final itemsToDelete = box.values
        .where((item) => item.food == food && item.vendorName == vendorName)
        .toList();
    
    for (final item in itemsToDelete) {
      await box.delete(item.menuId);
    }
  }

  // Order operations
  static Future<void> saveOrder(Order order) async {
    final box = await Hive.openBox<Order>(AppConstants.ordersBox);
    await box.put(order.orderId, order);
  }

  static Future<List<Order>> getAllOrders() async {
    final box = await Hive.openBox<Order>(AppConstants.ordersBox);
    return box.values.toList();
  }

  static Future<List<Order>> getUnsyncedOrders() async {
    final box = await Hive.openBox<Order>(AppConstants.ordersBox);
    return box.values.where((order) => !order.isSync).toList();
  }

  static Future<void> markOrderAsSynced(String orderId) async {
    final box = await Hive.openBox<Order>(AppConstants.ordersBox);
    final order = box.get(orderId);
    if (order != null) {
      await box.put(orderId, order.copyWith(isSync: true));
    }
  }

  // Transaction operations (existing)
  static Future<void> saveTransaction(Transaction transaction) async {
    final box = await Hive.openBox<Transaction>(AppConstants.transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static Future<List<Transaction>> getAllTransactions() async {
    final box = await Hive.openBox<Transaction>(AppConstants.transactionsBox);
    return box.values.toList();
  }

  // Card operations (existing if needed)
  static Future<void> saveCardBalance(String cardUid, double balance) async {
    final box = await Hive.openBox(AppConstants.cardsBox);
    await box.put(cardUid, {
      'balance': balance,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  static Future<double?> getCardBalance(String cardUid) async {
    final box = await Hive.openBox(AppConstants.cardsBox);
    final cardData = box.get(cardUid);
    return cardData?['balance']?.toDouble();
  }

  // Sync operations
  static Future<void> syncOrdersToApi() async {
    try {
      final unsyncedOrders = await getUnsyncedOrders();
      
      for (final order in unsyncedOrders) {
        // Convert order to sync format and send to API
        final syncData = order.toSyncJson();
        // TODO: Call sync API
        print('Syncing order: ${order.orderId}');
        
        // Mark as synced
        await markOrderAsSynced(order.orderId);
      }
    } catch (e) {
      print('Error syncing orders: $e');
    }
  }
}
