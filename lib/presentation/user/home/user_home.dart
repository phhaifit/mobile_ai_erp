import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';

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

  Role? _findRoleById(int id) {
    return widget.roleStore.roleList
        .where((r) => r.id == id)
        .cast<Role?>()
        .firstOrNull;
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
          _buildUserTab(),
          _buildRoleTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreateUserDialog(context);
          } else {
            _showCreateRoleDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserTab() {
    return Observer(
      builder: (_) {
        if (widget.userStore.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.userStore.userList.length,
          itemBuilder: (_, index) {
            final user = widget.userStore.userList[index];
            final role = _findRoleById(user.roleId);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _StatusBox(
                          isActive: user.status == UserStatus.active,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(user.email),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(role?.name ?? 'No role'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showGrantRoleDialog(context, user),
                          child: const Text('Grant Role'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => widget.userStore.deleteUser(user.id),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGrantRoleDialog(BuildContext context, User user) {
    int? selectedRoleId = user.roleId;

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
                      return RadioListTile<int>(
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

  void _showCreateUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    int? selectedRoleId;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 16),
                    Observer(
                      builder: (_) {
                        return DropdownButtonFormField<int>(
                          hint: const Text('Select Role'),
                          value: selectedRoleId,
                          items: widget.roleStore.roleList.map((role) {
                            return DropdownMenuItem(
                              value: role.id,
                              child: Text(role.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRoleId = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRoleId == null) return;

                    final newUser = User(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      status: UserStatus.active,
                      roleId: selectedRoleId!,
                    );

                    widget.userStore.createUser(newUser);
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRoleTab() {
    return Observer(
      builder: (_) {
        if (widget.roleStore.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.roleStore.error != null) {
          return Center(child: Text(widget.roleStore.error!));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.roleStore.roleList.length,
          itemBuilder: (_, index) {
            final role = widget.roleStore.roleList[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          role.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role.description ?? 'No description',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => widget.roleStore.deleteRole(role.id),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Create Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Role name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newRole = Role(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text,
                  description: descController.text,
                );

                widget.roleStore.createRole(newRole);
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBox extends StatelessWidget {
  final bool isActive;

  const _StatusBox({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
