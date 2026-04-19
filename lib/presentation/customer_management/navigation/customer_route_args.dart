class CustomerDetailArgs {
  const CustomerDetailArgs({required this.customerId});

  final String customerId;
}

class CustomerFormArgs {
  const CustomerFormArgs({this.customerId});

  final String? customerId;
}

class CustomerAddressesArgs {
  const CustomerAddressesArgs({this.customerId});

  final String? customerId;
}

class AddressFormArgs {
  const AddressFormArgs({
    this.addressId,
  });

  final String? addressId;
}

class CustomerGroupFormArgs {
  const CustomerGroupFormArgs({this.groupId});

  final String? groupId;
}
