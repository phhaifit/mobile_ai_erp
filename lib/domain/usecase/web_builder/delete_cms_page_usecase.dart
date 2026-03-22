import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class DeleteCmsPageUseCase extends UseCase<void, String> {
  final CmsPageRepository _repository;

  DeleteCmsPageUseCase(this._repository);

  @override
  Future<void> call({required String params}) {
    return _repository.deletePage(params);
  }
}
