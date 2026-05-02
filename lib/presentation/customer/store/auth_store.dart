import 'package:mobile_ai_erp/data/sharedpref/customer_shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/token_pair.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class CustomerAuthStore = CustomerAuthStoreBase with _$CustomerAuthStore;

abstract class CustomerAuthStoreBase with Store {
  final CustomerSharedPreferenceHelper _sharedPreferenceHelper;

  CustomerAuthStoreBase({
    required CustomerSharedPreferenceHelper sharedPreferenceHelper
  }) : _sharedPreferenceHelper = sharedPreferenceHelper {
    tokenPair = _sharedPreferenceHelper.loadTokenPair();
  }

  // Observable State
  @observable
  TokenPair? tokenPair;

  @action
  Future<void> setTokenPair(TokenPair tokenPair) async {
    await _sharedPreferenceHelper.saveTokenPair(tokenPair);
    tokenPair = tokenPair;
  }
}