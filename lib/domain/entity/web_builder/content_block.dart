class ContentBlock {
  String? type;
  String? title;

  ContentBlock({this.type, this.title});

  factory ContentBlock.fromMap(Map<String, dynamic> json) => ContentBlock(
        type: json['type'],
        title: json['title'],
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
      };
}
