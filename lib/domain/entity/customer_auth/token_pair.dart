import 'package:json_annotation/json_annotation.dart';

part 'token_pair.g.dart';

@JsonSerializable()
class TokenPair {
  final String accessToken;
  final String refreshToken;
  final String sessionId; // For session tracking

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPairToJson(this);
}
