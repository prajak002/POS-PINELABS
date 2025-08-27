import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../core/constants.dart';
import '../features/auth/auth_provider.dart';

// Menu Provider
final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier(ref);
});

class MenuNotifier extends StateNotifier<List<MenuItem>> {
  final Ref ref;

  MenuNotifier(this.ref) : super([]);

  Future<void> loadMenu() async {
    try {
      // First load from local Hive
      final localMenu = await HiveService.getAllMenuItems();
      state = localMenu;

      // Then sync with API
      await syncMenuFromApi();
    } catch (e) {
      print('Error loading menu: $e');
    }
  }

  Future<void> syncMenuFromApi() async {
    try {
      // TODO: Re-enable after API client menu methods are working
      print('Menu sync temporarily disabled - API methods being fixed');
      
      // Load from local storage for now
      final localMenu = await HiveService.getAllMenuItems();
      state = localMenu;
    } catch (e) {
      print('Error syncing menu from API: $e');
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    try {
      // TODO: Re-enable API call after fixing menu endpoints
      // For now, just save locally
      state = [...state, item];
      await HiveService.saveMenuItem(item);
      print('Menu item added locally (API call disabled)');
    } catch (e) {
      print('Error adding menu item: $e');
      rethrow;
    }
  }

  Future<void> deleteMenuItem(String food, String vendorName) async {
    try {
      // TODO: Re-enable API call after fixing menu endpoints
      // For now, just delete locally
      state = state.where((item) => !(item.food == food && item.vendorName == vendorName)).toList();
      await HiveService.deleteMenuItem(food, vendorName);
      print('Menu item deleted locally (API call disabled)');
    } catch (e) {
      print('Error deleting menu item: $e');
      rethrow;
    }
  }
}

// Cart Provider for order management
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartItem {
  final MenuItem menuItem;
  final int quantity;

  CartItem({required this.menuItem, required this.quantity});

  double get totalPrice => menuItem.price * quantity;

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem menuItem) {
    final existingIndex = state.indexWhere((item) => item.menuItem.menuId == menuItem.menuId);
    
    if (existingIndex >= 0) {
      // Increase quantity
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = updatedItems;
    } else {
      // Add new item
      state = [...state, CartItem(menuItem: menuItem, quantity: 1)];
    }
  }

  void removeItem(String menuId) {
    state = state.where((item) => item.menuItem.menuId != menuId).toList();
  }

  void updateQuantity(String menuId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuId);
      return;
    }

    final updatedItems = state.map((item) {
      if (item.menuItem.menuId == menuId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    
    state = updatedItems;
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0.0, (total, item) => total + item.totalPrice);
  }

  Order createOrder(String username) {
    final orderId = '${AppConstants.orderPrefix}${DateTime.now().millisecondsSinceEpoch}';
    
    final orderItems = state.map((cartItem) => OrderItem(
      menuId: cartItem.menuItem.menuId,
      foodName: cartItem.menuItem.food,
      price: cartItem.menuItem.price,
      quantity: cartItem.quantity,
      totalAmount: cartItem.totalPrice,
    )).toList();

    return Order(
      orderId: orderId,
      username: username,
      items: orderItems,
      totalAmount: totalAmount,
      timestamp: DateTime.now(),
    );
  }
}
