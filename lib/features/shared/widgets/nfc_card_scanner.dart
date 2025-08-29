import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/nfc_card_service.dart';
import '../../../services/pine_labs_service.dart';

class NfcCardScanner extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onCardRead;
  final VoidCallback? onCancel;
  final String title;
  final String subtitle;

  const NfcCardScanner({
    Key? key,
    this.onCardRead,
    this.onCancel,
    this.title = 'Scan Card',
    this.subtitle = 'Bring your card near the device',
  }) : super(key: key);

  @override
  ConsumerState<NfcCardScanner> createState() => _NfcCardScannerState();
}

class _NfcCardScannerState extends ConsumerState<NfcCardScanner>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  String _statusMessage = 'Ready to scan...';
  bool _isScanning = false;
  bool _cardDetected = false;
  Map<String, dynamic>? _cardData;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startScanning();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Initializing NFC...';
    });

    // Check NFC status first
    final nfcStatus = await NfcCardService.checkNfcStatus();
    
    if (nfcStatus['isAvailable'] != true) {
      setState(() {
        _statusMessage = 'NFC not available on this device';
        _isScanning = false;
      });
      return;
    }
    
    if (nfcStatus['isEnabled'] != true) {
      setState(() {
        _statusMessage = 'Please enable NFC in settings';
        _isScanning = false;
      });
      return;
    }

    // Start card scanning
    final result = await PineLabsService.readCard(
      onCardRead: _onCardReadCallback,
      onStatusUpdate: _onStatusUpdateCallback,
    );
    
    if (result['waiting'] == true) {
      setState(() {
        _statusMessage = 'Ready to scan - Bring card near device';
      });
    } else if (result['success'] != true) {
      setState(() {
        _statusMessage = result['responseMsg'] ?? 'Failed to start scanning';
        _isScanning = false;
      });
    }
  }

  void _onCardReadCallback(Map<String, dynamic> cardData) {
    setState(() {
      _cardDetected = true;
      _cardData = cardData;
      _isScanning = false;
      _animationController.stop();
    });

    if (cardData['success'] == true) {
      setState(() {
        _statusMessage = 'Card read successfully!';
      });
      
      // Vibrate device (if available)
      // HapticFeedback.heavyImpact();
      
      // Call the callback after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        widget.onCardRead?.call(cardData);
      });
    } else {
      setState(() {
        _statusMessage = cardData['responseMsg'] ?? 'Failed to read card';
      });
      
      // Restart scanning after error
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startScanning();
        }
      });
    }
  }

  void _onStatusUpdateCallback(String status) {
    setState(() {
      _statusMessage = status;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    PineLabsService.stopCardScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // NFC Icon with animation
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isScanning ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cardDetected
                        ? Colors.green
                        : _isScanning
                            ? Colors.blue
                            : Colors.grey,
                    boxShadow: [
                      BoxShadow(
                        color: (_cardDetected
                                ? Colors.green
                                : _isScanning
                                    ? Colors.blue
                                    : Colors.grey)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _cardDetected
                        ? Icons.check_circle
                        : Icons.nfc,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Status message
          Text(
            _statusMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Loading indicator
          if (_isScanning)
            const CircularProgressIndicator(),
          
          // Card data display
          if (_cardDetected && _cardData != null)
            _buildCardDataDisplay(),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: () {
                    PineLabsService.stopCardScan();
                    widget.onCancel?.call();
                  },
                  child: const Text('Cancel'),
                ),
              const SizedBox(width: 16),
              if (_isScanning)
                ElevatedButton(
                  onPressed: () {
                    PineLabsService.stopCardScan();
                    setState(() {
                      _isScanning = false;
                    });
                  },
                  child: const Text('Stop Scanning'),
                ),
              if (!_isScanning && !_cardDetected)
                ElevatedButton(
                  onPressed: _startScanning,
                  child: const Text('Start Scanning'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDataDisplay() {
    if (_cardData == null) return const SizedBox.shrink();
    
    final displayInfo = NfcCardService.getCardDisplayInfo(_cardData!);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Card UID', displayInfo['uid'] ?? 'Unknown'),
            _buildInfoRow('Card Number', displayInfo['cardNumber'] ?? 'N/A'),
            _buildInfoRow('Balance', displayInfo['balance'] ?? '₹0.00'),
            _buildInfoRow('Card Type', displayInfo['cardType'] ?? 'NFC_CARD'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage example widget
class NfcScannerDemo extends ConsumerWidget {
  const NfcScannerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Card Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: NfcCardScanner(
        title: 'Scan Your Card',
        subtitle: 'Place your NFC card near the device',
        onCardRead: (cardData) {
          // Handle successful card read
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Card read successfully: ${cardData['uid']}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or perform action
          Navigator.of(context).pop(cardData);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
