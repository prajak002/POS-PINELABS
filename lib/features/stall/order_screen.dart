import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/menu_provider_real.dart';
import '../../models/menu_item_simple.dart';
import '../../services/pine_labs_service.dart';
import '../topup/widgets/payment_method_dialog.dart';
import '../../core/constants.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Load menu when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProviderReal.notifier).loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuProviderReal);
    final cartState = ref.watch(cartProviderReal);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          if (cartState.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${cartState.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => _showCart(context),
            ),
        ],
      ),
      body: _buildMenuGrid(menuItems),
      floatingActionButton: cartState.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCart(context),
              icon: const Icon(Icons.shopping_cart),
              label: Text('Cart (${cartState.length})'),
            )
          : null,
    );
  }

  Widget _buildMenuGrid(List<MenuItemSimple> menuItems) {
    if (menuItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No menu items available'),
            Text('Add items from Menu Management'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _MenuItemCard(
          item: item,
          onTap: () => _addToCart(item),
        );
      },
    );
  }

  void _addToCart(MenuItemSimple item) {
    ref.read(cartProviderReal.notifier).addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.food} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CartBottomSheet(),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemSimple item;
  final VoidCallback onTap;

  const _MenuItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fastfood,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.food,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'By ${item.vendorName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${item.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProviderReal);
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.menuItem.price * item.quantity),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return _CartItemTile(cartItem: cartItem);
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : () => _processCheckout(context, ref, total),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, WidgetRef ref, double total) async {
    Navigator.pop(context); // Close cart bottom sheet
    
    showDialog(
      context: context,
      builder: (context) => PaymentMethodDialog(
        amount: total,
        onPaymentMethodSelected: (method) {
          Navigator.pop(context); // Close payment dialog
          _handlePayment(context, ref, method, total);
        },
      ),
    );
  }

  void _handlePayment(BuildContext context, WidgetRef ref, PaymentMethod method, double total) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final billingRefNo = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
  ResponseModel result;

      switch (method) {
        case PaymentMethod.card:
          result = await PineLabsService.doTransaction(
            paymentAmount: total,
            billingRefNo: billingRefNo,
            transactionType: PosTransactionType.card,
          );
          break;
        case PaymentMethod.upi:
          result = await PineLabsService.doUpiTransaction(
            amount: total,
            billingRefNo: billingRefNo,
          );
          break;
        case PaymentMethod.cash:
          result = await PineLabsService.doCashTransaction(
            amount: total,
            billingRefNo: billingRefNo,
          );
          break;
      }

      Navigator.pop(context); // Close loading dialog

  if (result.response.responseCode == 0) {
        // Clear cart and show success
        ref.read(cartProviderReal.notifier).clearCart();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ₹${total.toStringAsFixed(2)}'),
                Text('Method: ${method.name.toUpperCase()}'),
                if (result.detail?.billingRefNo != null)
                  Text('Transaction ID: ${result.detail?.billingRefNo}'),
                if (result.detail?.approvalCode != null)
                  Text('Approval Code: ${result.detail?.approvalCode}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  Navigator.pop(context); // Go back to dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
  _showErrorDialog(context, result.response.responseMsg);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(context, 'Payment error: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem cartItem;

  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.fastfood),
      ),
      title: Text(cartItem.menuItem.food),
      subtitle: Text('₹${cartItem.menuItem.price} each'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => ref.read(cartProviderReal.notifier).removeItem(cartItem.menuItem),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('${cartItem.quantity}'),
          IconButton(
            onPressed: () => ref.read(cartProviderReal.notifier).addItem(cartItem.menuItem),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
