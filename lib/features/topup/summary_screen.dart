import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../../services/api_client.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Transaction> _transactions = [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Load from API
      // final transactions = await ref.read(apiClientProvider).getTransactions();
      
      // For now, load mock data
      _loadMockTransactions();
      _calculateSummary();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMockTransactions() {
    // Mock transactions for demo
    _transactions = [
      Transaction(
        id: 'ISSUE_1735859355001',
        type: TransactionType.issue,
        amount: 500.0,
        cardUid: 'CARD12345678',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransactionStatus.completed,
        approvalCode: 'A123456',
        transactionId: 'TXN1735859355001',
      ),
      Transaction(
        id: 'TOPUP_1735859455002',
        type: TransactionType.topup,
        amount: 200.0,
        cardUid: 'CARD87654321',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: TransactionStatus.completed,
        approvalCode: 'A234567',
        transactionId: 'TXN1735859455002',
      ),
      Transaction(
        id: 'ISSUE_1735859555003',
        type: TransactionType.issue,
        amount: 1000.0,
        cardUid: 'CARD11223344',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: TransactionStatus.completed,
        approvalCode: 'A345678',
        transactionId: 'TXN1735859555003',
      ),
      Transaction(
        id: 'TOPUP_1735859655004',
        type: TransactionType.topup,
        amount: 300.0,
        cardUid: 'CARD44332211',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: TransactionStatus.completed,
        approvalCode: 'A456789',
        transactionId: 'TXN1735859655004',
      ),
    ];
  }

  void _calculateSummary() {
    double totalAmount = 0;
    int issueCount = 0;
    int topupCount = 0;
    double issueAmount = 0;
    double topupAmount = 0;

    for (final transaction in _transactions) {
      totalAmount += transaction.amount;
      if (transaction.type == TransactionType.issue) {
        issueCount++;
        issueAmount += transaction.amount;
      } else if (transaction.type == TransactionType.topup) {
        topupCount++;
        topupAmount += transaction.amount;
      }
    }

    _summary = {
      'totalTransactions': _transactions.length,
      'totalAmount': totalAmount,
      'issueCount': issueCount,
      'issueAmount': issueAmount,
      'topupCount': topupCount,
      'topupAmount': topupAmount,
    };
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'Issue Card';
      case TransactionType.topup:
        return 'Top-up';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return Colors.blue;
      case TransactionType.topup:
        return Colors.green;
      case TransactionType.payment:
        return Colors.orange;
      case TransactionType.refund:
        return Colors.red;
    }
  }

  Icon _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return const Icon(Icons.add_card, color: Colors.blue);
      case TransactionType.topup:
        return const Icon(Icons.add, color: Colors.green);
      case TransactionType.payment:
        return const Icon(Icons.payment, color: Colors.orange);
      case TransactionType.refund:
        return const Icon(Icons.remove, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Summary Cards
                      if (_summary != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.blue.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.receipt, size: 32, color: Colors.blue),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_summary!['totalTransactions']}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Total Transactions'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                color: Colors.green.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.currency_rupee, size: 32, color: Colors.green),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₹${_summary!['totalAmount'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Total Amount'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.orange.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.add_card, size: 24, color: Colors.orange),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_summary!['issueCount']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Issues'),
                                      Text('₹${_summary!['issueAmount'].toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                color: Colors.purple.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.add, size: 24, color: Colors.purple),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_summary!['topupCount']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Top-ups'),
                                      Text('₹${_summary!['topupAmount'].toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Transactions List
                      Expanded(
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _transactions.isEmpty
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text('No transactions found'),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _transactions.length,
                                        itemBuilder: (context, index) {
                                          final transaction = _transactions[index];
                                          return ListTile(
                                            leading: _getTransactionTypeIcon(transaction.type),
                                            title: Text(_getTransactionTypeText(transaction.type)),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Card: ${transaction.cardUid}'),
                                                Text(
                                                  '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} '
                                                  '${transaction.timestamp.hour.toString().padLeft(2, '0')}:'
                                                  '${transaction.timestamp.minute.toString().padLeft(2, '0')}',
                                                ),
                                              ],
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${transaction.amount.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _getTransactionTypeColor(transaction.type),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade100,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Text(
                                                    'COMPLETED',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              // TODO: Show transaction details
                                            },
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
