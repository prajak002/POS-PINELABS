import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pine_labs_service.dart';

class CheckBalanceScreen extends ConsumerStatefulWidget {
  const CheckBalanceScreen({super.key});

  @override
  ConsumerState<CheckBalanceScreen> createState() => _CheckBalanceScreenState();
}

class _CheckBalanceScreenState extends ConsumerState<CheckBalanceScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _cardInfo;

  Future<void> _readCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cardInfo = null;
    });

    try {
      // Read card to get current balance
      final cardReadResult = await PineLabsService.readCard();
      
      if (cardReadResult['success'] == true) {
        setState(() {
          _cardInfo = cardReadResult;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to read card: ${cardReadResult['responseMsg'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Card read failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Balance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Card Balance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap your NFC card on the POS terminal to check the current balance.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Card Reading Section
            if (_cardInfo == null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.nfc, size: 80, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        'Tap Card to Read Balance',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Place your card on the NFC reader',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _readCard,
                        icon: const Icon(Icons.credit_card),
                        label: _isLoading 
                            ? const Text('Reading...')
                            : const Text('Read Card'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        'Card Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Card UID:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_cardInfo!['uid']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Current Balance:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '₹${(_cardInfo!['balance'] as num).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _readCard,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Read Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _cardInfo = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const Spacer(),
            
            Card(
              color: Colors.grey.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Tap "Read Card" button'),
                    Text('• Place your NFC card on the POS terminal'),
                    Text('• Card UID and balance will be displayed'),
                    Text('• Use "Read Again" to refresh the balance'),
                    Text('• Use "Clear" to read a different card'),
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
