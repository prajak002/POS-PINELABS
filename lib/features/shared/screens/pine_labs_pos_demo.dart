import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/pine_labs_service.dart';
// Use the enums and models from pine_labs_service.dart
enum TransactionType {
  card,
  upi,
  cash,
  voidTransaction,
}

class PineLabsPosDemo extends ConsumerStatefulWidget {
  const PineLabsPosDemo({super.key});

  @override
  ConsumerState<PineLabsPosDemo> createState() => _PineLabsPosDemoState();
}

class _PineLabsPosDemoState extends ConsumerState<PineLabsPosDemo> {
  PosTransactionType _mapToPosTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.card:
        return PosTransactionType.card;
      case TransactionType.upi:
        return PosTransactionType.upi;
      case TransactionType.cash:
        return PosTransactionType.cash;
      case TransactionType.voidTransaction:
        return PosTransactionType.card; // or another appropriate mapping
    }
  }
  final TextEditingController _amountController = TextEditingController(text: '32.52');
  final TextEditingController _mobileController = TextEditingController(text: '9876543210');
  final TextEditingController _serialController = TextEditingController(text: 'BASE123');
  
  ResponseModel? _lastResponse;
  bool _isProcessing = false;
  TransactionType _selectedType = TransactionType.card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pine Labs POS Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔄 Pine Labs Flow Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      '🔄 Pine Labs Flutter POS Flow',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete App2App Integration Demo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Step 1-2: Initialization Status
            _buildInitializationCard(),
            
            const SizedBox(height: 16),
            
            // Step 3: Transaction Settings
            _buildTransactionCard(),
            
            const SizedBox(height: 16),
            
            // Step 4-9: Additional APIs
            _buildAdditionalApisCard(),
            
            const SizedBox(height: 16),
            
            // Response Display
            if (_lastResponse != null) _buildResponseCard(),
            
            const SizedBox(height: 16),
            
            // Flow Diagram
            _buildFlowDiagramCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitializationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Step 1-2: Initialization & Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '✅ POS Lib initialized automatically\n'
              '✅ App2App mode configured (commP1 = 3)\n'
              '✅ NFC services ready',
              style: TextStyle(color: Colors.green.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _testInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('Test Initialization'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Step 3: Main Transaction (doTransaction)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Transaction Type Selection
            Text('Transaction Type:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TransactionType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getTransactionTypeLabel(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Amount Input
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: 12),
            
            // Mobile Number Input
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            // Process Transaction Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processTransaction,
                icon: _isProcessing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.payment),
                label: Text(_isProcessing ? 'Processing...' : 'Process Transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalApisCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.api, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Step 4-9: Additional Pine Labs APIs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Serial Number Input
            TextField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Base Serial Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildApiButton('UPI Status', Icons.account_balance, _checkUpiStatus),
                _buildApiButton('Bluetooth', Icons.bluetooth, _setBluetooth),
                _buildApiButton('Start Scan', Icons.qr_code_scanner, _startScan),
                _buildApiButton('Stop Scan', Icons.stop, _stopScan),
                _buildApiButton('Print Receipt', Icons.print, _printReceipt),
                _buildApiButton('Raw Request', Icons.code, _sendRawRequest),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      color: _lastResponse!.response.responseCode == 0 
          ? Colors.green.shade50 
          : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _lastResponse!.response.responseCode == 0 
                      ? Icons.check_circle 
                      : Icons.error,
                  color: _lastResponse!.response.responseCode == 0 
                      ? Colors.green 
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transaction Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Response Code & Message
            _buildResponseRow('Response Code', _lastResponse!.response.responseCode.toString()),
            _buildResponseRow('Response Message', _lastResponse!.response.responseMsg),
            
            // Detail Information
            if (_lastResponse!.detail != null) ...[
              const Divider(),
              Text('Transaction Details:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_lastResponse!.detail!.cardType != null)
                _buildResponseRow('Card Type', _lastResponse!.detail!.cardType!),
              if (_lastResponse!.detail!.cardNumber != null)
                _buildResponseRow('Card Number', _lastResponse!.detail!.cardNumber!),
              if (_lastResponse!.detail!.approvalCode != null)
                _buildResponseRow('Approval Code', _lastResponse!.detail!.approvalCode!),
              if (_lastResponse!.detail!.transactionDate != null)
                _buildResponseRow('Transaction Date', _lastResponse!.detail!.transactionDate!),
              if (_lastResponse!.detail!.transactionTime != null)
                _buildResponseRow('Transaction Time', _lastResponse!.detail!.transactionTime!),
            ],
            
            const SizedBox(height: 12),
            
            // Raw Response
            ExpansionTile(
              title: const Text('Raw Response'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lastResponse!.rawResponse,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowDiagramCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'End-to-End Sequence Flow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildFlowStep('1', 'Billing App', 'calls doTransaction', Colors.blue),
            _buildFlowArrow(),
            _buildFlowStep('2', 'POS Bridge', 'routes to Pine Labs app', Colors.orange),
            _buildFlowArrow(),
            _buildFlowStep('3', 'Pine Labs App', 'sends to processing engine', Colors.green),
            _buildFlowArrow(),
            _buildFlowStep('4', 'Processing Engine', 'authorizes transaction', Colors.purple),
            _buildFlowArrow(),
            _buildFlowStep('5', 'Response Flow', 'returns result to billing app', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String number, String title, String description, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowArrow() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  // Event Handlers
  Future<void> _testInitialization() async {
    setState(() => _isProcessing = true);
    try {
      await PineLabsService.initialize();
      _showSuccessSnackBar('Pine Labs POS service initialized successfully!');
    } catch (e) {
      _showErrorSnackBar('Initialization failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processTransaction() async {
    setState(() => _isProcessing = true);
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final mobile = _mobileController.text.trim();
      final billingRefNo = 'TXN_${DateTime.now().millisecondsSinceEpoch}';

      final response = await PineLabsService.doTransaction(
        transactionType: _mapToPosTransactionType(_selectedType),
        billingRefNo: billingRefNo,
        paymentAmount: amount,
        mobileNumberForEChargeSlip: mobile.isNotEmpty ? mobile : null,
      );

  setState(() => _lastResponse = response);

      if (response.response.responseCode == 0) {
        _showSuccessSnackBar('Transaction successful!');
      } else {
        _showErrorSnackBar('Transaction failed: ${response.response.responseMsg}');
      }
    } catch (e) {
      _showErrorSnackBar('Transaction error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _checkUpiStatus() async {
    setState(() => _isProcessing = true);
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final response = await PineLabsService.getUpiStatus(
        billingRefNo: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
        paymentAmount: amount,
      );
  setState(() => _lastResponse = response);
      _showSuccessSnackBar('UPI status checked');
    } catch (e) {
      _showErrorSnackBar('UPI status error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _setBluetooth() async {
    setState(() => _isProcessing = true);
    try {
      final response = await PineLabsService.setBluetooth(
        baseSerialNumber: _serialController.text,
      );
  setState(() => _lastResponse = response);
      _showSuccessSnackBar('Bluetooth operation completed');
    } catch (e) {
      _showErrorSnackBar('Bluetooth error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _startScan() async {
    setState(() => _isProcessing = true);
    try {
      final response = await PineLabsService.startScan(
        baseSerialNumber: _serialController.text,
      );
  setState(() => _lastResponse = response);
      _showSuccessSnackBar('Scanning started');
    } catch (e) {
      _showErrorSnackBar('Start scan error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _stopScan() async {
    setState(() => _isProcessing = true);
    try {
      final response = await PineLabsService.stopScan(
        baseSerialNumber: _serialController.text,
      );
  setState(() => _lastResponse = response);
      _showSuccessSnackBar('Scanning stopped');
    } catch (e) {
      _showErrorSnackBar('Stop scan error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _printReceipt() async {
    setState(() => _isProcessing = true);
    try {
      final printList = [
        {
          "PrintDataType": 1,
          "PrinterWidth": 32,
          "IsCenterAligned": true,
          "DataToPrint": "Thank you for shopping!",
        },
        {
          "PrintDataType": 1,
          "PrinterWidth": 32,
          "IsCenterAligned": false,
          "DataToPrint": "Amount: ₹${_amountController.text}",
        },
        {
          "PrintDataType": 1,
          "PrinterWidth": 32,
          "IsCenterAligned": false,
          "DataToPrint": "Date: ${DateTime.now().toString().substring(0, 19)}",
        },
      ];
      
      final response = await PineLabsService.printData(
        printData: printList,
        printRefNo: 'RECEIPT_${DateTime.now().millisecondsSinceEpoch}',
      );
  setState(() => _lastResponse = ResponseModel.fromJson(response));
      _showSuccessSnackBar('Receipt sent to printer');
    } catch (e) {
      _showErrorSnackBar('Print error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _sendRawRequest() async {
    setState(() => _isProcessing = true);
    try {
      final rawJson = '{"test": "raw request", "timestamp": "${DateTime.now().toIso8601String()}"}';
      final response = await PineLabsService.sendRequest(requestJson: rawJson);
  setState(() => _lastResponse = response);
      _showSuccessSnackBar('Raw request sent');
    } catch (e) {
      _showErrorSnackBar('Raw request error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.card:
        return 'Card';
      case TransactionType.cash:
        return 'Cash';
      case TransactionType.upi:
        return 'UPI';
      case TransactionType.voidTransaction:
        return 'Void Transaction';
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _mobileController.dispose();
    _serialController.dispose();
    super.dispose();
  }
}
