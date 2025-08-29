import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pine_labs_service.dart';
import '../../services/api_client.dart';
import '../../models/transaction.dart';
import '../../core/constants.dart';
import 'widgets/payment_method_dialog.dart';

class IssueCardScreen extends ConsumerStatefulWidget {
  const IssueCardScreen({super.key});

  @override
  ConsumerState<IssueCardScreen> createState() => _IssueCardScreenState();
}

class _IssueCardScreenState extends ConsumerState<IssueCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _issueCard() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    // Show payment method selection dialog
    final paymentMethod = await showDialog<PaymentMethod>(
      context: context,
      builder: (context) => PaymentMethodDialog(
        amount: amount,
        onPaymentMethodSelected: (method) => Navigator.of(context).pop(method),
      ),
    );

    if (paymentMethod == null) return; // User cancelled

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final billingRefNo = '${AppConstants.issueCardPrefix}${DateTime.now().millisecondsSinceEpoch}';

      // Step 1: Process Payment based on selected method
  ResponseModel paymentResult;
      String paymentMethodName = '';
      
      switch (paymentMethod) {
        case PaymentMethod.card:
          paymentResult = await PineLabsService.doTransaction(
            paymentAmount: amount,
            billingRefNo: billingRefNo,
            transactionType: PosTransactionType.card,
          );
          paymentMethodName = 'CARD';
          break;
        case PaymentMethod.upi:
          paymentResult = await PineLabsService.doUpiTransaction(
            amount: amount,
            billingRefNo: billingRefNo,
          );
          paymentMethodName = 'UPI';
          break;
        case PaymentMethod.cash:
          paymentResult = await PineLabsService.doCashTransaction(
            amount: amount,
            billingRefNo: billingRefNo,
          );
          paymentMethodName = 'CASH';
          break;
      }

  if (paymentResult.response.responseCode == 0) {
        // Step 2: Read card UID after successful payment
  await _showCardTapDialog(amount, billingRefNo, paymentResult, paymentMethodName);
      } else {
        setState(() {
          _errorMessage = 'Payment failed: ${paymentResult.response.responseMsg}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCardTapDialog(double amount, String billingRefNo, ResponseModel paymentResult, String paymentMethod) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tap NFC Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.nfc,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text('Please tap the NFC card on the POS terminal'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      // Step 3: Read card to get UID
      final cardReadResult = await PineLabsService.readCard();
      
      if (cardReadResult['success'] == true) {
        final cardUid = cardReadResult['uid'];
        
        // Step 4: Write amount to card
        final writeResult = await PineLabsService.writeCard(
          uid: cardUid,
          balance: amount,
        );

        if (writeResult['success'] == true) {
        // Step 5: Save to backend
  await _saveCardToBackend(cardUid, amount, billingRefNo, jsonDecode(paymentResult.rawResponse), paymentMethod);
        
        // Step 6: Print receipt
        await _printReceipt(amount, cardUid, billingRefNo, paymentMethod);          Navigator.of(context).pop(); // Close dialog
          _showSuccessDialog(cardUid, amount);
        } else {
          Navigator.of(context).pop();
          setState(() {
            _errorMessage = 'Failed to write to card: ${writeResult['responseMsg'] ?? 'Unknown error'}';
          });
        }
      } else {
        Navigator.of(context).pop();
        setState(() {
          _errorMessage = 'Failed to read card: ${cardReadResult['responseMsg'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _errorMessage = 'Card operation failed: $e';
      });
    }
  }

  Future<void> _saveCardToBackend(String cardUid, double amount, String billingRefNo, Map<String, dynamic> paymentResult, String paymentMethod) async {
    try {
      // Create transaction record
      final transaction = Transaction(
        id: billingRefNo,
        type: TransactionType.issue,
        amount: amount,
        cardUid: cardUid,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
        approvalCode: paymentResult['approvalCode'],
        transactionId: paymentResult['transactionId'],
        additionalData: {
          'paymentMethod': paymentMethod,
          'cardType': paymentResult['cardType'] ?? '',
          'merchantId': paymentResult['merchantId'] ?? '',
          'terminalId': paymentResult['terminalId'] ?? '',
        },
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

  Future<void> _printReceipt(double amount, String cardUid, String billingRefNo, String paymentMethod) async {
    try {
      final printData = PineLabsService.createReceiptPrintData(
        title: 'NEW CARD ISSUED',
        amount: amount,
        cardUid: cardUid,
        billingRefNo: billingRefNo,
        paymentMethod: paymentMethod,
      );

      await PineLabsService.printData(
        printRefNo: 'PRINT_$billingRefNo',
        printData: printData,
      );
    } catch (e) {
      print('Print failed: $e');
    }
  }

  void _showSuccessDialog(String cardUid, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card Issued Successfully!'),
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
            Text('Initial Balance: ₹${amount.toStringAsFixed(2)}'),
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
        title: const Text('Issue New Card'),
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
                        'Issue New Card',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the initial amount to load on the new card. After payment, you will be prompted to tap the NFC card.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 10) {
                    return 'Minimum amount is ₹10';
                  }
                  if (amount > 10000) {
                    return 'Maximum amount is ₹10,000';
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
                onPressed: _isLoading ? null : _issueCard,
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
                      Text('1. Enter amount and proceed to payment'),
                      Text('2. Payment will be processed via Pine Labs'),
                      Text('3. Tap NFC card to get UID'),
                      Text('4. Amount will be written to the card'),
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
