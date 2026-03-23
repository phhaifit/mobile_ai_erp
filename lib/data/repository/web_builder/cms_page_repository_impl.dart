import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page_list.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/content_block.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class CmsPageRepositoryImpl extends CmsPageRepository {
  final List<CmsPage> _mockPages = [
    CmsPage(
      id: '1',
      title: 'Home Page',
      description:
          'Main landing page with hero banner, featured products, and promotions',
      type: 'Landing',
      status: 'Published',
      lastModified: DateTime(2026, 3, 15),
      isPublished: true,
      blocks: [
        ContentBlock(type: 'hero', title: 'Hero Banner'),
        ContentBlock(type: 'products', title: 'Product Showcase'),
        ContentBlock(type: 'cta', title: 'Call to Action'),
      ],
      metaTitle: 'Jarvis Store — Smart Shopping',
      metaDescription: 'Welcome to Jarvis Store. Discover the best products.',
      slug: 'home',
    ),
    CmsPage(
      id: '2',
      title: 'About Us',
      description: 'Company story, mission, and team introduction',
      type: 'Info',
      status: 'Published',
      lastModified: DateTime(2026, 3, 10),
      isPublished: true,
      blocks: [
        ContentBlock(type: 'hero', title: 'Hero Banner'),
        ContentBlock(type: 'text', title: 'Our Story'),
        ContentBlock(type: 'gallery', title: 'Team Photos'),
      ],
      metaTitle: 'About Us — Jarvis Store',
      metaDescription: 'Learn about our mission and team.',
      slug: 'about-us',
    ),
    CmsPage(
      id: '3',
      title: 'Contact',
      description: 'Contact form, store locations, and business hours',
      type: 'Info',
      status: 'Draft',
      lastModified: DateTime(2026, 3, 18),
      isPublished: false,
      blocks: [
        ContentBlock(type: 'text', title: 'Contact Info'),
        ContentBlock(type: 'cta', title: 'Send Message'),
      ],
      metaTitle: 'Contact Us — Jarvis Store',
      metaDescription: 'Get in touch with our team.',
      slug: 'contact',
    ),
    CmsPage(
      id: '4',
      title: 'Spring Sale 2026',
      description:
          'Seasonal promotion page with countdown timer and featured deals',
      type: 'Marketing',
      status: 'Published',
      lastModified: DateTime(2026, 3, 20),
      isPublished: true,
      blocks: [
        ContentBlock(type: 'hero', title: 'Sale Banner'),
        ContentBlock(type: 'products', title: 'Featured Deals'),
        ContentBlock(type: 'cta', title: 'Shop Now'),
      ],
      metaTitle: 'Spring Sale 2026 — Up to 50% Off',
      metaDescription: "Don't miss our biggest sale of the season!",
      slug: 'spring-sale-2026',
    ),
    CmsPage(
      id: '5',
      title: 'FAQ',
      description:
          'Frequently asked questions about shipping, returns, and payments',
      type: 'Support',
      status: 'Draft',
      lastModified: DateTime(2026, 3, 12),
      isPublished: false,
      blocks: [
        ContentBlock(type: 'text', title: 'Shipping Questions'),
        ContentBlock(type: 'text', title: 'Return Policy'),
        ContentBlock(type: 'text', title: 'Payment Methods'),
      ],
      metaTitle: 'FAQ — Jarvis Store',
      metaDescription: 'Find answers to common questions.',
      slug: 'faq',
    ),
  ];

  @override
  Future<CmsPageList> getPages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CmsPageList(pages: List.from(_mockPages));
  }

  @override
  Future<CmsPage?> getPageById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockPages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePage(CmsPage page) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockPages.indexWhere((p) => p.id == page.id);
    if (index >= 0) {
      _mockPages[index] = page;
    } else {
      _mockPages.add(page);
    }
  }

  @override
  Future<void> deletePage(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockPages.removeWhere((p) => p.id == id);
  }
}
