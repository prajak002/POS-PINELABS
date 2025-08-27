import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pine_labs_service.dart';
import '../../services/api_client.dart';
import '../../models/transaction.dart';
import '../../core/constants.dart';
import 'widgets/payment_method_dialog.dart';

class TopupCardScreen extends ConsumerStatefulWidget {
  const TopupCardScreen({super.key});

  @override
  ConsumerState<TopupCardScreen> createState() => _TopupCardScreenState();
}

class _TopupCardScreenState extends ConsumerState<TopupCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _cardInfo;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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

  Future<void> _topupCard() async {
    if (!_formKey.currentState!.validate() || _cardInfo == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final topupAmount = double.parse(_amountController.text);
      final billingRefNo = 'TOPUP_${DateTime.now().millisecondsSinceEpoch}';

      // Step 1: Process Payment through Pine Labs
      final paymentResult = await PineLabsService.doTransaction(
        amount: topupAmount,
        billingRefNo: billingRefNo,
        transactionType: AppConstants.cardSaleTransaction,
      );

      if (paymentResult['success'] == true && paymentResult['responseCode'] == '00') {
        // Step 2: Update card balance
        final currentBalance = (_cardInfo!['balance'] as num).toDouble();
        final newBalance = currentBalance + topupAmount;
        final cardUid = _cardInfo!['uid'];

        // Step 3: Write new balance to card
        final writeResult = await PineLabsService.writeCard(
          uid: cardUid,
          balance: newBalance,
        );

        if (writeResult['success'] == true) {
          // Step 4: Save to backend
          await _saveTransactionToBackend(cardUid, topupAmount, newBalance, billingRefNo, paymentResult);
          
          // Step 5: Print receipt
          await _printReceipt(topupAmount, currentBalance, newBalance, cardUid, billingRefNo);
          
          _showSuccessDialog(cardUid, topupAmount, newBalance);
        } else {
          setState(() {
            _errorMessage = 'Failed to update card: ${writeResult['responseMsg'] ?? 'Unknown error'}';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Payment failed: ${paymentResult['responseMsg'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Top-up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTransactionToBackend(String cardUid, double amount, double newBalance, String billingRefNo, Map<String, dynamic> paymentResult) async {
    try {
      // Create transaction record
      final transaction = Transaction(
        id: billingRefNo,
        type: TransactionType.topup,
        amount: amount,
        cardUid: cardUid,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
        approvalCode: paymentResult['approvalCode'],
        transactionId: paymentResult['transactionId'],
      );

      // TODO: Save to API
      // await ref.read(apiClientProvider).createTransaction(transaction);
      
      // Save to local Hive database
      // TODO: Implement Hive transaction saving
      print('Transaction saved: ${transaction.toJson()}');
    } catch (e) {
      print('Failed to save transaction: $e');
    }
  }

  Future<void> _printReceipt(double topupAmount, double oldBalance, double newBalance, String cardUid, String billingRefNo) async {
    try {
      final printData = PineLabsService.createReceiptPrintData(
        title: 'CARD TOP-UP',
        amount: topupAmount,
        cardUid: cardUid,
        billingRefNo: billingRefNo,
      );

      await PineLabsService.printData(
        printRefNo: 'PRINT_$billingRefNo',
        printData: printData,
      );
    } catch (e) {
      print('Print failed: $e');
    }
  }

  void _showSuccessDialog(String cardUid, double topupAmount, double newBalance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top-up Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text('Card UID: $cardUid'),
            Text('Top-up Amount: ₹${topupAmount.toStringAsFixed(2)}'),
            Text('New Balance: ₹${newBalance.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-up Card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                        'Top-up Existing Card',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'First, read the card to check current balance, then enter the top-up amount.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Card Information Section
              if (_cardInfo == null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.nfc, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        const Text('Tap card to read current balance'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _readCard,
                          icon: const Icon(Icons.credit_card),
                          label: _isLoading 
                              ? const Text('Reading...')
                              : const Text('Read Card'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Card Information:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('UID: ${_cardInfo!['uid']}'),
                        Text('Current Balance: ₹${(_cardInfo!['balance'] as num).toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _readCard,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Read Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Amount Input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Top-up Amount (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                enabled: _cardInfo != null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 10) {
                    return 'Minimum top-up is ₹10';
                  }
                  if (amount > 10000) {
                    return 'Maximum top-up is ₹10,000';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
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
              
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: (_isLoading || _cardInfo == null) ? null : _topupCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proceed to Payment',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              
              const Spacer(),
              
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Process Flow:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Tap card to read current balance'),
                      Text('2. Enter top-up amount'),
                      Text('3. Payment will be processed via Pine Labs'),
                      Text('4. Card balance will be updated'),
                      Text('5. Transaction will be saved to backend'),
                      Text('6. Receipt will be printed'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
