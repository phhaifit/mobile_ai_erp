import 'package:json_annotation/json_annotation.dart';

part 'magic_link_dto.g.dart';

@JsonSerializable()
class MagicLinkRequestDto {
  final String email;

  MagicLinkRequestDto({
    required this.email,
  });

  factory MagicLinkRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MagicLinkRequestDtoToJson(this);
}

@JsonSerializable()
class MagicLinkConfirmDto {
  final String token;

  MagicLinkConfirmDto({
    required this.token,
  });

  factory MagicLinkConfirmDto.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkConfirmDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MagicLinkConfirmDtoToJson(this);
}
