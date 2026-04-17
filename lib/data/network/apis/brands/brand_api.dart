import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:http/http.dart' as http;

class BrandApi {
  final RestClient _restClient;

  BrandApi(this._restClient);

  Future<dynamic> getBrands() async {
    return await _restClient.get(Endpoints.brandsUrl);
  }
}