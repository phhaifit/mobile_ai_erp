import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';
import 'package:mobile_ai_erp/presentation/user/home/users_tab.dart';
import 'package:mobile_ai_erp/presentation/user/home/roles_tab.dart';

class UserManagementScreen extends StatefulWidget {
  final UserStore userStore;
  final RoleStore roleStore;

  const UserManagementScreen({
    super.key,
    required this.userStore,
    required this.roleStore,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    if (widget.userStore.userList.isEmpty) {
      widget.userStore.loadUsers();
    }

    if (widget.roleStore.roleList.isEmpty) {
      widget.roleStore.loadRoles();
    }

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Roles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UsersTab(
            userStore: widget.userStore,
            roleStore: widget.roleStore,
            onGrantRole: (user) => _showGrantRoleDialog(context, user),
          ),
          RolesTab(roleStore: widget.roleStore),
        ],
      ),
    );
  }

  void _showGrantRoleDialog(BuildContext context, User user) {
    String? selectedRoleId = user.roleId;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Role'),
              content: Observer(
                builder: (_) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.roleStore.roleList.map((role) {
                      return RadioListTile<String>(
                        title: Text(role.name),
                        value: role.id,
                        groupValue: selectedRoleId,
                        onChanged: (value) {
                          setState(() {
                            selectedRoleId = value;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRoleId != null) {
                      widget.userStore.assignRole(user.id, selectedRoleId!);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

    }