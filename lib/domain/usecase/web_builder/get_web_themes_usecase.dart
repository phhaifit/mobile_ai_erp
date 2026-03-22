import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme_list.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

class GetWebThemesUseCase extends UseCase<WebThemeList, void> {
  final WebThemeRepository _repository;

  GetWebThemesUseCase(this._repository);

  @override
  Future<WebThemeList> call({required params}) {
    return _repository.getThemes();
  }
}
