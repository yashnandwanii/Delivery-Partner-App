import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        orderProvider.setToken(authProvider.token);
        orderProvider.loadAvailableOrders();
        orderProvider.loadMyOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Partner'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton(
                onSelected: (value) {
                  if (value == 'logout') {
                    authProvider.logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, OrderProvider>(
        builder: (context, authProvider, orderProvider, child) {
          if (!authProvider.isAuthenticated) {
            return const Center(child: Text('Please login to continue'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${authProvider.currentUser?.name ?? 'Partner'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${authProvider.currentUser?.status ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Deliveries: ${authProvider.currentUser?.totalDeliveries ?? 0}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Rating: ${authProvider.currentUser?.rating.toStringAsFixed(1) ?? '0.0'} ⭐',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => orderProvider.loadAvailableOrders(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Orders'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final newStatus =
                              authProvider.currentUser?.status == 'online'
                              ? 'offline'
                              : 'online';
                          authProvider.updateStatus(newStatus);
                        },
                        icon: Icon(
                          authProvider.currentUser?.status == 'online'
                              ? Icons.stop
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          authProvider.currentUser?.status == 'online'
                              ? 'Go Offline'
                              : 'Go Online',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Orders section
                Text(
                  'Available Orders',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: orderProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : orderProvider.availableOrders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No available orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: orderProvider.availableOrders.length,
                          itemBuilder: (context, index) {
                            final order = orderProvider.availableOrders[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  'Order #${order.id.substring(0, 8)}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Restaurant: ${order.restaurantName}'),
                                    Text(
                                      'Total: \$${order.grandTotal.toStringAsFixed(2)}',
                                    ),
                                    Text('Items: ${order.orderItems.length}'),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () =>
                                      orderProvider.acceptOrder(order.id),
                                  child: const Text('Accept'),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
