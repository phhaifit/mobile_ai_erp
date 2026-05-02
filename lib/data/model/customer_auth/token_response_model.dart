import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';
import 'customer_model.dart';

part 'token_response_model.g.dart';

@JsonSerializable()
class TokenResponseModel {
  final String accessToken;
  final String refreshToken;
  @JsonKey(name: 'expiresIn')
  final int expiresIn; // in seconds, typically 900 (15 minutes)
  final CustomerModel? customer;
  final String? sessionId;

  TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.customer,
    this.sessionId,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseModelToJson(this);

  // Convert to domain TokenPair
  TokenPair toTokenPair() {
    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      sessionId: sessionId,
    );
  }
}

@JsonSerializable()
class SignInResponseModel extends TokenResponseModel {
  SignInResponseModel({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    CustomerModel? customer,
    String? sessionId,
  }) : super(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    customer: customer,
    sessionId: sessionId,
  );

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignInResponseModelToJson(this);
}
