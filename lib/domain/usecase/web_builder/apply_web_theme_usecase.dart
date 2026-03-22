import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

class ApplyWebThemeParams {
  final String id;
  final int? primaryColor;
  final int? accentColor;

  ApplyWebThemeParams({required this.id, this.primaryColor, this.accentColor});
}

class ApplyWebThemeUseCase extends UseCase<void, ApplyWebThemeParams> {
  final WebThemeRepository _repository;

  ApplyWebThemeUseCase(this._repository);

  @override
  Future<void> call({required ApplyWebThemeParams params}) {
    return _repository.applyTheme(
      params.id,
      primaryColor: params.primaryColor,
      accentColor: params.accentColor,
    );
  }
}
