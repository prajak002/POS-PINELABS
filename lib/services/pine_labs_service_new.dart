import 'package:flutter/services.dart';
import '../core/constants.dart';
import 'nfc_card_service.dart';

// Pine Labs Response Models (following flutter_pinelabs structure)
class ResponseModel {
  final ResponseData response;
  final DetailData? detail;
  final String rawResponse;

  ResponseModel({
    required this.response,
    this.detail,
    required this.rawResponse,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      response: ResponseData.fromJson(json['Response'] ?? {}),
      detail: json['Detail'] != null ? DetailData.fromJson(json['Detail']) : null,
      rawResponse: json.toString(),
    );
  }
}

class ResponseData {
  final int responseCode;
  final String responseMsg;

  ResponseData({
    required this.responseCode,
    required this.responseMsg,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      responseCode: json['ResponseCode'] ?? 7,
      responseMsg: json['ResponseMsg'] ?? 'Unknown error',
    );
  }
}

class DetailData {
  final String? cardType;
  final String? cardNumber;
  final int? transactionType;
  final String? approvalCode;
  final String? transactionDate;
  final String? transactionTime;
  final String? hostResponse;
  final String? billingRefNo;
  final double? paymentAmount;

  DetailData({
    this.cardType,
    this.cardNumber,
    this.transactionType,
    this.approvalCode,
    this.transactionDate,
    this.transactionTime,
    this.hostResponse,
    this.billingRefNo,
    this.paymentAmount,
  });

  factory DetailData.fromJson(Map<String, dynamic> json) {
    return DetailData(
      cardType: json['CardType'],
      cardNumber: json['CardNumber'],
      transactionType: json['TransactionType'],
      approvalCode: json['ApprovalCode'],
      transactionDate: json['TransactionDate'],
      transactionTime: json['TransactionTime'],
      hostResponse: json['HostResponse'],
      billingRefNo: json['BillingRefNo'],
      paymentAmount: json['PaymentAmount']?.toDouble(),
    );
  }
}

class HeaderModel {
  final String applicationId;
  final String methodId;
  final String versionNo;
  final String userId;

  HeaderModel({
    required this.applicationId,
    required this.methodId,
    required this.versionNo,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ApplicationId': applicationId,
      'MethodId': methodId,
      'VersionNo': versionNo,
      'UserId': userId,
    };
  }
}

enum PosTransactionType {
  card,
  cash,
  upi,
  bharatqr,
}

class PineLabsService {
  static const MethodChannel _channel = MethodChannel(AppConstants.pineLabsChannel);
  static bool _isInitialized = false;

  // Initialize services following Pine Labs flow
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Step 1: Initialize POS Lib
      await _posLibInitialize();
      
      // Step 2: Set Configuration for App2App
      await _setConfiguration();
      
      // Step 3: Initialize NFC
      await NfcCardService.initialize();
      
      _isInitialized = true;
      print('Pine Labs POS Service initialized successfully');
    } catch (e) {
      print('Pine Labs initialization failed: $e');
      throw Exception('Failed to initialize Pine Labs: $e');
    }
  }

  // Step 1: Pine Labs POS Lib Initialization
  static Future<bool> _posLibInitialize() async {
    try {
      final result = await _channel.invokeMethod('posLibInitialize');
      
      if (result is Map) {
        return result['success'] == true;
      }
      return result == true;
    } on PlatformException catch (e) {
      print('POS Lib initialization error: ${e.message}');
      return false;
    }
  }

  // Step 2: Configuration for App2App mode
  static Future<bool> _setConfiguration() async {
    try {
      final configData = {
        'commP1': 3, // 3 = App2App mode (mandatory)
        'isLogsEnabled': true,
        'logLevel': 1,
        'connectionTimeOut': 30000,
        'retryCount': 3,
        'isDemoMode': false,
      };

      final result = await _channel.invokeMethod('setConfiguration', configData);
      final resultMap = result as Map?;
      return resultMap?['result'] == 0; // 0 = Success
    } on PlatformException catch (e) {
      print('Configuration error: ${e.message}');
      return false;
    }
  }

  // Step 3: Main Transaction API (doTransaction) - Core Pine Labs API
  static Future<ResponseModel> doTransaction({
    required PosTransactionType transactionType,
    required String billingRefNo,
    required double paymentAmount,
    HeaderModel? overrideHeader,
    String? mobileNumberForEChargeSlip,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Build request following Pine Labs structure
      final Map<String, dynamic> request = {
        "Header": overrideHeader?.toJson() ?? _getDefaultHeader(),
        "Detail": _buildTransactionDetail(
          transactionType: transactionType,
          billingRefNo: billingRefNo,
          paymentAmount: paymentAmount,
          mobileNumber: mobileNumberForEChargeSlip,
          additionalData: additionalData,
        ),
      };

      // Call native Pine Labs API
      final result = await _channel.invokeMethod('doTransaction', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Platform Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    } catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Transaction Failed: $e',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Helper: Default header for Pine Labs requests
  static Map<String, dynamic> _getDefaultHeader() {
    return {
      "ApplicationId": "fba2ad4fc55e41048ff6a1b9d2628395", // Your registered Pine Labs App ID
      "UserId": "USER_${DateTime.now().millisecondsSinceEpoch}",
      "MethodId": "1001", // DoTransaction method ID
      "VersionNo": "1.0"
    };
  }

  // Helper: Build transaction detail based on type
  static Map<String, dynamic> _buildTransactionDetail({
    required PosTransactionType transactionType,
    required String billingRefNo,
    required double paymentAmount,
    String? mobileNumber,
    Map<String, dynamic>? additionalData,
  }) {
    int txnTypeCode;
    switch (transactionType) {
      case PosTransactionType.card:
        txnTypeCode = AppConstants.cardSaleTransaction; // 4001
        break;
      case PosTransactionType.upi:
        txnTypeCode = AppConstants.upiSaleTransaction; // 5120
        break;
      case PosTransactionType.cash:
        txnTypeCode = 9999; // Custom cash type
        break;
      case PosTransactionType.bharatqr:
        txnTypeCode = 5130; // BharatQR
        break;
    }

    final detail = <String, dynamic>{
      "TransactionType": txnTypeCode.toString(),
      "BillingRefNo": billingRefNo,
      "PaymentAmount": (paymentAmount * 100).toInt(), // Amount in paise
    };

    if (transactionType != PosTransactionType.cash) {
      detail["IsSwipe"] = true;
    }

    if (mobileNumber != null) {
      detail["CustomerMobileNumber"] = mobileNumber;
    }

    if (additionalData != null) {
      for (final entry in additionalData.entries) {
        detail[entry.key] = entry.value;
      }
    }

    return detail;
  }

  // Step 4: UPI Status Check API
  static Future<ResponseModel> getUpiStatus({
    required String billingRefNo,
    required double paymentAmount,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": _getDefaultHeader(),
        "Detail": {
          "TransactionType": "5121", // UPI Status Check
          "BillingRefNo": billingRefNo,
          "PaymentAmount": (paymentAmount * 100).toInt(),
        }
      };

      final result = await _channel.invokeMethod('doTransaction', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'UPI Status Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Step 5: Bluetooth Pairing API
  static Future<ResponseModel> setBluetooth({
    required String baseSerialNumber,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": _getDefaultHeader(),
        "Detail": {
          "BaseSerialNumber": baseSerialNumber,
          "Action": "PAIR",
        }
      };

      final result = await _channel.invokeMethod('setBluetooth', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Bluetooth Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Step 6: Start Scanning API
  static Future<ResponseModel> startScan({
    required String baseSerialNumber,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": _getDefaultHeader(),
        "Detail": {
          "BaseSerialNumber": baseSerialNumber,
          "ScanAction": "START",
        }
      };

      final result = await _channel.invokeMethod('startScan', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Scan Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Step 7: Stop Scanning API
  static Future<ResponseModel> stopScan({
    required String baseSerialNumber,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": _getDefaultHeader(),
        "Detail": {
          "BaseSerialNumber": baseSerialNumber,
          "ScanAction": "STOP",
        }
      };

      final result = await _channel.invokeMethod('stopScan', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Stop Scan Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Step 8: Print Receipt API
  static Future<ResponseModel> printReceipt({
    required String printRequest,
    String? printRefNo,
  }) async {
    try {
      final Map<String, dynamic> request = {
        "Header": {
          ..._getDefaultHeader(),
          "MethodId": "1002", // Print Data method ID
        },
        "Detail": {
          "PrintRefNo": printRefNo ?? "PRINT_${DateTime.now().millisecondsSinceEpoch}",
          "SavePrintData": true,
          "Data": [
            {
              "PrintDataType": AppConstants.printText,
              "PrinterWidth": 32,
              "IsCenterAligned": true,
              "DataToPrint": printRequest,
            }
          ],
        }
      };

      final result = await _channel.invokeMethod('printData', request);
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Print Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Step 9: Send Raw JSON Request API
  static Future<ResponseModel> sendRequest({
    required String requestJson,
  }) async {
    try {
      final result = await _channel.invokeMethod('sendRequest', {
        'requestJson': requestJson,
      });
      return ResponseModel.fromJson(Map<String, dynamic>.from(result));

    } on PlatformException catch (e) {
      return ResponseModel(
        response: ResponseData(
          responseCode: 7,
          responseMsg: 'Send Request Error: ${e.message}',
        ),
        rawResponse: e.toString(),
      );
    }
  }

  // Legacy method for backward compatibility (amount parameter)
  static Future<Map<String, dynamic>> doTransactionLegacy({
    required double amount,
    required String billingRefNo,
    int transactionType = 4001,
    Map<String, dynamic>? additionalData,
    String? customerMobile,
    String? customerEmail,
  }) async {
    PosTransactionType type;
    switch (transactionType) {
      case 4001:
        type = PosTransactionType.card;
        break;
      case 5120:
        type = PosTransactionType.upi;
        break;
      case 9999:
        type = PosTransactionType.cash;
        break;
      default:
        type = PosTransactionType.card;
    }

    final response = await doTransaction(
      transactionType: type,
      billingRefNo: billingRefNo,
      paymentAmount: amount,
      mobileNumberForEChargeSlip: customerMobile,
      additionalData: additionalData,
    );

    return {
      'success': response.response.responseCode == 0,
      'responseCode': response.response.responseCode,
      'responseMsg': response.response.responseMsg,
      'billingRefNo': response.detail?.billingRefNo ?? billingRefNo,
      'approvalCode': response.detail?.approvalCode ?? '',
      'amount': amount,
      'cardNumber': response.detail?.cardNumber ?? '',
      'cardType': response.detail?.cardType ?? '',
      'transactionId': response.detail?.billingRefNo ?? '',
      'merchantId': '',
      'terminalId': '',
      'transactionDate': response.detail?.transactionDate ?? '',
      'transactionTime': response.detail?.transactionTime ?? '',
      'retrievalReferenceNumber': '',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Legacy print method for backward compatibility
  static Future<Map<String, dynamic>> printData({
    required String printRefNo,
    required List<Map<String, dynamic>> printData,
  }) async {
    final response = await printReceipt(
      printRequest: printData.map((e) => e['DataToPrint'] ?? '').join('\n'),
      printRefNo: printRefNo,
    );

    return {
      'success': response.response.responseCode == 0,
      'responseCode': response.response.responseCode.toString(),
      'responseMsg': response.response.responseMsg,
    };
  }

  // NFC Integration
  static Future<Map<String, dynamic>> readCard({
    Function(Map<String, dynamic>)? onCardRead,
    Function(String)? onStatusUpdate,
  }) async {
    return await NfcCardService.startCardScan(
      onCardRead: onCardRead,
      onStatusUpdate: onStatusUpdate,
    );
  }

  static void stopCardScan() {
    NfcCardService.stopCardScan();
  }

  static bool get isScanning => NfcCardService.isScanning;

  static Future<Map<String, dynamic>> writeCard({
    required String uid,
    required double balance,
    Map<String, dynamic>? additionalData,
  }) async {
    return await NfcCardService.writeCard(
      uid: uid,
      balance: balance,
      additionalData: additionalData,
    );
  }

  static Future<Map<String, dynamic>> checkNfcStatus() async {
    return await NfcCardService.checkNfcStatus();
  }
}
