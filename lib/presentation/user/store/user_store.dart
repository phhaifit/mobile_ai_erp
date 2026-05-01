import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_users_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_user_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_user_usecase.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  final UserRepository userRepo;
  final RoleRepository roleRepo;
  final AssignRoleToUserUseCase assignRoleUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  _UserStore(
    this.userRepo,
    this.roleRepo,
    this.assignRoleUseCase,
    this.getAllUsersUseCase,
    this.getUserByIdUseCase,
    this.createUserUseCase,
    this.updateUserUseCase,
    this.deleteUserUseCase,
  );

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
      final data = await getAllUsersUseCase.execute();
      userList = ObservableList.of(data);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> createUser(User user) async {
    loading = true;
    error = null;
    try {
      await createUserUseCase.execute(user);
      await loadUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> updateUser(String id, User user) async {
    loading = true;
    error = null;
    try {
      await updateUserUseCase.execute(id, user);
      await loadUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> deleteUser(String id) async {
    loading = true;
    error = null;
    try {
      await deleteUserUseCase.execute(id);
      await loadUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> assignRole(String userId, String roleId) async {
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
