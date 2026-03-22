import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_shared_section.dart';

class TrackingReturnExchangeCard extends StatelessWidget {
  const TrackingReturnExchangeCard({
    super.key,
    required this.selected,
    required this.returnStageLabel,
    required this.primaryColor,
    required this.title,
  });

  final OrderTrackingScenario selected;
  final String Function(ReturnExchangeStage stage) returnStageLabel;
  final Color primaryColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<ReturnExchangeStage> flowStages =
        _buildReturnFlow(selected.returnExchangeStage);

    return TrackingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TrackingSectionTitle(
            title: title,
            icon: Icons.swap_horiz_rounded,
            iconColor: primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            returnStageLabel(selected.returnExchangeStage),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              children: flowStages.asMap().entries.map((entry) {
                final int index = entry.key;
                final ReturnExchangeStage stage = entry.value;
                final bool isActive = stage == selected.returnExchangeStage;
                final bool isDone =
                    _isStageDone(stage, selected.returnExchangeStage);
                final bool isLast = index == flowStages.length - 1;

                return _ReturnStageStep(
                  label: returnStageLabel(stage),
                  isDone: isDone,
                  isActive: isActive,
                  isLast: isLast,
                  primaryColor: primaryColor,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<ReturnExchangeStage> _buildReturnFlow(ReturnExchangeStage current) {
    if (current == ReturnExchangeStage.exchanged) {
      return const <ReturnExchangeStage>[
        ReturnExchangeStage.requested,
        ReturnExchangeStage.approved,
        ReturnExchangeStage.inTransitBack,
        ReturnExchangeStage.received,
        ReturnExchangeStage.exchanged,
      ];
    }

    return const <ReturnExchangeStage>[
      ReturnExchangeStage.requested,
      ReturnExchangeStage.approved,
      ReturnExchangeStage.inTransitBack,
      ReturnExchangeStage.received,
      ReturnExchangeStage.refunded,
    ];
  }

  bool _isStageDone(ReturnExchangeStage stage, ReturnExchangeStage current) {
    final int stageIndex = _stageOrder(stage);
    final int currentIndex = _stageOrder(current);

    return stageIndex <= currentIndex;
  }

  int _stageOrder(ReturnExchangeStage stage) {
    switch (stage) {
      case ReturnExchangeStage.none:
        return -1;
      case ReturnExchangeStage.requested:
        return 0;
      case ReturnExchangeStage.approved:
        return 1;
      case ReturnExchangeStage.inTransitBack:
        return 2;
      case ReturnExchangeStage.received:
        return 3;
      case ReturnExchangeStage.refunded:
        return 4;
      case ReturnExchangeStage.exchanged:
        return 4;
    }
  }
}

class _ReturnStageStep extends StatelessWidget {
  const _ReturnStageStep({
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    required this.primaryColor,
  });

  final String label;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color markerColor =
        isDone ? primaryColor : colorScheme.onSurface.withValues(alpha: 0.28);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 22,
          child: Column(
            children: <Widget>[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? markerColor : colorScheme.surface,
                  border: Border.all(color: markerColor, width: 2),
                ),
                child: isDone
                    ? Icon(Icons.check, size: 10, color: colorScheme.onPrimary)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 22,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: isDone
                      ? primaryColor.withValues(alpha: 0.35)
                      : colorScheme.onSurface.withValues(alpha: 0.14),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 0, bottom: isLast ? 0 : 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive
                    ? primaryColor
                    : colorScheme.onSurface
                        .withValues(alpha: isDone ? 0.9 : 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
