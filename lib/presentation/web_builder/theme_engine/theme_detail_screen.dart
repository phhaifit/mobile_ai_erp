import 'package:flutter/material.dart';

/// Mock theme data used for detail preview.
/// In Phase 2 this will come from the domain layer.
class _ThemeData {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String category;
  final List<String> fonts;
  final bool isActive;

  const _ThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.category,
    required this.fonts,
    this.isActive = false,
  });
}

const _allThemes = <String, _ThemeData>{
  '1': _ThemeData(
    id: '1',
    name: 'Modern Minimal',
    description: 'Clean and minimalist design with focus on content. '
        'Perfect for stores that want a professional, distraction-free look.',
    primaryColor: Color(0xFF1A1A2E),
    accentColor: Color(0xFFE94560),
    backgroundColor: Color(0xFFF5F5F5),
    category: 'Minimal',
    fonts: ['Inter', 'Roboto'],
    isActive: true,
  ),
  '2': _ThemeData(
    id: '2',
    name: 'Ocean Breeze',
    description: 'Fresh blue tones inspired by the sea. '
        'Great for lifestyle, travel, and wellness brands.',
    primaryColor: Color(0xFF0077B6),
    accentColor: Color(0xFF00B4D8),
    backgroundColor: Color(0xFFCAF0F8),
    category: 'Nature',
    fonts: ['Poppins', 'Open Sans'],
  ),
  '3': _ThemeData(
    id: '3',
    name: 'Sunset Glow',
    description: 'Warm gradient colors for a vibrant storefront. '
        'Ideal for food, fashion, and creative businesses.',
    primaryColor: Color(0xFFFF6B35),
    accentColor: Color(0xFFFFC045),
    backgroundColor: Color(0xFFFFF8F0),
    category: 'Vibrant',
    fonts: ['Montserrat', 'Lato'],
  ),
  '4': _ThemeData(
    id: '4',
    name: 'Dark Elegance',
    description: 'Sophisticated dark theme with gold accents. '
        'Perfect for luxury goods, jewelry, and premium brands.',
    primaryColor: Color(0xFF2D2D2D),
    accentColor: Color(0xFFD4AF37),
    backgroundColor: Color(0xFF1A1A1A),
    category: 'Dark',
    fonts: ['Playfair Display', 'Cormorant'],
  ),
  '5': _ThemeData(
    id: '5',
    name: 'Forest Green',
    description: 'Natural earthy tones for eco-friendly brands. '
        'Ideal for organic, sustainable, and outdoor products.',
    primaryColor: Color(0xFF2D6A4F),
    accentColor: Color(0xFF95D5B2),
    backgroundColor: Color(0xFFF0FFF4),
    category: 'Nature',
    fonts: ['Nunito', 'Source Sans Pro'],
  ),
  '6': _ThemeData(
    id: '6',
    name: 'Tech Purple',
    description: 'Modern tech-inspired purple and neon palette. '
        'Great for SaaS, gadgets, and digital products.',
    primaryColor: Color(0xFF7B2CBF),
    accentColor: Color(0xFFC77DFF),
    backgroundColor: Color(0xFFF8F0FF),
    category: 'Vibrant',
    fonts: ['Space Grotesk', 'JetBrains Mono'],
  ),
};

class ThemeDetailScreen extends StatefulWidget {
  const ThemeDetailScreen({super.key});

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  late _ThemeData _themeData;
  bool _loaded = false;

  // Customizable colors (user can tweak)
  late Color _customPrimary;
  late Color _customAccent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final themeId =
          ModalRoute.of(context)?.settings.arguments as String? ?? '1';
      _themeData = _allThemes[themeId] ?? _allThemes['1']!;
      _customPrimary = _themeData.primaryColor;
      _customAccent = _themeData.accentColor;
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_themeData.name),
        actions: [
          if (_themeData.isActive)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('Active'),
                avatar: Icon(Icons.check_circle, size: 18),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview
            _buildLivePreview(),
            // Theme info & customization
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text('About this theme', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _themeData.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Theme details
                  _buildDetailsSection(theme),
                  const SizedBox(height: 24),

                  // Color customization
                  _buildColorCustomization(theme),
                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      width: double.infinity,
      height: 280,
      color: _themeData.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock nav bar
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: _customPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  ...List.generate(
                    3,
                    (i) => Container(
                      width: 30,
                      height: 8,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Hero section
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _customAccent.withValues(alpha: 0.2),
                      _customAccent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _customPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _customPrimary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _customAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Product grid mock
            Expanded(
              flex: 2,
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _customPrimary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    _customPrimary.withValues(alpha: 0.06),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _customPrimary
                                          .withValues(alpha: 0.4),
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    height: 6,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: _customAccent
                                          .withValues(alpha: 0.6),
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(theme, 'Category', _themeData.category),
            const Divider(height: 20),
            _buildDetailRow(theme, 'Fonts', _themeData.fonts.join(', ')),
            const Divider(height: 20),
            _buildDetailRow(
                theme, 'Status', _themeData.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        )),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }

  Widget _buildColorCustomization(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customize Colors', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Tap a color to preview changes in the live preview above',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        // Primary color picker
        _buildColorRow(
          theme,
          label: 'Primary Color',
          currentColor: _customPrimary,
          presets: const [
            Color(0xFF1A1A2E),
            Color(0xFF0077B6),
            Color(0xFF2D6A4F),
            Color(0xFF7B2CBF),
            Color(0xFF2D2D2D),
            Color(0xFFD21E1D),
          ],
          onColorSelected: (color) {
            setState(() => _customPrimary = color);
          },
        ),
        const SizedBox(height: 16),
        // Accent color picker
        _buildColorRow(
          theme,
          label: 'Accent Color',
          currentColor: _customAccent,
          presets: const [
            Color(0xFFE94560),
            Color(0xFF00B4D8),
            Color(0xFFFFC045),
            Color(0xFFD4AF37),
            Color(0xFF95D5B2),
            Color(0xFFC77DFF),
          ],
          onColorSelected: (color) {
            setState(() => _customAccent = color);
          },
        ),
        const SizedBox(height: 12),
        // Reset button
        if (_customPrimary != _themeData.primaryColor ||
            _customAccent != _themeData.accentColor)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _customPrimary = _themeData.primaryColor;
                _customAccent = _themeData.accentColor;
              });
            },
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('Reset to defaults'),
          ),
      ],
    );
  }

  Widget _buildColorRow(
    ThemeData theme, {
    required String label,
    required Color currentColor,
    required List<Color> presets,
    required ValueChanged<Color> onColorSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((color) {
            final isSelected = color == currentColor;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _customPrimary = _themeData.primaryColor;
                _customAccent = _themeData.accentColor;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Colors reset to theme defaults'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _themeData.isActive
                        ? 'Theme settings updated!'
                        : 'Theme "${_themeData.name}" activated!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            icon: Icon(
                _themeData.isActive ? Icons.save : Icons.check_circle_outline),
            label: Text(_themeData.isActive ? 'Save Changes' : 'Apply Theme'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
