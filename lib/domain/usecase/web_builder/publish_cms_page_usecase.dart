import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class PublishCmsPageParams {
  final String id;
  final bool published;

  PublishCmsPageParams({required this.id, required this.published});
}

class PublishCmsPageUseCase extends UseCase<void, PublishCmsPageParams> {
  final CmsPageRepository _repository;

  PublishCmsPageUseCase(this._repository);

  @override
  Future<void> call({required PublishCmsPageParams params}) {
    return _repository.publishPage(params.id, params.published);
  }
}
