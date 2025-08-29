import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pine_labs_service.dart';
import '../services/nfc_card_service.dart';

// NFC Status Provider
final nfcStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await PineLabsService.checkNfcStatus();
});

// Card Scanning State Provider
final cardScanningProvider = StateNotifierProvider<CardScanningNotifier, CardScanningState>((ref) {
  return CardScanningNotifier();
});

class CardScanningState {
  final bool isScanning;
  final String statusMessage;
  final Map<String, dynamic>? cardData;
  final bool hasError;
  final String? error;

  CardScanningState({
    this.isScanning = false,
    this.statusMessage = 'Ready to scan',
    this.cardData,
    this.hasError = false,
    this.error,
  });

  CardScanningState copyWith({
    bool? isScanning,
    String? statusMessage,
    Map<String, dynamic>? cardData,
    bool? hasError,
    String? error,
  }) {
    return CardScanningState(
      isScanning: isScanning ?? this.isScanning,
      statusMessage: statusMessage ?? this.statusMessage,
      cardData: cardData ?? this.cardData,
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
    );
  }
}

class CardScanningNotifier extends StateNotifier<CardScanningState> {
  CardScanningNotifier() : super(CardScanningState());

  Future<void> startScanning() async {
    state = state.copyWith(
      isScanning: true,
      statusMessage: 'Initializing NFC...',
      hasError: false,
      error: null,
      cardData: null,
    );

    try {
      final result = await PineLabsService.readCard(
        onCardRead: _handleCardRead,
        onStatusUpdate: _handleStatusUpdate,
      );

      if (result['success'] == true) {
        if (result['waiting'] == true) {
          state = state.copyWith(
            statusMessage: 'Ready to scan - Bring card near device',
          );
        }
      } else {
        state = state.copyWith(
          isScanning: false,
          hasError: true,
          error: result['responseMsg'] ?? 'Failed to start scanning',
          statusMessage: result['responseMsg'] ?? 'Failed to start scanning',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        hasError: true,
        error: e.toString(),
        statusMessage: 'Error: $e',
      );
    }
  }

  void _handleCardRead(Map<String, dynamic> cardData) {
    if (cardData['success'] == true) {
      state = state.copyWith(
        isScanning: false,
        cardData: cardData,
        statusMessage: 'Card read successfully!',
        hasError: false,
        error: null,
      );
    } else {
      state = state.copyWith(
        isScanning: false,
        hasError: true,
        error: cardData['responseMsg'] ?? 'Failed to read card',
        statusMessage: cardData['responseMsg'] ?? 'Failed to read card',
      );
    }
  }

  void _handleStatusUpdate(String status) {
    state = state.copyWith(statusMessage: status);
  }

  void stopScanning() {
    PineLabsService.stopCardScan();
    state = state.copyWith(
      isScanning: false,
      statusMessage: 'Scanning stopped',
    );
  }

  void clearCardData() {
    state = state.copyWith(
      cardData: null,
      statusMessage: 'Ready to scan',
      hasError: false,
      error: null,
    );
  }
}

// Example usage in a screen
class NfcDemoScreen extends ConsumerWidget {
  const NfcDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nfcStatus = ref.watch(nfcStatusProvider);
    final scanningState = ref.watch(cardScanningProvider);
    final scanningNotifier = ref.read(cardScanningProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // NFC Status
          nfcStatus.when(
            data: (status) => Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: Icon(
                  status['isAvailable'] == true 
                      ? (status['isEnabled'] == true ? Icons.nfc : Icons.nfc_outlined)
                      : Icons.error,
                  color: status['isAvailable'] == true 
                      ? (status['isEnabled'] == true ? Colors.green : Colors.orange)
                      : Colors.red,
                ),
                title: Text(status['message'] ?? 'Unknown status'),
                subtitle: Text(
                  'Available: ${status['isAvailable']}, Enabled: ${status['isEnabled']}'
                ),
              ),
            ),
            loading: () => const Card(
              margin: EdgeInsets.all(16),
              child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Checking NFC status...'),
              ),
            ),
            error: (error, stack) => Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text('Error: $error'),
              ),
            ),
          ),

          // Scanning Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: scanningState.isScanning 
                      ? null 
                      : () => scanningNotifier.startScanning(),
                  child: Text(scanningState.isScanning ? 'Scanning...' : 'Start Scan'),
                ),
                ElevatedButton(
                  onPressed: scanningState.isScanning 
                      ? () => scanningNotifier.stopScanning()
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () => scanningNotifier.clearCardData(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Status Message
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: Icon(
                scanningState.hasError 
                    ? Icons.error 
                    : scanningState.isScanning 
                        ? Icons.radar
                        : Icons.info,
                color: scanningState.hasError 
                    ? Colors.red 
                    : scanningState.isScanning 
                        ? Colors.blue
                        : Colors.grey,
              ),
              title: Text(scanningState.statusMessage),
              subtitle: scanningState.hasError && scanningState.error != null
                  ? Text('Error: ${scanningState.error}')
                  : null,
            ),
          ),

          // Card Data Display
          if (scanningState.cardData != null)
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...scanningState.cardData!.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '${entry.key}:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text('${entry.value}'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
