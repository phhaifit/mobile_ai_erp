// =============================
// MOCK DATASOURCES (ASYNC)
// =============================

import 'package:mobile_ai_erp/domain/entity/user/role.dart';

class RoleDataSource {
  final List<Role> _roles = [
    Role(id: '1', tenantId: 'default-tenant', name: 'Admin', description: 'Full access'),
    Role(id: '2', tenantId: 'default-tenant', name: 'Manager', description: 'Manage operations'),
    Role(id: '3', tenantId: 'default-tenant', name: 'Staff', description: 'Basic access'),
  ];

  Future<List<Role>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_roles);
  }

  Future<void> addRole(Role role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _roles.add(role);
  }

  Future<void> updateRole(Role updated) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _roles.indexWhere((r) => r.id == updated.id);
    if (index != -1) _roles[index] = updated;
  }

  Future<void> deleteRole(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _roles.removeWhere((r) => r.id == id);
  }
}
