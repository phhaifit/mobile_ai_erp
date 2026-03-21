import 'package:mobile_ai_erp/presentation/customer_management/customers/customer_detail.dart';
import 'package:mobile_ai_erp/presentation/customer_management/customers/customer_form.dart';
import 'package:mobile_ai_erp/presentation/customer_management/customers/customers_screen.dart';
import 'package:mobile_ai_erp/presentation/customer_management/addresses/address_form.dart';
import 'package:mobile_ai_erp/presentation/customer_management/addresses/addresses_screen.dart';
import 'package:mobile_ai_erp/presentation/customer_management/groups/customer_group_form.dart';
import 'package:mobile_ai_erp/presentation/customer_management/groups/customer_groups_screen.dart';
import 'package:mobile_ai_erp/presentation/customer_management/home/customer_management_home.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:flutter/material.dart';

class CustomerNavigator {
  CustomerNavigator._();

  static const String homeRoute = '/customers/home';
  static const String customersRoute = '/customers';
  static const String customerDetailRoute = '/customers/detail';
  static const String customerFormRoute = '/customers/form';
  static const String addressesRoute = '/customers/addresses';
  static const String addressFormRoute = '/customers/addresses/form';
  static const String groupsRoute = '/customers/groups';
  static const String groupFormRoute = '/customers/groups/form';

  static Future<T?> openHome<T>(BuildContext context) {
    return _push<T>(
      context,
      const CustomerManagementHomeScreen(),
      routeName: homeRoute,
    );
  }

  static Future<T?> openCustomers<T>(BuildContext context) {
    return _push<T>(
      context,
      const CustomersScreen(),
      routeName: customersRoute,
    );
  }

  static Future<T?> openCustomerDetail<T>(
    BuildContext context, {
    required CustomerDetailArgs args,
  }) {
    return _push<T>(
      context,
      CustomerDetailScreen(args: args),
      routeName: customerDetailRoute,
    );
  }

  static Future<T?> openCustomerForm<T>(
    BuildContext context, {
    CustomerFormArgs? args,
  }) {
    return _push<T>(
      context,
      CustomerFormScreen(args: args),
      routeName: customerFormRoute,
    );
  }

  static Future<T?> openAddresses<T>(
    BuildContext context, {
    required CustomerAddressesArgs args,
  }) {
    return _push<T>(
      context,
      CustomerAddressesScreen(args: args),
      routeName: addressesRoute,
    );
  }

  static Future<T?> openAddressForm<T>(
    BuildContext context, {
    required AddressFormArgs args,
  }) {
    return _push<T>(
      context,
      AddressFormScreen(args: args),
      routeName: addressFormRoute,
    );
  }

  static Future<T?> openGroups<T>(BuildContext context) {
    return _push<T>(
      context,
      const CustomerGroupsScreen(),
      routeName: groupsRoute,
    );
  }

  static Future<T?> openGroupForm<T>(
    BuildContext context, {
    CustomerGroupFormArgs? args,
  }) {
    return _push<T>(
      context,
      CustomerGroupFormScreen(args: args),
      routeName: groupFormRoute,
    );
  }

  static Future<T?> _push<T>(
    BuildContext context,
    Widget screen, {
    required String routeName,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        settings: RouteSettings(name: routeName),
        builder: (_) => screen,
      ),
    );
  }
}
