import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

@JsonSerializable()
class Session {
  final String id;
  final String customerId;
  final String deviceInfo;
  final String? ipAddress;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;
  final DateTime lastUsedAt;

  Session({
    required this.id,
    required this.customerId,
    required this.deviceInfo,
    this.ipAddress,
    required this.expiresAt,
    this.revokedAt,
    required this.createdAt,
    required this.lastUsedAt,
  });

  bool get isActive => revokedAt == null && expiresAt.isAfter(DateTime.now());
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  Duration get remainingDuration => expiresAt.difference(DateTime.now());

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
