import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: EmptyState(
            icon: Icons.warehouse_outlined,
            title: 'Inventory & Stock Control Placeholder',
            subtitle: 'Stock counts, stock receiving, and adjustments will be built in Prompt #2.',
          ),
        ),
      ),
    );
  }
}
