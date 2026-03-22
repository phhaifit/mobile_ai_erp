import 'package:mobile_ai_erp/domain/entity/web_builder/content_block.dart';

class CmsPage {
  String? id;
  String? title;
  String? description;
  String? type;
  String? status;
  DateTime? lastModified;
  bool? isPublished;
  List<ContentBlock>? blocks;
  String? metaTitle;
  String? metaDescription;
  String? slug;

  CmsPage({
    this.id,
    this.title,
    this.description,
    this.type,
    this.status,
    this.lastModified,
    this.isPublished,
    this.blocks,
    this.metaTitle,
    this.metaDescription,
    this.slug,
  });

  factory CmsPage.fromMap(Map<String, dynamic> json) => CmsPage(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: json['type'],
        status: json['status'],
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'])
            : null,
        isPublished: json['isPublished'],
        blocks: json['blocks'] != null
            ? (json['blocks'] as List)
                .map((b) => ContentBlock.fromMap(b))
                .toList()
            : null,
        metaTitle: json['metaTitle'],
        metaDescription: json['metaDescription'],
        slug: json['slug'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'status': status,
        'lastModified': lastModified?.toIso8601String(),
        'isPublished': isPublished,
        'blocks': blocks?.map((b) => b.toMap()).toList(),
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'slug': slug,
      };
}
