import 'package:flutter/material.dart';
import '../models/delivery_order.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onAccept;
  final VoidCallback? onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Restaurant info
            Row(
              children: [
                const Icon(Icons.store, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Customer info
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerName.isEmpty
                        ? 'Customer'
                        : order.customerName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Distance and earnings (placeholder for now)
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '${_calculateDistance().toStringAsFixed(1)} km away',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.monetization_on,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Est. \$${_calculateEarnings().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.orderItems.length} items',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${order.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFFC6011),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (order.orderItems.isNotEmpty) ...[
                    Text(
                      _getOrderItemsText(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (onViewDetails != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      child: const Text('View Details'),
                    ),
                  ),
                if (onViewDetails != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: order.orderStatus == 'pending' ? onAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFC6011),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _getActionButtonText(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.orderStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getActionButtonText() {
    switch (order.orderStatus.toLowerCase()) {
      case 'pending':
        return 'Accept Order';
      case 'accepted':
        return 'Pick Up';
      case 'picked_up':
        return 'Deliver';
      case 'delivered':
        return 'Completed';
      default:
        return 'View Order';
    }
  }

  String _getOrderItemsText() {
    if (order.orderItems.isEmpty) return '';

    final firstTwoItems = order.orderItems
        .take(2)
        .map((item) => '${item.quantity}x ${item.foodName}')
        .join(', ');

    if (order.orderItems.length > 2) {
      return '$firstTwoItems +${order.orderItems.length - 2} more';
    }

    return firstTwoItems;
  }

  double _calculateDistance() {
    // Placeholder calculation - in real app, use user's location
    // and restaurant/delivery addresses
    return 2.5 + (order.grandTotal / 10); // Mock calculation
  }

  double _calculateEarnings() {
    // Simple earnings calculation based on order value and distance
    final baseEarning = 3.00;
    final distanceBonus = _calculateDistance() * 0.50;
    final orderValueBonus = order.grandTotal * 0.05;

    return baseEarning + distanceBonus + orderValueBonus;
  }
}
