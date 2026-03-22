class WebTheme {
  String? id;
  String? name;
  String? description;
  int? primaryColor;
  int? accentColor;
  int? backgroundColor;
  String? category;
  List<String>? fonts;
  bool? isActive;

  WebTheme({
    this.id,
    this.name,
    this.description,
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
    this.category,
    this.fonts,
    this.isActive,
  });

  factory WebTheme.fromMap(Map<String, dynamic> json) => WebTheme(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        primaryColor: json['primaryColor'],
        accentColor: json['accentColor'],
        backgroundColor: json['backgroundColor'],
        category: json['category'],
        fonts: json['fonts'] != null ? List<String>.from(json['fonts']) : null,
        isActive: json['isActive'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'primaryColor': primaryColor,
        'accentColor': accentColor,
        'backgroundColor': backgroundColor,
        'category': category,
        'fonts': fonts,
        'isActive': isActive,
      };
}
