import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page_list.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class GetCmsPagesUseCase extends UseCase<CmsPageList, void> {
  final CmsPageRepository _repository;

  GetCmsPagesUseCase(this._repository);

  @override
  Future<CmsPageList> call({required params}) {
    return _repository.getPages();
  }
}
