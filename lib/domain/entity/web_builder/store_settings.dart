class StoreSettings {
  String? storeName;
  String? tagline;
  String? email;
  String? phone;
  String? address;
  String? currency;
  String? description;
  String? logoUrl;

  StoreSettings({
    this.storeName,
    this.tagline,
    this.email,
    this.phone,
    this.address,
    this.currency,
    this.description,
    this.logoUrl,
  });

  factory StoreSettings.fromMap(Map<String, dynamic> json) => StoreSettings(
        storeName: json['storeName'],
        tagline: json['tagline'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        currency: json['currency'],
        description: json['description'],
        logoUrl: json['logoUrl'],
      );

  Map<String, dynamic> toMap() => {
        'storeName': storeName,
        'tagline': tagline,
        'email': email,
        'phone': phone,
        'address': address,
        'currency': currency,
        'description': description,
        'logoUrl': logoUrl,
      };
}
