import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CustomerManagementHomeScreen extends StatefulWidget {
  const CustomerManagementHomeScreen({super.key});

  @override
  State<CustomerManagementHomeScreen> createState() =>
      _CustomerManagementHomeScreenState();
}

class _CustomerManagementHomeScreenState
    extends State<CustomerManagementHomeScreen> {
  final CustomerStore _store = getIt<CustomerStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              CustomerSectionCard(
                title: 'Customers',
                description:
                    'View and manage all customer profiles and contacts.',
                countLabel: '${_store.customers.length} customers',
                icon: Icons.people_outline,
                onTap: () => CustomerNavigator.openCustomers(context),
              ),
              CustomerSectionCard(
                title: 'Customer Groups',
                description:
                    'Organize customers into segments for targeted actions.',
                countLabel: '${_store.groups.length} groups',
                icon: Icons.group_work_outlined,
                onTap: () => CustomerNavigator.openGroups(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
