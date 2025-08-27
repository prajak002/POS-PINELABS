class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://kiis0e7lfj.execute-api.ap-south-1.amazonaws.com/uat';
  static const String loginEndpoint = '/login';
  static const String menuEndpoint = '/menu';
  static const String menuAllEndpoint = '/menu/all';
  static const String syncBatchEndpoint = '/sync-batch';

  // User Roles
  static const String topupUserRole = 'topup_user';
  static const String stallUserRole = 'stall_user';

  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userRoleKey = 'user_role';
  static const String usernameKey = 'username';

  // Hive Box Names
  static const String transactionsBox = 'transactions';
  static const String menuBox = 'menu';
  static const String cardsBox = 'cards';
  static const String ordersBox = 'orders';

  // Pine Labs Constants
  static const String pineLabsChannel = 'com.pinelabs.pos/methods';

  // Transaction Types (as per Plutus APOS documentation)
  static const int cardSaleTransaction = 4001;
  static const int cardVoidTransaction = 4006;
  static const int cardRefundTransaction = 4002;
  static const int upiSaleTransaction = 5120;
  static const int settlementTransaction = 4501;
  static const int getLastTransactionStatus = 4101;

  // Pine Labs Response Codes
  static const String responseCodeApproved = '00';
  static const String responseCodeDeclined = '05';
  static const String responseCodeError = '96';

  // Print Data Types
  static const int printText = 0;
  static const int printImageByPath = 1;
  static const int printImageDump = 2;
  static const int printBarcode = 3;
  static const int printQRCode = 4;

  // Billing Reference Number Prefixes
  static const String issueCardPrefix = 'ISSUE_';
  static const String topupPrefix = 'TOPUP_';
  static const String paymentPrefix = 'PAYMENT_';
  static const String refundPrefix = 'REFUND_';
  static const String orderPrefix = 'ORDER_';
}

class ApiEndpoints {
  static const String login = AppConstants.loginEndpoint;
  static const String menu = AppConstants.menuEndpoint;
  static const String syncBatch = AppConstants.syncBatchEndpoint;
}

class HiveBoxes {
  static const String transactions = AppConstants.transactionsBox;
  static const String menu = AppConstants.menuBox;
  static const String cards = AppConstants.cardsBox;
}
