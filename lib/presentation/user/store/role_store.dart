import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_roles_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_role_by_id_usecase.dart';
import 'package:mobile_ai_erp/core/data/network/models/api_error_response.dart';
import 'package:mobx/mobx.dart';

part 'role_store.g.dart';

class RoleStore = _RoleStore with _$RoleStore;

abstract class _RoleStore with Store {
  final RoleRepository roleRepo;
  final CreateRoleUseCase createRoleUseCase;
  final UpdateRoleUseCase updateRoleUseCase;
  final DeleteRoleUseCase deleteRoleUseCase;
  final GetAllRolesUseCase getAllRolesUseCase;
  final GetRoleByIdUseCase getRoleByIdUseCase;

  _RoleStore(
    this.roleRepo,
    this.createRoleUseCase,
    this.updateRoleUseCase,
    this.deleteRoleUseCase,
    this.getAllRolesUseCase,
    this.getRoleByIdUseCase,
  );

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
      final data = await getAllRolesUseCase.execute();
      roleList = ObservableList.of(data);
    } on ApiException catch (e) {
      error = e.userFriendlyMessage;
    } catch (e) {
      error = 'Failed to load roles. Please try again.';
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
    } on ApiException catch (e) {
      error = e.userFriendlyMessage;
    } catch (e) {
      error = 'Failed to create role. Please try again.';
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> updateRole(String id, Role role) async {
    try {
      loading = true;
      error = null;

      await updateRoleUseCase.execute(id, role);

      await loadRoles();
    } on ApiException catch (e) {
      error = e.userFriendlyMessage;
    } catch (e) {
      error = 'Failed to update role. Please try again.';
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> deleteRole(String id) async {
    try {
      await deleteRoleUseCase.execute(id);
      await loadRoles();
    } on ApiException catch (e) {
      error = e.userFriendlyMessage;
    } catch (e) {
      error = 'Failed to delete role. Please try again.';
    }
  }

  @action
  Future<Role?> getRoleById(String id) async {
    try {
      return await getRoleByIdUseCase.execute(id);
    } on ApiException catch (e) {
      error = e.userFriendlyMessage;
      return null;
    } catch (e) {
      error = 'Failed to load role details. Please try again.';
      return null;
    }
  }
}
