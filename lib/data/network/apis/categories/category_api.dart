import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';

class CategoryApi {
  final RestClient _restClient;

  CategoryApi(this._restClient);

  Future<dynamic> getCategories() async {
    return await _restClient.get(Endpoints.categoriesUrl);
  }
}
