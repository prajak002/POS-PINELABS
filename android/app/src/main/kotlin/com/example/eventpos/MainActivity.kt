package com.example.eventpos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Bundle
import android.util.Log
import android.media.ToneGenerator
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch
import java.util.*

// Pine Labs POS Lib imports (add when you have the actual library)
// import com.pinelabs.poslib.PosLibManager
// import com.pinelabs.poslib.ConfigData
// import com.pinelabs.poslib.TransactionListener

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "com.pinelabs.pos/methods"
    private var nfcAdapter: NfcAdapter? = null
    private var methodChannel: MethodChannel? = null
    private var isListeningForCards = false
    
    // Pine Labs POS Lib manager (uncomment when you have the library)
    // private lateinit var posLibManager: PosLibManager
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                // Pine Labs Core APIs
                "posLibInitialize" -> handlePosLibInitialize(result)
                "setConfiguration" -> handleSetConfiguration(call.arguments, result)
                "doTransaction" -> handleDoTransaction(call.arguments, result)
                
                // Additional Pine Labs APIs
                "setBluetooth" -> handleSetBluetooth(call.arguments, result)
                "startScan" -> handleStartScan(call.arguments, result)
                "stopScan" -> handleStopScan(call.arguments, result)
                "printData" -> handlePrintData(call.arguments, result)
                "sendRequest" -> handleSendRequest(call.arguments, result)
                
                // NFC APIs
                "readNfcCard" -> handleNfcCardRead(result)
                "writeNfcCard" -> handleNfcCardWrite(call.arguments, result)
                "checkNfcStatus" -> handleNfcStatusCheck(result)
                
                else -> result.notImplemented()
            }
        }
        
        // Initialize components
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        // posLibManager = PosLibManager.getInstance()
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "Pine Labs POS app started")
    }
    
    // ================== PINE LABS POS LIB INTEGRATION ==================
    
    // Step 1: Initialize Pine Labs POS Library
    private fun handlePosLibInitialize(result: MethodChannel.Result) {
        try {
            Log.d("PosLib", "Initializing Pine Labs POS Library...")
            
            // TODO: Uncomment when you have Pine Labs POS Lib
            // val success = posLibManager.posLibInitialize(applicationContext)
            // Log.d("PosLib", "POS Lib initialization result: $success")
            
            // Mock response for now
            val success = true
            
            result.success(mapOf(
                "success" to success,
                "message" to if (success) "POS Lib initialized successfully" else "POS Lib initialization failed"
            ))
            
        } catch (e: Exception) {
            Log.e("PosLib", "POS Lib initialization error: ${e.message}")
            result.error("INIT_ERROR", e.message, null)
        }
    }
    
    // Step 2: Set Configuration for App2App Communication
    private fun handleSetConfiguration(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            Log.d("PosLib", "Setting Pine Labs configuration: $args")
            
            // TODO: Uncomment when you have Pine Labs POS Lib
            /*
            val configData = ConfigData().apply {
                commP1 = args?.get("commP1") as? Int ?: 3  // 3 = App2App mode
                isLogsEnabled = args?.get("isLogsEnabled") as? Boolean ?: true
                logLevel = args?.get("logLevel") as? Int ?: 1
                connectionTimeOut = args?.get("connectionTimeOut") as? Int ?: 30000
                retryCount = args?.get("retryCount") as? Int ?: 3
                isDemoMode = args?.get("isDemoMode") as? Boolean ?: false
            }
            
            val configResult = posLibManager.setConfiguration(configData, this)
            Log.d("PosLib", "Configuration result: $configResult")
            */
            
            // Mock response for now
            val configResult = 0 // 0 = Success
            
            result.success(mapOf(
                "result" to configResult,
                "message" to if (configResult == 0) "Configuration set successfully" else "Configuration failed"
            ))
            
        } catch (e: Exception) {
            Log.e("PosLib", "Configuration error: ${e.message}")
            result.error("CONFIG_ERROR", e.message, null)
        }
    }
    
    // Step 3: Main Transaction API (doTransaction)
    private fun handleDoTransaction(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val header = args?.get("Header") as? Map<String, Any>
            val detail = args?.get("Detail") as? Map<String, Any>
            
            Log.d("PosLib", "Processing transaction: $args")
            
            val transactionType = detail?.get("TransactionType") as? String ?: "4001"
            val billingRefNo = detail?.get("BillingRefNo") as? String ?: ""
            val paymentAmount = detail?.get("PaymentAmount") as? Int ?: 0
            
            // TODO: Uncomment when you have Pine Labs POS Lib
            /*
            val paymentRequest = buildPaymentRequest(transactionType, billingRefNo, paymentAmount)
            
            posLibManager.doTransaction(
                this,
                paymentRequest,
                6, // Payment transaction type
                object : TransactionListener {
                    override fun onSuccess(paymentResponse: String) {
                        Log.d("PosLib", "Transaction success: $paymentResponse")
                        val parsedResponse = parsePaymentResponse(paymentResponse)
                        result.success(parsedResponse)
                    }
                    
                    override fun onFailure(errorMsg: String, errorCode: Int) {
                        Log.e("PosLib", "Transaction failed: $errorMsg (Code: $errorCode)")
                        result.success(mapOf(
                            "Response" to mapOf(
                                "ResponseCode" to errorCode,
                                "ResponseMsg" to errorMsg
                            )
                        ))
                    }
                }
            )
            */
            
            // Mock successful response for now
            val mockResponse = createMockTransactionResponse(billingRefNo, paymentAmount)
            result.success(mockResponse)
            
        } catch (e: Exception) {
            Log.e("PosLib", "Transaction error: ${e.message}")
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 7,
                    "ResponseMsg" to "Transaction error: ${e.message}"
                )
            ))
        }
    }
    
    // Helper: Create mock transaction response
    private fun createMockTransactionResponse(billingRefNo: String, paymentAmount: Int): Map<String, Any> {
        return mapOf(
            "Response" to mapOf(
                "ResponseCode" to 0,
                "ResponseMsg" to "APPROVED"
            ),
            "Detail" to mapOf(
                "CardType" to "VISA",
                "CardNumber" to "************1234",
                "TransactionType" to 4001,
                "ApprovalCode" to "123456",
                "TransactionDate" to android.text.format.DateFormat.format("ddMMyyyy", Date()),
                "TransactionTime" to android.text.format.DateFormat.format("HHmmss", Date()),
                "HostResponse" to "APPROVED",
                "BillingRefNo" to billingRefNo,
                "PaymentAmount" to paymentAmount,
                "RetrievalReferenceNumber" to "000001234567",
                "MerchantId" to "MERCHANT123",
                "TerminalId" to "TERM001"
            )
        )
    }
    
    // Helper: Build payment request for Pine Labs
    private fun buildPaymentRequest(transactionType: String, billingRefNo: String, amount: Int): String {
        // Format: Pine Labs specific hex format
        // This is a simplified version - actual format depends on Pine Labs requirements
        val hexAmount = String.format("%08X", amount)
        val hexTxnType = String.format("%04X", transactionType.toInt())
        return "10000997001D$hexTxnType$billingRefNo$hexAmount"
    }
    
    // ================== ADDITIONAL PINE LABS APIs ==================
    
    // Step 4: Bluetooth Pairing
    private fun handleSetBluetooth(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val baseSerialNumber = args?.get("Detail")?.let { 
                (it as Map<String, Any>)["BaseSerialNumber"] 
            } as? String ?: ""
            
            Log.d("PosLib", "Setting Bluetooth for base: $baseSerialNumber")
            
            // Mock response
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 0,
                    "ResponseMsg" to "Bluetooth paired successfully"
                ),
                "Detail" to mapOf(
                    "BaseSerialNumber" to baseSerialNumber,
                    "Status" to "PAIRED"
                )
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 7,
                    "ResponseMsg" to "Bluetooth error: ${e.message}"
                )
            ))
        }
    }
    
    // Step 5: Start Scanning
    private fun handleStartScan(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val baseSerialNumber = args?.get("Detail")?.let { 
                (it as Map<String, Any>)["BaseSerialNumber"] 
            } as? String ?: ""
            
            Log.d("PosLib", "Starting scan for base: $baseSerialNumber")
            
            // Mock response
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 0,
                    "ResponseMsg" to "Scanning started"
                ),
                "Detail" to mapOf(
                    "BaseSerialNumber" to baseSerialNumber,
                    "ScanStatus" to "STARTED"
                )
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 7,
                    "ResponseMsg" to "Scan error: ${e.message}"
                )
            ))
        }
    }
    
    // Step 6: Stop Scanning
    private fun handleStopScan(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val baseSerialNumber = args?.get("Detail")?.let { 
                (it as Map<String, Any>)["BaseSerialNumber"] 
            } as? String ?: ""
            
            Log.d("PosLib", "Stopping scan for base: $baseSerialNumber")
            
            // Mock response
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 0,
                    "ResponseMsg" to "Scanning stopped"
                ),
                "Detail" to mapOf(
                    "BaseSerialNumber" to baseSerialNumber,
                    "ScanStatus" to "STOPPED"
                )
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 7,
                    "ResponseMsg" to "Stop scan error: ${e.message}"
                )
            ))
        }
    }
    
    // Step 7: Print Data
    private fun handlePrintData(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val detail = args?.get("Detail") as? Map<String, Any>
            val printData = detail?.get("Data") as? List<*>
            
            Log.d("PosLib", "Printing data: $printData")
            
            // Mock print response
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 0,
                    "ResponseMessage" to "Print successful"
                )
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 1,
                    "ResponseMessage" to "Print error: ${e.message}"
                )
            ))
        }
    }
    
    // Step 8: Send Raw Request
    private fun handleSendRequest(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val requestJson = args?.get("requestJson") as? String ?: ""
            
            Log.d("PosLib", "Sending raw request: $requestJson")
            
            // Mock response
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 0,
                    "ResponseMsg" to "Request processed successfully"
                ),
                "RawResponse" to requestJson
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "Response" to mapOf(
                    "ResponseCode" to 7,
                    "ResponseMsg" to "Send request error: ${e.message}"
                )
            ))
        }
    }
    
    // ================== NFC INTEGRATION ==================
    
    override fun onResume() {
        super.onResume()
        if (isListeningForCards) {
            enableNfcForegroundDispatch()
        }
    }
    
    override fun onPause() {
        super.onPause()
        disableNfcForegroundDispatch()
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (isListeningForCards) {
            handleNfcIntent(intent)
        }
    }
    
    private fun enableNfcForegroundDispatch() {
        if (nfcAdapter?.isEnabled == true) {
            val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
            nfcAdapter?.enableForegroundDispatch(this, pendingIntent, null, null)
        }
    }
    
    private fun disableNfcForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(this)
    }
    
    private fun handleNfcIntent(intent: Intent) {
        when (intent.action) {
            NfcAdapter.ACTION_TECH_DISCOVERED,
            NfcAdapter.ACTION_TAG_DISCOVERED,
            NfcAdapter.ACTION_NDEF_DISCOVERED -> {
                val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
                tag?.let { processNfcTag(it) }
            }
        }
    }
    
    private fun processNfcTag(tag: Tag) {
        lifecycleScope.launch {
            try {
                methodChannel?.invokeMethod("nfcScanStatus", "Reading card...")
                
                val isoDep = IsoDep.get(tag)
                isoDep?.let { 
                    val cardData = readEmvCardAdvanced(it)
                    
                    // Play success sound
                    playSuccessSound()
                    vibrateDevice()
                    
                    // Send result to Flutter
                    methodChannel?.invokeMethod("nfcCardRead", cardData)
                } ?: run {
                    val cardData = readSimpleNfcCard(tag)
                    methodChannel?.invokeMethod("nfcCardRead", cardData)
                }
                
            } catch (e: Exception) {
                Log.e("NFC", "Error processing NFC tag: ${e.message}")
                methodChannel?.invokeMethod("nfcCardError", mapOf(
                    "error" to e.message,
                    "success" to false,
                    "message" to "Failed to read card: ${e.message}",
                    "responseCode" to "96"
                ))
            }
        }
    }
    
    // Continue with remaining NFC methods...
    private fun readEmvCardAdvanced(isoDep: IsoDep): Map<String, Any> {
        // Implementation continues...
        return mapOf("success" to true, "uid" to "demo")
    }
    
    private fun readSimpleNfcCard(tag: Tag): Map<String, Any> {
        // Implementation continues...
        return mapOf("success" to true, "uid" to "demo")
    }
    
    private fun handleNfcCardRead(result: MethodChannel.Result) {
        // Implementation continues...
        result.success(mapOf("success" to true, "waiting" to true))
    }
    
    private fun handleNfcStatusCheck(result: MethodChannel.Result) {
        // Implementation continues...
        result.success(mapOf("isAvailable" to true, "isEnabled" to true))
    }
    
    private fun handleNfcCardWrite(arguments: Any?, result: MethodChannel.Result) {
        // Implementation continues...
        result.success(mapOf("success" to true))
    }
    
    private fun playSuccessSound() {}
    private fun vibrateDevice() {}
    private fun bytesToHex(bytes: ByteArray): String = ""
}
    
    override fun onResume() {
        super.onResume()
        enableNfcForegroundDispatch()
    }
    
    override fun onPause() {
        super.onPause()
        disableNfcForegroundDispatch()
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNfcIntent(intent)
    }
    
    private fun enableNfcForegroundDispatch() {
        if (nfcAdapter?.isEnabled == true) {
            val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
            nfcAdapter?.enableForegroundDispatch(this, pendingIntent, null, null)
        }
    }
    
    private fun disableNfcForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(this)
    }
    
    private fun handleNfcIntent(intent: Intent) {
        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action || 
            NfcAdapter.ACTION_TAG_DISCOVERED == intent.action ||
            NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            
            val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
            tag?.let { processNfcTag(it) }
        }
    }
    
    private fun processNfcTag(tag: Tag) {
        try {
            val isoDep = IsoDep.get(tag)
            isoDep?.let { 
                val cardData = readEmvCard(it)
                
                // Play success sound
                val tg = ToneGenerator(AudioManager.STREAM_ALARM, 100)
                tg.startTone(ToneGenerator.TONE_PROP_BEEP, 200)
                
                // Send result to Flutter
                methodChannel?.invokeMethod("nfcCardRead", cardData)
            }
        } catch (e: Exception) {
            Log.e("NFC", "Error processing NFC tag: ${e.message}")
            methodChannel?.invokeMethod("nfcCardError", mapOf(
                "error" to e.message,
                "success" to false
            ))
        }
    }
    
    private fun readEmvCard(isoDep: IsoDep): Map<String, Any> {
        try {
            isoDep.connect()
            
            // EMV card reading logic (simplified version)
            // This is a basic implementation - for production, you'd need full EMV protocol
            
            val uid = bytesToHex(isoDep.tag.id)
            
            // For demo purposes, we'll simulate card data
            // In real implementation, you'd parse EMV data from the card
            val cardData = mapOf(
                "success" to true,
                "uid" to uid,
                "cardNumber" to "**** **** **** ${uid.takeLast(4)}",
                "cardType" to "NFC_CARD",
                "balance" to 0.0,
                "message" to "Card read successfully",
                "responseCode" to "00"
            )
            
            isoDep.close()
            return cardData
            
        } catch (e: Exception) {
            Log.e("NFC", "Error reading EMV card: ${e.message}")
            return mapOf(
                "success" to false,
                "message" to "Failed to read card: ${e.message}",
                "responseCode" to "96"
            )
        }
    }
    
    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02x".format(it) }
    }
    
    // Pine Labs transaction handlers (mock implementations)
    private fun handlePineLabsTransaction(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val header = args?.get("Header") as? Map<String, Any>
            val detail = args?.get("Detail") as? Map<String, Any>
            
            // Mock Pine Labs response
            val response = mapOf(
                "Header" to mapOf(
                    "ApplicationId" to (header?.get("ApplicationId") ?: ""),
                    "MethodId" to (header?.get("MethodId") ?: "")
                ),
                "Response" to mapOf(
                    "ResponseCode" to "00",
                    "ResponseMsg" to "APPROVED"
                ),
                "Detail" to mapOf(
                    "BillingRefNo" to (detail?.get("BillingRefNo") ?: ""),
                    "ApprovalCode" to "123456",
                    "AmountProcessed" to (detail?.get("PaymentAmount") ?: 0),
                    "CardNumber" to "**** **** **** 1234",
                    "CardType" to "VISA",
                    "TransactionDate" to android.text.format.DateFormat.format("dd/MM/yyyy", Date()),
                    "TransactionTime" to android.text.format.DateFormat.format("HH:mm:ss", Date())
                )
            )
            
            result.success(response)
        } catch (e: Exception) {
            result.error("TRANSACTION_ERROR", e.message, null)
        }
    }
    
    private fun handleNfcCardRead(result: MethodChannel.Result) {
        if (nfcAdapter?.isEnabled != true) {
            result.success(mapOf(
                "success" to false,
                "message" to "NFC is not enabled",
                "responseCode" to "96"
            ))
            return
        }
        
        // For immediate response, return waiting state
        result.success(mapOf(
            "success" to true,
            "message" to "Ready to scan card. Please bring card near device.",
            "responseCode" to "00",
            "waiting" to true
        ))
    }
    
    private fun handleNfcCardWrite(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val uid = args?.get("uid") as? String ?: ""
            val balance = args?.get("balance") as? Double ?: 0.0
            
            // Mock NFC write response
            result.success(mapOf(
                "success" to true,
                "message" to "Card written successfully",
                "responseCode" to "00",
                "uid" to uid,
                "balance" to balance
            ))
        } catch (e: Exception) {
            result.error("NFC_WRITE_ERROR", e.message, null)
        }
    }
    
    private fun handlePrintData(arguments: Any?, result: MethodChannel.Result) {
        // Mock print response
        result.success(mapOf(
            "Response" to mapOf(
                "ResponseCode" to "0",
                "ResponseMessage" to "Print successful"
            )
        ))
    }
    
    private fun handleSettlement(arguments: Any?, result: MethodChannel.Result) {
        // Mock settlement response
        result.success(mapOf(
            "Response" to mapOf(
                "ResponseCode" to "00",
                "ResponseMsg" to "Settlement successful"
            ),
            "Detail" to mapOf(
                "SettlementSummary" to listOf<Map<String, Any>>()
            )
        ))
    }
}
