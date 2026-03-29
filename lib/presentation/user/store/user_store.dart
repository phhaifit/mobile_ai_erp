import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  final UserRepository userRepo;
  final RoleRepository roleRepo;
  final AssignRoleToUserUseCase assignRoleUseCase;

  _UserStore(this.userRepo, this.roleRepo, this.assignRoleUseCase);

  @observable
  ObservableList<User> userList = ObservableList();

  @observable
  bool loading = false;

  @observable
  String? error;

  @action
  Future<void> loadUsers() async {
    loading = true;
    error = null;
    try {
      final data = await userRepo.getAll();
      userList = ObservableList.of(data);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> createUser(User user) async {
    await userRepo.create(user);
    await loadUsers();
  }

  @action
  Future<void> updateUser(User user) async {
    await userRepo.update(user);
    await loadUsers();
  }

  @action
  Future<void> deleteUser(int id) async {
    await userRepo.delete(id);
    await loadUsers();
  }

  @action
  Future<void> assignRole(int userId, int roleId) async {
    final user = userList.firstWhere((u) => u.id == userId);

    try {
      loading = true;

      await assignRoleUseCase.execute(
        user: user,
        roleId: roleId,
      );

      await loadUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }
}
