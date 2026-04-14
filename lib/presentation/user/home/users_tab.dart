import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';
import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/core/services/tenant_service.dart';

class UsersTab extends StatefulWidget {
  final UserStore userStore;
  final RoleStore roleStore;
  final VoidCallback onGrantRole;

  const UsersTab({
    super.key,
    required this.userStore,
    required this.roleStore,
    required this.onGrantRole,
  });

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  void initState() {
    super.initState();
    widget.userStore.loadUsers();
  }

  Role? _findRoleById(String? roleId) {
    if (roleId == null) return null;
    try {
      return widget.roleStore.roleList.firstWhere((role) => role.id == roleId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (widget.userStore.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.userStore.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userStore.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => widget.userStore.loadUsers(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateRoleDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create User'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                onPressed: () => widget.onGrantRole(),
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
              ),
            ),
          ],
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
            StatefulBuilder(
              builder: (context, setState) {
                return Observer(
                  builder: (_) {
                    return ElevatedButton(
                      onPressed: widget.roleStore.loading ? null : () async {
                        final tenantService = TenantService();
                        final tenantId = await tenantService.getCurrentTenantId();
                        
                        if (tenantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unable to get tenant ID')),
                          );
                          return;
                        }

                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a role name')),
                          );
                          return;
                        }

                        final newRole = Role(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          tenantId: tenantId,
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                        );

                        await widget.roleStore.createRole(newRole);
                        
                        if (widget.roleStore.error == null) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Role created successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.roleStore.error!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: widget.roleStore.loading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                    );
                  },
                );
              },
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
