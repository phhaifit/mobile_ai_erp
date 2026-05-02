class TokenPair {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt; // Calculated: now() + 15 minutes
  final String? sessionId; // For session tracking

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.sessionId,
  });

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  bool get isExpiringSoon =>
      expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 2)));

  Duration get remainingDuration => expiresAt.difference(DateTime.now());
}
