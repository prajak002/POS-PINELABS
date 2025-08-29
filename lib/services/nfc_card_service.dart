import 'package:flutter/services.dart';
import '../core/constants.dart';

class NfcCardService {
  static const MethodChannel _channel = MethodChannel(AppConstants.pineLabsChannel);
  
  // Card scanning state
  static bool _isScanning = false;
  static Function(Map<String, dynamic>)? _onCardRead;
  static Function(String)? _onScanStatus;
  
  // Initialize NFC listening
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  // Handle method calls from Android
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'nfcCardRead':
        final cardData = Map<String, dynamic>.from(call.arguments);
        _isScanning = false;
        _onCardRead?.call(cardData);
        break;
      case 'nfcCardError':
        final errorData = Map<String, dynamic>.from(call.arguments);
        _isScanning = false;
        _onCardRead?.call(errorData);
        break;
      case 'nfcScanStatus':
        final status = call.arguments.toString();
        _onScanStatus?.call(status);
        break;
    }
  }
  
  // Start scanning for NFC cards
  static Future<Map<String, dynamic>> startCardScan({
    Function(Map<String, dynamic>)? onCardRead,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      if (_isScanning) {
        return {
          'success': false,
          'message': 'Already scanning for cards',
          'responseCode': '01',
        };
      }
      
      _onCardRead = onCardRead;
      _onScanStatus = onStatusUpdate;
      _isScanning = true;
      
      final result = await _channel.invokeMethod('readNfcCard');
      return _parseCardResponse(result);
      
    } on PlatformException catch (e) {
      _isScanning = false;
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'NFC Scan Error: ${e.message}',
      };
    } catch (e) {
      _isScanning = false;
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Card scan failed: $e',
      };
    }
  }
  
  // Stop scanning
  static void stopCardScan() {
    _isScanning = false;
    _onCardRead = null;
    _onScanStatus = null;
  }
  
  // Check if currently scanning
  static bool get isScanning => _isScanning;
  
  // Read EMV card data (enhanced version based on the article)
  static Future<Map<String, dynamic>> readEmvCard() async {
    try {
      final result = await _channel.invokeMethod('readNfcCard');
      return _parseCardResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'EMV Read Error: ${e.message}',
      };
    }
  }
  
  // Write card data (for prepaid cards)
  static Future<Map<String, dynamic>> writeCard({
    required String uid,
    required double balance,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'uid': uid,
        'balance': balance,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (additionalData != null) ...additionalData,
      };

      final result = await _channel.invokeMethod('writeNfcCard', data);
      return _parseCardResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'NFC Write Error: ${e.message}',
      };
    }
  }
  
  // Check NFC availability
  static Future<Map<String, dynamic>> checkNfcStatus() async {
    try {
      final result = await _channel.invokeMethod('checkNfcStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'isAvailable': false,
        'isEnabled': false,
        'message': 'NFC Status Error: ${e.message}',
      };
    }
  }
  
  // Parse card response with enhanced error handling
  static Map<String, dynamic> _parseCardResponse(dynamic result) {
    try {
      final response = Map<String, dynamic>.from(result);
      
      // Handle different response formats
      if (response.containsKey('waiting') && response['waiting'] == true) {
        return {
          'success': true,
          'waiting': true,
          'responseCode': response['responseCode'] ?? '00',
          'responseMsg': response['message'] ?? 'Ready to scan card',
        };
      }
      
      // Handle successful card read
      if (response['success'] == true && response.containsKey('uid')) {
        return {
          'success': true,
          'responseCode': response['responseCode'] ?? '00',
          'responseMsg': response['message'] ?? 'Card read successfully',
          'uid': response['uid'] ?? '',
          'cardNumber': response['cardNumber'] ?? '',
          'balance': response['balance']?.toDouble() ?? 0.0,
          'cardType': response['cardType'] ?? 'NFC_CARD',
          'expiryDate': response['expiryDate'] ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          'rawData': response,
        };
      }
      
      // Handle error responses
      return {
        'success': false,
        'responseCode': response['responseCode'] ?? AppConstants.responseCodeError,
        'responseMsg': response['message'] ?? 'Card operation failed',
        'error': response['error'],
      };
      
    } catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Card response parsing error: $e',
      };
    }
  }
  
  // Utility method to format card number (mask for security)
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    final last4 = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $last4';
  }
  
  // Validate card data
  static bool isValidCardData(Map<String, dynamic> cardData) {
    return cardData['success'] == true && 
           cardData['uid'] != null && 
           cardData['uid'].toString().isNotEmpty;
  }
  
  // Extract card information for display
  static Map<String, String> getCardDisplayInfo(Map<String, dynamic> cardData) {
    if (!isValidCardData(cardData)) {
      return {'error': 'Invalid card data'};
    }
    
    return {
      'uid': cardData['uid']?.toString() ?? 'Unknown',
      'cardNumber': maskCardNumber(cardData['cardNumber']?.toString() ?? ''),
      'balance': '₹${(cardData['balance'] ?? 0.0).toStringAsFixed(2)}',
      'cardType': cardData['cardType']?.toString() ?? 'NFC_CARD',
      'timestamp': cardData['timestamp']?.toString() ?? '',
    };
  }
}
