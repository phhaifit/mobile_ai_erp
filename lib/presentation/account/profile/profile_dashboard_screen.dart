import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../utils/routes/routes.dart';
import '../store/profile_store.dart';
import '../widgets/loyalty_point_card.dart';
import '../../../../di/service_locator.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen> {
  // Fetch the store from DI
  final ProfileStore _profileStore = getIt<ProfileStore>();

  @override
  void initState() {
    super.initState();
    _profileStore.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            Observer(
              builder: (_) => LoyaltyPointCard(
                points: _profileStore.loyaltyPoints,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context,
              icon: Icons.location_on_outlined,
              title: 'Address Book',
              subtitle: 'Manage your shipping addresses',
              onTap: () => Navigator.pushNamed(context, Routes.addressBook),
            ),
            _buildMenuOption(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Order History',
              subtitle: 'Track, return, or buy again',
              onTap: () => Navigator.pushNamed(context, Routes.orderHistory),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Observer(
      builder: (_) => Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            // FIX: Safely check if the name is loaded before cutting the string
            child: Text(
              _profileStore.userName.isNotEmpty 
                  ? _profileStore.userName.substring(0, 1).toUpperCase() 
                  : '?', // Shows a question mark while loading
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIX: Add a fallback for empty text
                Text(
                  _profileStore.userName.isNotEmpty ? _profileStore.userName : 'Loading...',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileStore.userEmail,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileStore.userPhone,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue.shade700),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
