import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';

import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

class IsLoggedInUseCase {
  final SharedPreferenceHelper _sharedPreferenceHelper;

  IsLoggedInUseCase(this._sharedPreferenceHelper);

  @override
  Future<bool> call({required void params}) async {
    return await _sharedPreferenceHelper.isLoggedIn;
  }
}
