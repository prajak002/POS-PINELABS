import 'package:flutter/services.dart';
import '../core/constants.dart';

class PineLabsService {
  static const MethodChannel _channel = MethodChannel(AppConstants.pineLabsChannel);

  // Do Transaction - triggers Pine Labs payment (following Plutus APOS docs)
  static Future<Map<String, dynamic>> doTransaction({
    required double amount,
    required String billingRefNo,
    int transactionType = AppConstants.cardSaleTransaction,
    Map<String, dynamic>? additionalData,
    String? customerMobile,
    String? customerEmail,
  }) async {
    try {
      // Create Pine Labs APOS compliant request
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024", // Your registered Pine Labs App ID
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1001", // DoTransaction method ID
          "VersionNo": "1.0"
        },
        "Detail": {
          "TransactionType": transactionType.toString(),
          "BillingRefNo": billingRefNo,
          "PaymentAmount": (amount * 100).toInt(), // Amount in paise
          "IsSwipe": true,
          if (customerMobile != null) "CustomerMobileNumber": customerMobile,
          if (customerEmail != null) "CustomerEmailId": customerEmail,
          if (additionalData != null) "AdditionalInfo": additionalData,
        }
      };

      final result = await _channel.invokeMethod('doTransaction', request);
      return _parseTransactionResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Platform Error: ${e.message}',
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Transaction Failed: $e',
      };
    }
  }

  // UPI Transaction
  static Future<Map<String, dynamic>> doUpiTransaction({
    required double amount,
    required String billingRefNo,
    String? customerMobile,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024",
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1001",
          "VersionNo": "1.0"
        },
        "Detail": {
          "TransactionType": AppConstants.upiSaleTransaction.toString(),
          "BillingRefNo": billingRefNo,
          "PaymentAmount": (amount * 100).toInt(),
          if (customerMobile != null) "CustomerMobileNumber": customerMobile,
        }
      };

      final result = await _channel.invokeMethod('doTransaction', request);
      return _parseTransactionResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'UPI Error: ${e.message}',
      };
    }
  }

  // Cash Transaction (No Pine Labs processing needed)
  static Future<Map<String, dynamic>> doCashTransaction({
    required double amount,
    required String billingRefNo,
  }) async {
    // For cash transactions, we just record the transaction
    return {
      'success': true,
      'responseCode': AppConstants.responseCodeApproved,
      'responseMsg': 'CASH PAYMENT ACCEPTED',
      'billingRefNo': billingRefNo,
      'amount': amount,
      'paymentMethod': 'CASH',
      'approvalCode': 'CASH_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'transactionId': billingRefNo,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Void Transaction
  static Future<Map<String, dynamic>> voidTransaction({
    required String originalBillingRefNo,
    required String voidBillingRefNo,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024",
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1001",
          "VersionNo": "1.0"
        },
        "Detail": {
          "TransactionType": AppConstants.cardVoidTransaction.toString(),
          "BillingRefNo": voidBillingRefNo,
          "InvoiceNo": originalBillingRefNo,
        }
      };

      final result = await _channel.invokeMethod('doTransaction', request);
      return _parseTransactionResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Void Error: ${e.message}',
      };
    }
  }

  // Refund Transaction
  static Future<Map<String, dynamic>> refundTransaction({
    required double amount,
    required String billingRefNo,
    String? originalBillingRefNo,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024",
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1001",
          "VersionNo": "1.0"
        },
        "Detail": {
          "TransactionType": AppConstants.cardRefundTransaction.toString(),
          "BillingRefNo": billingRefNo,
          "PaymentAmount": (amount * 100).toInt(),
          if (originalBillingRefNo != null) "InvoiceNo": originalBillingRefNo,
        }
      };

      final result = await _channel.invokeMethod('doTransaction', request);
      return _parseTransactionResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Refund Error: ${e.message}',
      };
    }
  }

  // Print Receipt
  static Future<Map<String, dynamic>> printData({
    required String printRefNo,
    required List<Map<String, dynamic>> printData,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024",
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1002", // Print Data method ID
          "VersionNo": "1.0"
        },
        "Detail": {
          "PrintRefNo": printRefNo,
          "SavePrintData": true,
          "Data": printData,
        }
      };

      final result = await _channel.invokeMethod('printData', request);
      return _parsePrintResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': '1',
        'responseMsg': 'Print Error: ${e.message}',
      };
    }
  }

  // Read NFC Card - Real NFC operations
  static Future<Map<String, dynamic>> readCard() async {
    try {
      final result = await _channel.invokeMethod('readNfcCard');
      return _parseCardResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'NFC Read Error: ${e.message}',
      };
    }
  }

  // Write NFC Card - Real NFC operations
  static Future<Map<String, dynamic>> writeCard({
    required String uid,
    required double balance,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'uid': uid,
        'balance': balance,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
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

  // Settlement
  static Future<Map<String, dynamic>> settlement() async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          "ApplicationId": "EVENTPOS2024",
          "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
          "MethodId": "1003", // Settlement method ID
          "VersionNo": "1.0"
        }
      };

      final result = await _channel.invokeMethod('settlement', request);
      return _parseSettlementResponse(result);
    } on PlatformException catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Settlement Error: ${e.message}',
      };
    }
  }

  // Response Parsers - Parse Pine Labs APOS responses
  static Map<String, dynamic> _parseTransactionResponse(dynamic result) {
    try {
      final response = Map<String, dynamic>.from(result);
      final header = response['Header'] ?? {};
      final responseData = response['Response'] ?? {};
      final detail = response['Detail'] ?? {};

      final responseCode = responseData['ResponseCode']?.toString() ?? '96';
      final isSuccess = responseCode == '00' || responseCode == '0';

      return {
        'success': isSuccess,
        'responseCode': responseCode,
        'responseMsg': responseData['ResponseMsg'] ?? 'Unknown response',
        'billingRefNo': detail['BillingRefNo'] ?? '',
        'approvalCode': detail['ApprovalCode'] ?? '',
        'amount': detail['AmountProcessed'] ?? '',
        'cardNumber': detail['CardNumber'] ?? '',
        'cardType': detail['CardType'] ?? '',
        'transactionId': detail['InvoiceNumber']?.toString() ?? '',
        'merchantId': detail['MerchantId'] ?? '',
        'terminalId': detail['TerminalId'] ?? '',
        'transactionDate': detail['TransactionDate'] ?? '',
        'transactionTime': detail['TransactionTime'] ?? '',
        'retrievalReferenceNumber': detail['RetrievalReferenceNumber'] ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Response parsing error: $e',
      };
    }
  }

  static Map<String, dynamic> _parsePrintResponse(dynamic result) {
    try {
      final response = Map<String, dynamic>.from(result);
      final responseData = response['Response'] ?? {};
      
      final responseCode = responseData['ResponseCode']?.toString() ?? '1';
      final isSuccess = responseCode == '0';

      return {
        'success': isSuccess,
        'responseCode': responseCode,
        'responseMsg': responseData['ResponseMessage'] ?? 'Print failed',
      };
    } catch (e) {
      return {
        'success': false,
        'responseCode': '1',
        'responseMsg': 'Print parsing error: $e',
      };
    }
  }

  static Map<String, dynamic> _parseCardResponse(dynamic result) {
    try {
      final response = Map<String, dynamic>.from(result);
      
      return {
        'success': response['success'] ?? false,
        'responseCode': response['responseCode'] ?? AppConstants.responseCodeError,
        'responseMsg': response['message'] ?? 'Card operation failed',
        'uid': response['uid'] ?? '',
        'balance': response['balance']?.toDouble() ?? 0.0,
        'cardType': response['cardType'] ?? 'NFC_CARD',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Card response parsing error: $e',
      };
    }
  }

  static Map<String, dynamic> _parseSettlementResponse(dynamic result) {
    try {
      final response = Map<String, dynamic>.from(result);
      final responseData = response['Response'] ?? {};
      final detail = response['Detail'] ?? {};

      final responseCode = responseData['ResponseCode']?.toString() ?? '96';
      final isSuccess = responseCode == '00' || responseCode == '0';

      return {
        'success': isSuccess,
        'responseCode': responseCode,
        'responseMsg': responseData['ResponseMsg'] ?? 'Settlement failed',
        'settlementSummary': detail['SettlementSummary'] ?? [],
      };
    } catch (e) {
      return {
        'success': false,
        'responseCode': AppConstants.responseCodeError,
        'responseMsg': 'Settlement parsing error: $e',
      };
    }
  }

  // Utility method to create receipt print data
  static List<Map<String, dynamic>> createReceiptPrintData({
    required String title,
    required double amount,
    required String cardUid,
    required String billingRefNo,
    String? approvalCode,
    String? paymentMethod,
  }) {
    return [
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": true,
        "DataToPrint": "EVENT POS SYSTEM",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": true,
        "DataToPrint": "================================",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": true,
        "DataToPrint": title,
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Date: ${DateTime.now().toString().substring(0, 19)}",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Card UID: $cardUid",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Amount: ₹${amount.toStringAsFixed(2)}",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Ref No: $billingRefNo",
      },
      if (paymentMethod != null) {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Payment: $paymentMethod",
      },
      if (approvalCode != null) {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": false,
        "DataToPrint": "Approval: $approvalCode",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": true,
        "DataToPrint": "================================",
      },
      {
        "PrintDataType": AppConstants.printText,
        "PrinterWidth": 32,
        "IsCenterAligned": true,
        "DataToPrint": "Thank You!",
      },
    ];
  }
}
