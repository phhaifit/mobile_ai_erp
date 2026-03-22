import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class GetCmsPageByIdUseCase extends UseCase<CmsPage?, String> {
  final CmsPageRepository _repository;

  GetCmsPageByIdUseCase(this._repository);

  @override
  Future<CmsPage?> call({required String params}) {
    return _repository.getPageById(params);
  }
}
