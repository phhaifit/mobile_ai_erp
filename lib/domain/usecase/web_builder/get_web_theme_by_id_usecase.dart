import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

class GetWebThemeByIdUseCase extends UseCase<WebTheme?, String> {
  final WebThemeRepository _repository;

  GetWebThemeByIdUseCase(this._repository);

  @override
  Future<WebTheme?> call({required String params}) {
    return _repository.getThemeById(params);
  }
}
