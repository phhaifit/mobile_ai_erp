import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';

part 'token_response_dto.g.dart';

@JsonSerializable()
class TokenResponseDto {
  final String accessToken;
  final String refreshToken;
  final String? expiresIn; // in seconds, typically 900 (15 minutes)
  final String sessionId;

  TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    required this.sessionId,
  });

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseDtoToJson(this);

  // Convert to domain TokenPair
  TokenPair toTokenPair() {
    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
    );
  }
}

@JsonSerializable()
class SignInResponseModel extends TokenResponseDto {
  SignInResponseModel({
    required super.accessToken,
    required super.refreshToken,
    super.expiresIn,
    required super.sessionId,
  });

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignInResponseModelToJson(this);
}
