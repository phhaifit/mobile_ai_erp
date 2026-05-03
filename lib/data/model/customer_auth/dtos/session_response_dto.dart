import 'package:json_annotation/json_annotation.dart';

part 'session_response_dto.g.dart';

@JsonSerializable()
class SessionResponseDto {
  final String id;
  final String? deviceInfo;
  final String? ipAddress;
  final String createdAt;
  final String lastUsedAt;
  final bool isCurrent;

  SessionResponseDto({
    required this.id,
    this.deviceInfo,
    this.ipAddress,
    required this.createdAt,
    required this.lastUsedAt,
    required this.isCurrent,
  });

  factory SessionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SessionResponseDtoToJson(this);
}
