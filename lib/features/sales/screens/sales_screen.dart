import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'New Sale',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('POS checkout workflow will be added in Prompt #2.'),
                ),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Sales & Billing Placeholder',
            subtitle: 'Point of sale, receipts, and payment processing (Cash, EVC Plus, Zaad, Sahal) will be added in Prompt #2.',
          ),
        ),
      ),
    );
  }
}
