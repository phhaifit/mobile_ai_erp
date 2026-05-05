import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../di/service_locator.dart';
import '../store/loyalty_store.dart';

class LoyaltyHistoryScreen extends StatefulWidget {
  const LoyaltyHistoryScreen({super.key});

  @override
  State<LoyaltyHistoryScreen> createState() => _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends State<LoyaltyHistoryScreen> {
  final LoyaltyStore _loyaltyStore = getIt<LoyaltyStore>();

  @override
  void initState() {
    super.initState();
    _loyaltyStore.fetchBalance();
    _loyaltyStore.fetchHistory(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points History'),
        elevation: 0,
      ),
      body: Observer(
        builder: (_) {
          if (_loyaltyStore.isLoading && _loyaltyStore.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Balance Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    const Text('Current Balance', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_loyaltyStore.balance}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              
              // History List
              Expanded(
                child: _loyaltyStore.history.isEmpty
                    ? const Center(child: Text('No point history found.'))
                    : ListView.separated(
                        itemCount: _loyaltyStore.history.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _loyaltyStore.history[index];
                          final isPositive = item.points > 0;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                isPositive ? Icons.add_circle : Icons.remove_circle,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(item.reason, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              // Just formatting the date simply
                              item.createdAt.toString().substring(0, 10),
                            ),
                            trailing: Text(
                              '${isPositive ? '+' : ''}${item.points}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}