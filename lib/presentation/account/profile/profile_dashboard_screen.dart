import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../utils/routes/routes.dart';
import '../store/profile_store.dart';
import '../store/loyalty_store.dart';
import '../widgets/loyalty_point_card.dart';
import '../../../../di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen> {
  // Fetch the store from DI
  final ProfileStore _profileStore = getIt<ProfileStore>();
  final LoyaltyStore _loyaltyStore = getIt<LoyaltyStore>();
  final CustomerAuthStore _authStore = getIt<CustomerAuthStore>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _profileStore.fetchProfile());
    Future.microtask(() => _loyaltyStore.fetchBalance());
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
                points: _loyaltyStore.balance, // 3. Use the LoyaltyStore balance
                onTap: () {
                  // 4. Navigate to the history screen when tapped!
                  Navigator.pushNamed(context, Routes.loyaltyHistory);
                },
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
            ),
            _buildMenuOption(
              context,
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your name and phone number',
              onTap: () => Navigator.pushNamed(context, Routes.profileEdit),
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _confirmLogout(context),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                // 1. Pop the confirmation dialog first (if this button is inside a dialog)
                Navigator.of(context).pop(); 

                // 2. Perform the logout
                await _authStore.logout();

                // 3. Check if the widget is still in the tree before navigating
                if (context.mounted) {
                  // 4. Wipe the navigation stack and push the login screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.customerLogin,
                    (Route<dynamic> route) => false, // This destroys all previous routes
                  );
                }
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      // Call the store to wipe data
      await _profileStore.logout();
      
      // Navigate back to the login screen and wipe the navigation stack so they can't press "Back"
      if (context.mounted) {
         // Assuming you have a Routes.login defined in your routes file
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }
    }
  }
}
