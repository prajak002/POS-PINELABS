// Advanced EMV Card Reader for Android
// This file contains the enhanced Kotlin implementation 
// Based on the article's approach for reading EMV cards

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
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
import java.nio.ByteBuffer

class AdvancedMainActivity : FlutterFragmentActivity() {
    
    private val CHANNEL = "com.pinelabs.pos/methods"
    private var nfcAdapter: NfcAdapter? = null
    private var methodChannel: MethodChannel? = null
    private var isListeningForCards = false
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "doTransaction" -> handlePineLabsTransaction(call.arguments, result)
                "readNfcCard" -> handleNfcCardRead(result)
                "writeNfcCard" -> handleNfcCardWrite(call.arguments, result)
                "checkNfcStatus" -> handleNfcStatusCheck(result)
                "printData" -> handlePrintData(call.arguments, result)
                "settlement" -> handleSettlement(call.arguments, result)
                else -> result.notImplemented()
            }
        }
        
        // Initialize NFC
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if NFC is available
        if (nfcAdapter == null) {
            Log.e("NFC", "NFC is not available on this device")
        }
    }
    
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
                // Update status
                methodChannel?.invokeMethod("nfcScanStatus", "Reading card...")
                
                val isoDep = IsoDep.get(tag)
                isoDep?.let { 
                    val cardData = readEmvCardAdvanced(it)
                    
                    // Play success sound
                    playSuccessSound()
                    
                    // Vibrate device
                    vibrateDevice()
                    
                    // Send result to Flutter
                    methodChannel?.invokeMethod("nfcCardRead", cardData)
                } ?: run {
                    // Try other NFC technologies
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
    
    private fun readEmvCardAdvanced(isoDep: IsoDep): Map<String, Any> {
        try {
            isoDep.connect()
            Log.d("NFC", "Connected to EMV card")
            
            // EMV Application Selection (as per article)
            val aidCommand = byteArrayOf(
                0x00.toByte(), 0xA4.toByte(), 0x04.toByte(), 0x00.toByte(), // SELECT command
                0x07.toByte(), // Length of AID
                0xA0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x00.toByte(), // Visa AID
                0x03.toByte(), 0x10.toByte(), 0x10.toByte()
            )
            
            val aidResponse = isoDep.transceive(aidCommand)
            Log.d("NFC", "AID Response: ${bytesToHex(aidResponse)}")
            
            // Get Processing Options
            val gpoCommand = byteArrayOf(
                0x80.toByte(), 0xA8.toByte(), 0x00.toByte(), 0x00.toByte(),
                0x02.toByte(), 0x83.toByte(), 0x00.toByte()
            )
            
            val gpoResponse = isoDep.transceive(gpoCommand)
            Log.d("NFC", "GPO Response: ${bytesToHex(gpoResponse)}")
            
            // Read Application Data
            var cardNumber = ""
            var expiryDate = ""
            
            // Try to read record files (simplified approach)
            for (sfi in 1..10) {
                for (record in 1..16) {
                    try {
                        val readCommand = byteArrayOf(
                            0x00.toByte(), 0xB2.toByte(), record.toByte(),
                            (sfi shl 3 or 4).toByte(), 0x00.toByte()
                        )
                        
                        val recordResponse = isoDep.transceive(readCommand)
                        
                        if (recordResponse.size > 2 && 
                            recordResponse[recordResponse.size - 2] == 0x90.toByte() &&
                            recordResponse[recordResponse.size - 1] == 0x00.toByte()) {
                            
                            val recordData = recordResponse.sliceArray(0..recordResponse.size - 3)
                            
                            // Parse record for PAN and expiry date
                            val parsedData = parseEmvRecord(recordData)
                            if (parsedData["pan"]?.isNotEmpty() == true) {
                                cardNumber = parsedData["pan"] ?: ""
                            }
                            if (parsedData["expiryDate"]?.isNotEmpty() == true) {
                                expiryDate = parsedData["expiryDate"] ?: ""
                            }
                        }
                    } catch (e: Exception) {
                        // Continue to next record
                    }
                    
                    if (cardNumber.isNotEmpty() && expiryDate.isNotEmpty()) {
                        break
                    }
                }
                if (cardNumber.isNotEmpty() && expiryDate.isNotEmpty()) {
                    break
                }
            }
            
            val uid = bytesToHex(isoDep.tag.id)
            isoDep.close()
            
            return mapOf(
                "success" to true,
                "uid" to uid,
                "cardNumber" to if (cardNumber.isNotEmpty()) formatCardNumber(cardNumber) else "**** **** **** ${uid.takeLast(4)}",
                "expiryDate" to expiryDate,
                "cardType" to "EMV_CARD",
                "balance" to 0.0,
                "message" to "EMV card read successfully",
                "responseCode" to "00",
                "rawPan" to cardNumber,
                "aidResponse" to bytesToHex(aidResponse),
                "gpoResponse" to bytesToHex(gpoResponse)
            )
            
        } catch (e: Exception) {
            Log.e("NFC", "Error reading EMV card: ${e.message}")
            return mapOf(
                "success" to false,
                "message" to "Failed to read EMV card: ${e.message}",
                "responseCode" to "96"
            )
        }
    }
    
    private fun readSimpleNfcCard(tag: Tag): Map<String, Any> {
        try {
            val uid = bytesToHex(tag.id)
            
            return mapOf(
                "success" to true,
                "uid" to uid,
                "cardNumber" to "**** **** **** ${uid.takeLast(4)}",
                "cardType" to "NFC_CARD",
                "balance" to 0.0,
                "message" to "NFC card read successfully",
                "responseCode" to "00"
            )
            
        } catch (e: Exception) {
            return mapOf(
                "success" to false,
                "message" to "Failed to read NFC card: ${e.message}",
                "responseCode" to "96"
            )
        }
    }
    
    private fun parseEmvRecord(data: ByteArray): Map<String, String> {
        val result = mutableMapOf<String, String>()
        
        try {
            var i = 0
            while (i < data.size) {
                if (i + 1 >= data.size) break
                
                val tag = data[i]
                val length = data[i + 1].toInt() and 0xFF
                
                if (i + 2 + length > data.size) break
                
                val value = data.sliceArray(i + 2 until i + 2 + length)
                
                when (tag.toInt() and 0xFF) {
                    0x5A -> { // Application Primary Account Number (PAN)
                        result["pan"] = bytesToNumericString(value)
                    }
                    0x5F, 0x24 -> { // Application Expiration Date
                        if (value.size >= 3) {
                            val expiry = bytesToHex(value.sliceArray(0..2))
                            if (expiry.length >= 4) {
                                result["expiryDate"] = "${expiry.substring(2, 4)}/${expiry.substring(0, 2)}"
                            }
                        }
                    }
                }
                
                i += 2 + length
            }
        } catch (e: Exception) {
            Log.e("EMV", "Error parsing EMV record: ${e.message}")
        }
        
        return result
    }
    
    private fun bytesToNumericString(bytes: ByteArray): String {
        val hex = bytesToHex(bytes)
        return hex.replace("F", "").replace("f", "") // Remove padding
    }
    
    private fun formatCardNumber(cardNumber: String): String {
        return cardNumber.chunked(4).joinToString(" ")
    }
    
    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02x".format(it) }
    }
    
    private fun playSuccessSound() {
        try {
            val tg = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
            tg.startTone(ToneGenerator.TONE_PROP_BEEP, 200)
        } catch (e: Exception) {
            Log.e("SOUND", "Error playing sound: ${e.message}")
        }
    }
    
    private fun vibrateDevice() {
        try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(100)
            }
        } catch (e: Exception) {
            Log.e("VIBRATE", "Error vibrating device: ${e.message}")
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
        
        isListeningForCards = true
        enableNfcForegroundDispatch()
        
        result.success(mapOf(
            "success" to true,
            "message" to "Ready to scan card. Please bring card near device.",
            "responseCode" to "00",
            "waiting" to true
        ))
    }
    
    private fun handleNfcStatusCheck(result: MethodChannel.Result) {
        val isAvailable = nfcAdapter != null
        val isEnabled = nfcAdapter?.isEnabled == true
        
        result.success(mapOf(
            "isAvailable" to isAvailable,
            "isEnabled" to isEnabled,
            "message" to when {
                !isAvailable -> "NFC not available on this device"
                !isEnabled -> "NFC is disabled. Please enable in settings."
                else -> "NFC is ready"
            }
        ))
    }
    
    private fun handleNfcCardWrite(arguments: Any?, result: MethodChannel.Result) {
        try {
            val args = arguments as? Map<String, Any>
            val uid = args?.get("uid") as? String ?: ""
            val balance = args?.get("balance") as? Double ?: 0.0
            
            // For demo purposes - in real implementation, you'd write to NDEF or specific sectors
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
    
    // Mock Pine Labs handlers (same as before)
    private fun handlePineLabsTransaction(arguments: Any?, result: MethodChannel.Result) {
        // ... (same implementation as in previous MainActivity)
    }
    
    private fun handlePrintData(arguments: Any?, result: MethodChannel.Result) {
        // ... (same implementation as in previous MainActivity)
    }
    
    private fun handleSettlement(arguments: Any?, result: MethodChannel.Result) {
        // ... (same implementation as in previous MainActivity)
    }
}
