import 'package:json_annotation/json_annotation.dart';

part 'sign_up_dto.g.dart';

@JsonSerializable()
class SignUpDto {
  final String email;
  final String password;

  SignUpDto({
    required this.email,
    required this.password,
  });

  factory SignUpDto.fromJson(Map<String, dynamic> json) =>
      _$SignUpDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpDtoToJson(this);
}
