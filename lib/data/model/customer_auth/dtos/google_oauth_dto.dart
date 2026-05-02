import 'package:json_annotation/json_annotation.dart';

part 'google_oauth_dto.g.dart';

@JsonSerializable()
class GoogleOAuthInitiateDto {
  final String redirectUri;

  GoogleOAuthInitiateDto({
    required this.redirectUri,
  });

  factory GoogleOAuthInitiateDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthInitiateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthInitiateDtoToJson(this);
}

@JsonSerializable()
class GoogleOAuthCallbackDto {
  final String authorizationCode;

  GoogleOAuthCallbackDto({
    required this.authorizationCode,
  });

  factory GoogleOAuthCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthCallbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthCallbackDtoToJson(this);
}
