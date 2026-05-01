import 'package:mobile_ai_erp/domain/entity/user/user.dart';

class UserDataSource {
  final List<User> _users = [
    User(
      id: '1',
      tenantId: 'tenant_1',
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      roleId: '1',
      isActive: true,
    ),
    User(
      id: '2',
      tenantId: 'tenant_1',
      name: 'Jane Smith',
      email: 'jane@example.com',
      password: 'password123',
      roleId: '2',
      isActive: true,
    ),
    User(
      id: '3',
      tenantId: 'tenant_1',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      password: 'password123',
      roleId: '3',
      isActive: false,
    ),
    User(
      id: '4',
      tenantId: 'tenant_1',
      name: 'Bob Brown',
      email: 'bob@example.com',
      password: 'password123',
      roleId: '1',
      isActive: true,
    ),
    User(
      id: '5',
      tenantId: 'tenant_1',
      name: 'Charlie Davis',
      email: 'charlie@example.com',
      password: 'password123',
      roleId: '2',
      isActive: false,
    ),
    User(
      id: '6',
      tenantId: 'tenant_1',
      name: 'Diana Evans',
      email: 'diana@example.com',
      password: 'password123',
      roleId: '3',
      isActive: true,
    ),
    User(
      id: '7',
      tenantId: 'tenant_1',
      name: 'Ethan Wilson',
      email: 'ethan@example.com',
      password: 'password123',
      roleId: '1',
      isActive: true,
    ),
    User(
      id: '8',
      tenantId: 'tenant_1',
      name: 'Fiona Taylor',
      email: 'fiona@example.com',
      password: 'password123',
      roleId: '2',
      isActive: false,
    ),
    User(
      id: '9',
      tenantId: 'tenant_1',
      name: 'George Anderson',
      email: 'george@example.com',
      password: 'password123',
      roleId: '3',
      isActive: true,
    ),
    User(
      id: '10',
      tenantId: 'tenant_1',
      name: 'Hannah Thomas',
      email: 'hannah@example.com',
      password: 'password123',
      roleId: '1',
      isActive: true,
    ),
  ];

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_users);
  }

  Future<void> addUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.add(user);
  }

  Future<void> updateUser(User updated) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _users.indexWhere((u) => u.id == updated.id);
    if (index != -1) _users[index] = updated;
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.removeWhere((u) => u.id == id);
  }
}
