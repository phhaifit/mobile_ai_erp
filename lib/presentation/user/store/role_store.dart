import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
import 'package:mobx/mobx.dart';

part 'role_store.g.dart';

class RoleStore = _RoleStore with _$RoleStore;

abstract class _RoleStore with Store {
  final RoleRepository roleRepo;
  final CreateRoleUseCase createRoleUseCase;
  final UpdateRoleUseCase updateRoleUseCase;

  _RoleStore(this.roleRepo, this.createRoleUseCase, this.updateRoleUseCase);

  @observable
  ObservableList<Role> roleList = ObservableList();

  @observable
  bool loading = false;

  @observable
  String? error;

  @action
  Future<void> loadRoles() async {
    loading = true;
    error = null;
    try {
      final data = await roleRepo.getAll();
      roleList = ObservableList.of(data);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> createRole(Role role) async {
    try {
      loading = true;
      error = null;

      await createRoleUseCase.execute(role);

      await loadRoles();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> updateRole(Role role) async {
    try {
      loading = true;
      error = null;

      await updateRoleUseCase.execute(role);

      await loadRoles();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> deleteRole(int id) async {
    await roleRepo.delete(id);
    await loadRoles();
  }
}
