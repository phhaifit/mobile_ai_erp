class RoutingRecommendationOptionDto {
  final String optionId;
  final String provider;
  final String serviceLevel;
  final double score;
  final int estimatedDeliveryDays;
  final double estimatedCost;
  final String reason;

  RoutingRecommendationOptionDto({
    required this.optionId,
    required this.provider,
    required this.serviceLevel,
    required this.score,
    required this.estimatedDeliveryDays,
    required this.estimatedCost,
    required this.reason,
  });

  factory RoutingRecommendationOptionDto.fromJson(Map<String, dynamic> json) {
    return RoutingRecommendationOptionDto(
      optionId: json['optionId'] as String,
      provider: json['provider'] as String,
      serviceLevel: json['serviceLevel'] as String,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] as int? ?? 0,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
    );
  }
}

class OrderRoutingRecommendationResponseDto {
  final String decisionId;
  final String orderId;
  final String recommendedProvider;
  final String? selectedProvider;
  final String? selectedOptionId;
  final double? confidence;
  final String scoreStrategy;
  final bool fallbackUsed;
  final List<RoutingRecommendationOptionDto> options;
  final String createdAt;
  final String? appliedAt;

  OrderRoutingRecommendationResponseDto({
    required this.decisionId,
    required this.orderId,
    required this.recommendedProvider,
    required this.selectedProvider,
    this.selectedOptionId,
    required this.confidence,
    required this.scoreStrategy,
    required this.fallbackUsed,
    required this.options,
    required this.createdAt,
    required this.appliedAt,
  });

  factory OrderRoutingRecommendationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final optionsJson = json['options'];
    final options = optionsJson is List<dynamic>
        ? optionsJson
            .whereType<Map<String, dynamic>>()
            .map(RoutingRecommendationOptionDto.fromJson)
            .toList()
        : <RoutingRecommendationOptionDto>[];

    return OrderRoutingRecommendationResponseDto(
      decisionId: json['decisionId'] as String,
      orderId: json['orderId'] as String,
      recommendedProvider: json['recommendedProvider'] as String,
      selectedProvider: json['selectedProvider'] as String?,
      selectedOptionId: json['selectedOptionId'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      scoreStrategy: json['scoreStrategy'] as String? ?? 'weighted_v1',
      fallbackUsed: json['fallbackUsed'] as bool? ?? false,
      options: options,
      createdAt: json['createdAt'] as String,
      appliedAt: json['appliedAt'] as String?,
    );
  }
}

class OrderRoutingApplyResponseDto {
  final String decisionId;
  final String orderId;
  final String selectedProvider;
  final String? selectedOptionId;
  final String appliedAt;

  OrderRoutingApplyResponseDto({
    required this.decisionId,
    required this.orderId,
    required this.selectedProvider,
    required this.selectedOptionId,
    required this.appliedAt,
  });

  factory OrderRoutingApplyResponseDto.fromJson(Map<String, dynamic> json) {
    return OrderRoutingApplyResponseDto(
      decisionId: json['decisionId'] as String,
      orderId: json['orderId'] as String,
      selectedProvider: json['selectedProvider'] as String,
      selectedOptionId: json['selectedOptionId'] as String?,
      appliedAt: json['appliedAt'] as String,
    );
  }
}
