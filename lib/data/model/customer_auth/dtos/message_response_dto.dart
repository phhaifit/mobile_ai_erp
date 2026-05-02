import 'package:json_annotation/json_annotation.dart';

part 'message_response_dto.g.dart';

@JsonSerializable()
class MessageResponseDto {
  final String message;

  MessageResponseDto({
    required this.message,
  });

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseDtoToJson(this);
}

