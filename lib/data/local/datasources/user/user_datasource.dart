import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';

class UserDataSource {
  final List<User> _users = [
    User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '123456789',
      status: UserStatus.active,
      role: '1',
    ),
    User(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '987654321',
      status: UserStatus.active,
      role: '2',
    ),
    User(
      id: '3',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      phone: '111222333',
      status: UserStatus.inactive,
      role: '3',
    ),
    User(
      id: '4',
      name: 'Bob Brown',
      email: 'bob@example.com',
      phone: '444555666',
      status: UserStatus.active,
      role: '1',
    ),
    User(
      id: '5',
      name: 'Charlie Davis',
      email: 'charlie@example.com',
      phone: '777888999',
      status: UserStatus.inactive,
      role: '2',
    ),
    User(
      id: '6',
      name: 'Diana Evans',
      email: 'diana@example.com',
      phone: '222333444',
      status: UserStatus.active,
      role: '3',
    ),
    User(
      id: '7',
      name: 'Ethan Wilson',
      email: 'ethan@example.com',
      phone: '555666777',
      status: UserStatus.active,
      role: '1',
    ),
    User(
      id: '8',
      name: 'Fiona Taylor',
      email: 'fiona@example.com',
      phone: '888999000',
      status: UserStatus.inactive,
      role: '2',
    ),
    User(
      id: '9',
      name: 'George Anderson',
      email: 'george@example.com',
      phone: '333444555',
      status: UserStatus.active,
      role: '3',
    ),
    User(
      id: '10',
      name: 'Hannah Thomas',
      email: 'hannah@example.com',
      phone: '666777888',
      status: UserStatus.active,
      role: '1',
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
