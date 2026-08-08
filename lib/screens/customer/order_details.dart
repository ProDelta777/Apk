import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String orderStatus; // e.g., 'delivered'

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    required this.orderStatus,
  }) : super(key: key);

  void _requestReturn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String reason = "";
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Return/Exchange', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Reason for return'),
                onChanged: (val) => reason = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Calls Supabase to insert a record into the `returns` table
                  // Supabase Realtime sends a notification to the Shopkeeper
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Return requested. The shopkeeper will review it shortly.')),
                  );
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text('Submit Request'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #$orderId')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${orderStatus.toUpperCase()}',
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            const ListTile(
              title: Text('Aashirvaad Atta 5kg'),
              trailing: Text('1 x ₹250.00'),
            ),
            const ListTile(
              title: Text('Tata Salt 1kg'),
              trailing: Text('2 x ₹25.00'),
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹300.00', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            if (orderStatus == 'delivered')
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment_return),
                label: const Text('Request Return / Exchange'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _requestReturn(context),
              ),
          ],
        ),
      ),
    );
  }
}
