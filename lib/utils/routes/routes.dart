import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String inventoryAudit = '/inventory-audit';
  static const String inventoryAuditSummary = '/inventory-audit-summary';
  static const String inventoryOutbound = '/inventory-outbound';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    inventoryAudit: (BuildContext context) => const InventoryAuditScreen(),
    inventoryAuditSummary: (BuildContext context) =>
        const InventoryAuditSummaryScreen(),
    inventoryOutbound: (BuildContext context) => const InventoryOutboundScreen(),
  };
}
