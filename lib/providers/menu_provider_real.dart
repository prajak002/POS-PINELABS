import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/menu_item_simple.dart';
import '../core/constants.dart';
import '../features/auth/auth_provider.dart';

// Menu Provider for stall functionality
final menuProviderReal = StateNotifierProvider<MenuNotifier, List<MenuItemSimple>>((ref) {
  return MenuNotifier(ref);
});

class MenuNotifier extends StateNotifier<List<MenuItemSimple>> {
  final Ref ref;

  MenuNotifier(this.ref) : super([]);

  // Load menu from API
  Future<void> loadMenu() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.jwtTokenKey);
      final username = prefs.getString(AppConstants.usernameKey) ?? 'stall_user';
      
      if (token == null) return;

      final apiClient = ref.read(apiClientProvider);
      final menuResponse = await apiClient.getMenu('Bearer $token');
      
      if (menuResponse.success) {
        final menuItems = menuResponse.data.map((item) => 
          item.toMenuItemSimple(
            username: username,
            vendorName: 'Default Vendor',
          )
        ).toList();
        
        state = menuItems;
      }
    } catch (e) {
      print('Error loading menu: $e');
      // Keep existing state on error
    }
  }

  // Add menu item
  Future<bool> addMenuItem(MenuItemSimple item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.jwtTokenKey);
      
      if (token == null) return false;

      final apiClient = ref.read(apiClientProvider);
      final newItem = await apiClient.addMenuItem(
        'Bearer $token',
        item.toApiJson(),
      );

      // Update local state
      state = [...state, newItem];
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String food, String vendorName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.jwtTokenKey);
      final username = prefs.getString(AppConstants.usernameKey);
      
      if (token == null || username == null) return false;

      final apiClient = ref.read(apiClientProvider);
      await apiClient.deleteMenuItem(
        'Bearer $token',
        {
          'username': username,
          'food': food,
          'vendor_name': vendorName,
        },
      );

      // Update local state
      state = state.where((item) => 
        !(item.food == food && item.vendorName == vendorName)
      ).toList();
      
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }
}

// Cart Provider for order management
final cartProviderReal = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItemSimple menuItem, {int quantity = 1}) {
    final existingIndex = state.indexWhere(
      (item) => item.menuItem.food == menuItem.food && 
                item.menuItem.vendorName == menuItem.vendorName
    );

    if (existingIndex >= 0) {
      // Update quantity if item exists
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = updatedItems;
    } else {
      // Add new item
      state = [...state, CartItem(menuItem: menuItem, quantity: quantity)];
    }
  }

  void removeItem(MenuItemSimple menuItem) {
    state = state.where((item) => 
      !(item.menuItem.food == menuItem.food && 
        item.menuItem.vendorName == menuItem.vendorName)
    ).toList();
  }

  void updateQuantity(MenuItemSimple menuItem, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItem);
      return;
    }

    final updatedItems = state.map((item) {
      if (item.menuItem.food == menuItem.food && 
          item.menuItem.vendorName == menuItem.vendorName) {
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
    return state.fold(0.0, (sum, item) => sum + (item.menuItem.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartItem {
  final MenuItemSimple menuItem;
  final int quantity;

  CartItem({
    required this.menuItem,
    required this.quantity,
  });

  CartItem copyWith({
    MenuItemSimple? menuItem,
    int? quantity,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => menuItem.price * quantity;
}
