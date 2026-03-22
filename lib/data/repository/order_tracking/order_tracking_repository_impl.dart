import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';

class OrderTrackingRepositoryImpl extends OrderTrackingRepository {
  @override
  List<OrderTrackingScenario> getScenarios({DateTime? now}) {
    final DateTime clock = now ?? DateTime.now();

    return <OrderTrackingScenario>[
      OrderTrackingScenario(
        scenarioName: 'In Transit',
        orderId: 'ORD-10001',
        trackingNumber: 'TRK-SEA-778899',
        carrierName: 'SwiftExpress',
        carrierTrackingUrl: 'https://example.com/carrier/TRK-SEA-778899',
        estimatedDeliveryDate: clock.add(const Duration(days: 2)),
        lastUpdatedAt: clock.subtract(const Duration(minutes: 11)),
        timelineSteps: <TrackingTimelineStep>[
          TrackingTimelineStep(
            stage: ShipmentStage.confirmed,
            timestamp: clock.subtract(const Duration(days: 2, hours: 1)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.packed,
            timestamp: clock.subtract(const Duration(days: 1, hours: 6)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.shipped,
            timestamp: clock.subtract(const Duration(hours: 12)),
          ),
          TrackingTimelineStep(stage: ShipmentStage.delivered),
        ],
        currentStage: ShipmentStage.shipped,
        deliveryAlertType: DeliveryAlertType.none,
        deliveryAlertMessage: '',
        returnExchangeStage: ReturnExchangeStage.none,
      ),
      OrderTrackingScenario(
        scenarioName: 'Delivered',
        orderId: 'ORD-10002',
        trackingNumber: 'TRK-SUN-123456',
        carrierName: 'SwiftExpress',
        carrierTrackingUrl: 'https://example.com/carrier/TRK-SUN-123456',
        estimatedDeliveryDate: clock.subtract(const Duration(days: 1)),
        lastUpdatedAt: clock.subtract(const Duration(hours: 2)),
        timelineSteps: <TrackingTimelineStep>[
          TrackingTimelineStep(
            stage: ShipmentStage.confirmed,
            timestamp: clock.subtract(const Duration(days: 4)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.packed,
            timestamp: clock.subtract(const Duration(days: 3, hours: 2)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.shipped,
            timestamp: clock.subtract(const Duration(days: 2, hours: 5)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.delivered,
            timestamp: clock.subtract(const Duration(hours: 7)),
          ),
        ],
        currentStage: ShipmentStage.delivered,
        deliveryAlertType: DeliveryAlertType.none,
        deliveryAlertMessage: '',
        returnExchangeStage: ReturnExchangeStage.none,
      ),
      OrderTrackingScenario(
        scenarioName: 'Delivery Failed + Re-delivery',
        orderId: 'ORD-10003',
        trackingNumber: 'TRK-NXT-555210',
        carrierName: 'NextCarrier',
        carrierTrackingUrl: 'https://example.com/carrier/TRK-NXT-555210',
        estimatedDeliveryDate: clock.add(const Duration(days: 1)),
        lastUpdatedAt: clock.subtract(const Duration(minutes: 30)),
        timelineSteps: <TrackingTimelineStep>[
          TrackingTimelineStep(
            stage: ShipmentStage.confirmed,
            timestamp: clock.subtract(const Duration(days: 2)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.packed,
            timestamp: clock.subtract(const Duration(days: 1, hours: 10)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.shipped,
            timestamp: clock.subtract(const Duration(hours: 20)),
          ),
          TrackingTimelineStep(stage: ShipmentStage.delivered),
        ],
        currentStage: ShipmentStage.shipped,
        deliveryAlertType: DeliveryAlertType.redeliveryScheduled,
        deliveryAlertMessage:
            'Delivery attempt failed. Re-delivery is scheduled for tomorrow 09:00 - 12:00.',
        returnExchangeStage: ReturnExchangeStage.none,
      ),
      OrderTrackingScenario(
        scenarioName: 'Return In Progress',
        orderId: 'ORD-10004',
        trackingNumber: 'TRK-RTN-900111',
        carrierName: 'ReturnShip',
        carrierTrackingUrl: 'https://example.com/carrier/TRK-RTN-900111',
        estimatedDeliveryDate: clock.subtract(const Duration(days: 6)),
        lastUpdatedAt: clock.subtract(const Duration(hours: 1)),
        timelineSteps: <TrackingTimelineStep>[
          TrackingTimelineStep(
            stage: ShipmentStage.confirmed,
            timestamp: clock.subtract(const Duration(days: 10)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.packed,
            timestamp: clock.subtract(const Duration(days: 9, hours: 20)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.shipped,
            timestamp: clock.subtract(const Duration(days: 8, hours: 18)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.delivered,
            timestamp: clock.subtract(const Duration(days: 6, hours: 4)),
          ),
        ],
        currentStage: ShipmentStage.delivered,
        deliveryAlertType: DeliveryAlertType.none,
        deliveryAlertMessage: '',
        returnExchangeStage: ReturnExchangeStage.approved,
      ),
      OrderTrackingScenario(
        scenarioName: 'Return Completed - Refunded',
        orderId: 'ORD-10005',
        trackingNumber: 'TRK-RTN-900222',
        carrierName: 'ReturnShip',
        carrierTrackingUrl: 'https://example.com/carrier/TRK-RTN-900222',
        estimatedDeliveryDate: clock.subtract(const Duration(days: 12)),
        lastUpdatedAt: clock.subtract(const Duration(hours: 5)),
        timelineSteps: <TrackingTimelineStep>[
          TrackingTimelineStep(
            stage: ShipmentStage.confirmed,
            timestamp: clock.subtract(const Duration(days: 17)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.packed,
            timestamp: clock.subtract(const Duration(days: 16, hours: 19)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.shipped,
            timestamp: clock.subtract(const Duration(days: 15, hours: 14)),
          ),
          TrackingTimelineStep(
            stage: ShipmentStage.delivered,
            timestamp: clock.subtract(const Duration(days: 12, hours: 10)),
          ),
        ],
        currentStage: ShipmentStage.delivered,
        deliveryAlertType: DeliveryAlertType.none,
        deliveryAlertMessage: '',
        returnExchangeStage: ReturnExchangeStage.refunded,
      ),
    ];
  }

  @override
  OrderTrackingScenario? findByOrderId(
    List<OrderTrackingScenario> scenarios,
    String orderId,
  ) {
    for (final OrderTrackingScenario scenario in scenarios) {
      if (scenario.orderId.toLowerCase() == orderId.toLowerCase()) {
        return scenario;
      }
    }
    return null;
  }
}
