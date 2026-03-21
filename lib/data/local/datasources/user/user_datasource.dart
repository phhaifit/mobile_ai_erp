import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';

class UserDataSource {
  final List<User> _users = [
    User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '123456789',
      status: UserStatus.active,
      roleIds: [1],
    ),
    User(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '987654321',
      status: UserStatus.active,
      roleIds: [2, 3],
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

  Future<void> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.removeWhere((u) => u.id == id);
  }
}
