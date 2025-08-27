import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import 'issue_card_screen.dart';
import 'topup_card_screen.dart';
import 'check_balance_screen.dart';
import 'summary_screen.dart';

class TopupDashboard extends ConsumerWidget {
  const TopupDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topup Counter'),
        actions: [
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
                      Icons.person,
                      size: 32,
                      color: AppTheme.primaryColor,
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
                          'Topup Counter Dashboard',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dashboard cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    title: 'Issue New Card',
                    subtitle: 'Create and load new card',
                    icon: Icons.add_card,
                    color: AppTheme.successColor,
                    onTap: () {
                      // Navigate to issue new card screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const IssueCardScreen(),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    title: 'Top-up Card',
                    subtitle: 'Add money to existing card',
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    onTap: () {
                      // Navigate to topup screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TopupCardScreen(),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    title: 'Check Balance',
                    subtitle: 'View card balance',
                    icon: Icons.search,
                    color: AppTheme.warningColor,
                    onTap: () {
                      // Navigate to balance check screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CheckBalanceScreen(),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    title: 'Summary',
                    subtitle: 'View transactions & export',
                    icon: Icons.assessment,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to summary screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SummaryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
