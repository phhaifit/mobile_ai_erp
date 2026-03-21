import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobx/mobx.dart';

part 'role_store.g.dart';

class RoleStore = _RoleStore with _$RoleStore;

abstract class _RoleStore with Store {
  final RoleRepository roleRepo;

  _RoleStore(this.roleRepo);

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
    await roleRepo.create(role);
    await loadRoles();
  }

  @action
  Future<void> updateRole(Role role) async {
    await roleRepo.update(role);
    await loadRoles();
  }

  @action
  Future<void> deleteRole(int id) async {
    await roleRepo.delete(id);
    await loadRoles();
  }
}
