import 'package:flutter/material.dart';
import '../../../core/constants.dart';

enum PaymentMethod {
  card,
  upi,
  cash,
}

class PaymentMethodDialog extends StatefulWidget {
  final double amount;
  final Function(PaymentMethod) onPaymentMethodSelected;

  const PaymentMethodDialog({
    super.key,
    required this.amount,
    required this.onPaymentMethodSelected,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  PaymentMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Payment Method'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Amount: ₹${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentMethodTile(
            PaymentMethod.card,
            'Card Payment',
            'Credit/Debit Card via Pine Labs',
            Icons.credit_card,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodTile(
            PaymentMethod.upi,
            'UPI Payment',
            'UPI via Pine Labs',
            Icons.qr_code_scanner,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodTile(
            PaymentMethod.cash,
            'Cash Payment',
            'Cash payment',
            Icons.money,
            Colors.orange,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedMethod != null
              ? () {
                  Navigator.of(context).pop();
                  widget.onPaymentMethodSelected(_selectedMethod!);
                }
              : null,
          child: const Text('Proceed'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == method;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}
