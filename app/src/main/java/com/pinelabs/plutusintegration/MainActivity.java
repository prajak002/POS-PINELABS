package com.pinelabs.plutusintegration;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.pinelabs.plutusintegration.constants.PlutusConstants;
import com.pinelabs.plutusintegration.models.TransactionRequest;
import com.pinelabs.plutusintegration.utils.JsonHelper;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "MainActivity";
    
    private EditText etAmount, etBillingRefNo;
    private Button btnCardSale, btnUpiSale, btnPrintData, btnSettlement, btnGetTerminalInfo;
    private TextView tvResponse;
    
    private Messenger mServerMessenger;
    private boolean isBound = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initViews();
        bindToPlutusService();
    }

    private void initViews() {
        etAmount = findViewById(R.id.et_amount);
        etBillingRefNo = findViewById(R.id.et_billing_ref_no);
        btnCardSale = findViewById(R.id.btn_card_sale);
        btnUpiSale = findViewById(R.id.btn_upi_sale);
        btnPrintData = findViewById(R.id.btn_print_data);
        btnSettlement = findViewById(R.id.btn_settlement);
        btnGetTerminalInfo = findViewById(R.id.btn_get_terminal_info);
        tvResponse = findViewById(R.id.tv_response);

        btnCardSale.setOnClickListener(this);
        btnUpiSale.setOnClickListener(this);
        btnPrintData.setOnClickListener(this);
        btnSettlement.setOnClickListener(this);
        btnGetTerminalInfo.setOnClickListener(this);
    }

    private void bindToPlutusService() {
        Intent intent = new Intent();
        intent.setAction(PlutusConstants.PLUTUS_SMART_ACTION);
        intent.setPackage(PlutusConstants.PLUTUS_SMART_PACKAGE);
        bindService(intent, connection, BIND_AUTO_CREATE);
    }

    private ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mServerMessenger = new Messenger(service);
            isBound = true;
            Log.d(TAG, "Service connected");
            Toast.makeText(MainActivity.this, "Connected to Plutus Smart", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mServerMessenger = null;
            isBound = false;
            Log.d(TAG, "Service disconnected");
        }
    };

    @Override
    public void onClick(View v) {
        if (!isBound) {
            Toast.makeText(this, "Not connected to Plutus Smart", Toast.LENGTH_SHORT).show();
            return;
        }

        int id = v.getId();
        if (id == R.id.btn_card_sale) {
            performCardSale();
        } else if (id == R.id.btn_upi_sale) {
            performUpiSale();
        } else if (id == R.id.btn_print_data) {
            performPrintData();
        } else if (id == R.id.btn_settlement) {
            performSettlement();
        } else if (id == R.id.btn_get_terminal_info) {
            getTerminalInfo();
        }
    }

    private void performCardSale() {
        String amount = etAmount.getText().toString().trim();
        String billingRef = etBillingRefNo.getText().toString().trim();
        
        if (amount.isEmpty()) {
            Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show();
            return;
        }

        TransactionRequest request = new TransactionRequest();
        request.setTransactionType(4001); // Card Sale
        request.setPaymentAmount(Long.parseLong(amount) * 100); // Convert to paise
        request.setBillingRefNo(billingRef.isEmpty() ? "TXN" + System.currentTimeMillis() : billingRef);

        sendRequest(JsonHelper.createDoTransactionRequest(request), PlutusConstants.METHOD_ID_DO_TRANSACTION);
    }

    private void performUpiSale() {
        String amount = etAmount.getText().toString().trim();
        String billingRef = etBillingRefNo.getText().toString().trim();
        
        if (amount.isEmpty()) {
            Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show();
            return;
        }

        TransactionRequest request = new TransactionRequest();
        request.setTransactionType(5120); // UPI Sale
        request.setPaymentAmount(Long.parseLong(amount) * 100); // Convert to paise
        request.setBillingRefNo(billingRef.isEmpty() ? "UPI" + System.currentTimeMillis() : billingRef);

        sendRequest(JsonHelper.createDoTransactionRequest(request), PlutusConstants.METHOD_ID_DO_TRANSACTION);
    }

    private void performPrintData() {
        String printRequest = JsonHelper.createPrintDataRequest("Sample Receipt Data");
        sendRequest(printRequest, PlutusConstants.METHOD_ID_PRINT_DATA);
    }

    private void performSettlement() {
        String settlementRequest = JsonHelper.createSettlementRequest();
        sendRequest(settlementRequest, PlutusConstants.METHOD_ID_SETTLEMENT);
    }

    private void getTerminalInfo() {
        String terminalInfoRequest = JsonHelper.createGetTerminalInfoRequest();
        sendRequest(terminalInfoRequest, PlutusConstants.METHOD_ID_GET_TERMINAL_INFO);
    }

    private void sendRequest(String jsonRequest, String methodId) {
        if (!isBound || mServerMessenger == null) {
            Toast.makeText(this, "Service not connected", Toast.LENGTH_SHORT).show();
            return;
        }

        Message message = Message.obtain(null, PlutusConstants.MESSAGE_CODE);
        Bundle data = new Bundle();
        data.putString(PlutusConstants.BILLING_REQUEST_TAG, jsonRequest);
        message.setData(data);
        message.replyTo = new Messenger(new IncomingHandler());

        try {
            mServerMessenger.send(message);
            tvResponse.setText("Request sent. Waiting for response...");
        } catch (RemoteException e) {
            e.printStackTrace();
            Toast.makeText(this, "Failed to send request", Toast.LENGTH_SHORT).show();
        }
    }

    private class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            Bundle bundle = msg.getData();
            String response = bundle.getString(PlutusConstants.BILLING_RESPONSE_TAG);
            
            runOnUiThread(() -> {
                tvResponse.setText(response != null ? response : "No response received");
                Log.d(TAG, "Response: " + response);
            });
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (isBound) {
            unbindService(connection);
            isBound = false;
        }
    }
}
