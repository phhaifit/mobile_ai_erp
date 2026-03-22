import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class SaveCmsPageUseCase extends UseCase<void, CmsPage> {
  final CmsPageRepository _repository;

  SaveCmsPageUseCase(this._repository);

  @override
  Future<void> call({required CmsPage params}) {
    return _repository.savePage(params);
  }
}
