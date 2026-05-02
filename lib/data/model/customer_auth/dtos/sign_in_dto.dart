import 'package:json_annotation/json_annotation.dart';

part 'sign_in_dto.g.dart';

@JsonSerializable()
class SignInDto {
  final String email;
  final String password;

  SignInDto({
    required this.email,
    required this.password,
  });

  factory SignInDto.fromJson(Map<String, dynamic> json) =>
      _$SignInDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignInDtoToJson(this);
}
