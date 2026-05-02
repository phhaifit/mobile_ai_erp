import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel extends Session {
  SessionModel({
    required String id,
    required String customerId,
    required String deviceInfo,
    String? ipAddress,
    required DateTime expiresAt,
    DateTime? revokedAt,
    required DateTime createdAt,
    required DateTime lastUsedAt,
  }) : super(
    id: id,
    customerId: customerId,
    deviceInfo: deviceInfo,
    ipAddress: ipAddress,
    expiresAt: expiresAt,
    revokedAt: revokedAt,
    createdAt: createdAt,
    lastUsedAt: lastUsedAt,
  );

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  // Convert from domain entity to model
  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      id: session.id,
      customerId: session.customerId,
      deviceInfo: session.deviceInfo,
      ipAddress: session.ipAddress,
      expiresAt: session.expiresAt,
      revokedAt: session.revokedAt,
      createdAt: session.createdAt,
      lastUsedAt: session.lastUsedAt,
    );
  }

  // Convert to domain entity
  Session toEntity() {
    return Session(
      id: id,
      customerId: customerId,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      expiresAt: expiresAt,
      revokedAt: revokedAt,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
    );
  }
}
