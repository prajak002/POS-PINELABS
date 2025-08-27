import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: _buildOrderHistory(),
    );
  }

  Widget _buildOrderHistory() {
    // Mock data for now - in real app, this would come from local storage or API
    final orders = _getMockOrders();

    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No order history available'),
            Text('Orders will appear here after checkout'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }

  List<Order> _getMockOrders() {
    // Mock orders for demonstration
    return [
      Order(
        id: 'ORD001',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        items: [
          OrderItem(name: 'Burger', quantity: 2, price: 150.0),
          OrderItem(name: 'Fries', quantity: 1, price: 80.0),
        ],
        total: 380.0,
        paymentMethod: 'Card',
        status: 'Completed',
      ),
      Order(
        id: 'ORD002',
        date: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          OrderItem(name: 'Pizza', quantity: 1, price: 250.0),
          OrderItem(name: 'Coke', quantity: 2, price: 40.0),
        ],
        total: 330.0,
        paymentMethod: 'UPI',
        status: 'Completed',
      ),
      Order(
        id: 'ORD003',
        date: DateTime.now().subtract(const Duration(days: 2)),
        items: [
          OrderItem(name: 'Sandwich', quantity: 1, price: 120.0),
        ],
        total: 120.0,
        paymentMethod: 'Cash',
        status: 'Completed',
      ),
    ];
  }

  void _exportToExcel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Orders'),
        content: const Text('This feature will export order history to Excel format.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Excel export functionality coming soon!'),
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.id,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '₹${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(order.date)),
            Text('${order.paymentMethod} • ${order.status}'),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.name} x${item.quantity}'),
                      Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

// Models for Order History
class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double total;
  final String paymentMethod;
  final String status;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
