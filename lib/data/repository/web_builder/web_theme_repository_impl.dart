import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme_list.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

class WebThemeRepositoryImpl extends WebThemeRepository {
  final List<WebTheme> _mockThemes = [
    WebTheme(
      id: '1',
      name: 'Modern Minimal',
      description: 'Clean and minimalist design with focus on content. '
          'Perfect for stores that want a professional, distraction-free look.',
      primaryColor: 0xFF1A1A2E,
      accentColor: 0xFFE94560,
      backgroundColor: 0xFFF5F5F5,
      category: 'Minimal',
      fonts: ['Inter', 'Roboto'],
      isActive: true,
    ),
    WebTheme(
      id: '2',
      name: 'Ocean Breeze',
      description: 'Fresh blue tones inspired by the sea. '
          'Great for lifestyle, travel, and wellness brands.',
      primaryColor: 0xFF0077B6,
      accentColor: 0xFF00B4D8,
      backgroundColor: 0xFFCAF0F8,
      category: 'Nature',
      fonts: ['Poppins', 'Open Sans'],
      isActive: false,
    ),
    WebTheme(
      id: '3',
      name: 'Sunset Glow',
      description: 'Warm gradient colors for a vibrant storefront. '
          'Ideal for food, fashion, and creative businesses.',
      primaryColor: 0xFFFF6B35,
      accentColor: 0xFFFFC045,
      backgroundColor: 0xFFFFF8F0,
      category: 'Vibrant',
      fonts: ['Montserrat', 'Lato'],
      isActive: false,
    ),
    WebTheme(
      id: '4',
      name: 'Dark Elegance',
      description: 'Sophisticated dark theme with gold accents. '
          'Perfect for luxury goods, jewelry, and premium brands.',
      primaryColor: 0xFF2D2D2D,
      accentColor: 0xFFD4AF37,
      backgroundColor: 0xFF1A1A1A,
      category: 'Dark',
      fonts: ['Playfair Display', 'Cormorant'],
      isActive: false,
    ),
    WebTheme(
      id: '5',
      name: 'Forest Green',
      description: 'Natural earthy tones for eco-friendly brands. '
          'Ideal for organic, sustainable, and outdoor products.',
      primaryColor: 0xFF2D6A4F,
      accentColor: 0xFF95D5B2,
      backgroundColor: 0xFFF0FFF4,
      category: 'Nature',
      fonts: ['Nunito', 'Source Sans Pro'],
      isActive: false,
    ),
    WebTheme(
      id: '6',
      name: 'Tech Purple',
      description: 'Modern tech-inspired purple and neon palette. '
          'Great for SaaS, gadgets, and digital products.',
      primaryColor: 0xFF7B2CBF,
      accentColor: 0xFFC77DFF,
      backgroundColor: 0xFFF8F0FF,
      category: 'Vibrant',
      fonts: ['Space Grotesk', 'JetBrains Mono'],
      isActive: false,
    ),
  ];

  @override
  Future<WebThemeList> getThemes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return WebThemeList(themes: List.from(_mockThemes));
  }

  @override
  Future<WebTheme?> getThemeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockThemes.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> applyTheme(String id,
      {int? primaryColor, int? accentColor}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < _mockThemes.length; i++) {
      if (_mockThemes[i].id == id) {
        _mockThemes[i] = WebTheme(
          id: _mockThemes[i].id,
          name: _mockThemes[i].name,
          description: _mockThemes[i].description,
          primaryColor: primaryColor ?? _mockThemes[i].primaryColor,
          accentColor: accentColor ?? _mockThemes[i].accentColor,
          backgroundColor: _mockThemes[i].backgroundColor,
          category: _mockThemes[i].category,
          fonts: _mockThemes[i].fonts,
          isActive: true,
        );
      } else {
        _mockThemes[i] = WebTheme(
          id: _mockThemes[i].id,
          name: _mockThemes[i].name,
          description: _mockThemes[i].description,
          primaryColor: _mockThemes[i].primaryColor,
          accentColor: _mockThemes[i].accentColor,
          backgroundColor: _mockThemes[i].backgroundColor,
          category: _mockThemes[i].category,
          fonts: _mockThemes[i].fonts,
          isActive: false,
        );
      }
    }
  }
}
