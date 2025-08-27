import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/menu_provider_real.dart';
import '../auth/auth_provider.dart';
import 'order_screen.dart';
import 'menu_management_screen.dart';
import 'order_history_screen.dart';

class StallDashboard extends ConsumerStatefulWidget {
  const StallDashboard({super.key});

  @override
  ConsumerState<StallDashboard> createState() => _StallDashboardState();
}

class _StallDashboardState extends ConsumerState<StallDashboard> {
  @override
  void initState() {
    super.initState();
    // Load menu when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProviderReal.notifier).loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final menu = ref.watch(menuProviderReal);
    final cart = ref.watch(cartProviderReal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stall Counter'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          // Cart badge
          if (cart.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${cart.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => _showComingSoonDialog(context, 'Checkout'),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 32,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.username ?? 'User'}',
                          style: AppTextStyles.heading2,
                        ),
                        Text(
                          'Stall Counter Management',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dashboard actions
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    title: 'New Order',
                    subtitle: 'Take customer orders',
                    icon: Icons.add_shopping_cart,
                    color: Colors.green,
                    onTap: () => _showOrderScreen(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    title: 'Manage Menu',
                    subtitle: 'Add/Edit menu items',
                    icon: Icons.restaurant_menu,
                    color: Colors.blue,
                    onTap: () => _showMenuManagement(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    title: 'Orders History',
                    subtitle: 'View past orders',
                    icon: Icons.history,
                    color: Colors.purple,
                    onTap: () => _showOrderHistory(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    title: 'Sync Data',
                    subtitle: 'Sync with server',
                    icon: Icons.sync,
                    color: Colors.teal,
                    onTap: () => _syncData(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu preview
            if (menu.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Menu (${menu.length} items)',
                    style: AppTextStyles.heading2,
                  ),
                  TextButton(
                    onPressed: () => _showComingSoonDialog(context, 'Manage Menu'),
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Menu functionality coming soon!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // TODO: Restore when MenuItem issues are fixed
                // child: ListView.builder(
                //   itemCount: menu.take(3).length,
                //   itemBuilder: (context, index) {
                //     final item = menu[index];
                //     return Card(
                //       child: ListTile(
                //         leading: CircleAvatar(
                //           backgroundColor: Colors.orange.shade100,
                //           child: Icon(Icons.fastfood, color: Colors.orange),
                //         ),
                //         title: Text(item.food),
                //         subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
                //         trailing: Text(
                //           item.vendorName,
                //           style: TextStyle(
                //             fontSize: 12,
                //             color: Colors.grey.shade600,
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No menu items found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showComingSoonDialog(context, 'Add Menu Items'),
                      child: const Text('Add Menu Items'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOrderScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderScreen(),
      ),
    );
  }

  void _showMenuManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MenuManagementScreen(),
      ),
    );
  }

  void _showOrderHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderHistoryScreen(),
      ),
    );
  }

  Future<void> _syncData(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sync menu from server
      await ref.read(menuProviderReal.notifier).loadMenu();
      
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}