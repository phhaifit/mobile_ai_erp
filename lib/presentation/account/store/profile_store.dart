import 'package:mobx/mobx.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  // Assuming logged-in state per Feature 0 boundaries
  @observable
  String userName = "Khang"; 

  @observable
  String userEmail = "khang@gmail.com";

  @observable
  String userPhone = "0901234567";

  @observable
  int loyaltyPoints = 1250; 
}