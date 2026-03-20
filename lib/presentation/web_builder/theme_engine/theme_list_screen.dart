import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class _MockTheme {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String category;
  final bool isActive;

  const _MockTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.category,
    this.isActive = false,
  });
}

const _mockThemes = <_MockTheme>[
  _MockTheme(
    id: '1',
    name: 'Modern Minimal',
    description: 'Clean and minimalist design with focus on content',
    primaryColor: Color(0xFF1A1A2E),
    accentColor: Color(0xFFE94560),
    backgroundColor: Color(0xFFF5F5F5),
    category: 'Minimal',
    isActive: true,
  ),
  _MockTheme(
    id: '2',
    name: 'Ocean Breeze',
    description: 'Fresh blue tones inspired by the sea',
    primaryColor: Color(0xFF0077B6),
    accentColor: Color(0xFF00B4D8),
    backgroundColor: Color(0xFFCAF0F8),
    category: 'Nature',
  ),
  _MockTheme(
    id: '3',
    name: 'Sunset Glow',
    description: 'Warm gradient colors for a vibrant storefront',
    primaryColor: Color(0xFFFF6B35),
    accentColor: Color(0xFFFFC045),
    backgroundColor: Color(0xFFFFF8F0),
    category: 'Vibrant',
  ),
  _MockTheme(
    id: '4',
    name: 'Dark Elegance',
    description: 'Sophisticated dark theme with gold accents',
    primaryColor: Color(0xFF2D2D2D),
    accentColor: Color(0xFFD4AF37),
    backgroundColor: Color(0xFF1A1A1A),
    category: 'Dark',
  ),
  _MockTheme(
    id: '5',
    name: 'Forest Green',
    description: 'Natural earthy tones for eco-friendly brands',
    primaryColor: Color(0xFF2D6A4F),
    accentColor: Color(0xFF95D5B2),
    backgroundColor: Color(0xFFF0FFF4),
    category: 'Nature',
  ),
  _MockTheme(
    id: '6',
    name: 'Tech Purple',
    description: 'Modern tech-inspired purple and neon palette',
    primaryColor: Color(0xFF7B2CBF),
    accentColor: Color(0xFFC77DFF),
    backgroundColor: Color(0xFFF8F0FF),
    category: 'Vibrant',
  ),
];

class ThemeListScreen extends StatefulWidget {
  const ThemeListScreen({super.key});

  @override
  State<ThemeListScreen> createState() => _ThemeListScreenState();
}

class _ThemeListScreenState extends State<ThemeListScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Minimal', 'Nature', 'Vibrant', 'Dark'];

  List<_MockTheme> get _filteredThemes {
    if (_selectedCategory == 'All') return _mockThemes;
    return _mockThemes
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter chips
          _buildCategoryFilter(theme),
          // Theme grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 3
                    : constraints.maxWidth > 500
                        ? 2
                        : 1;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredThemes.length,
                  itemBuilder: (context, index) {
                    return _buildThemeCard(context, _filteredThemes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, _MockTheme mockTheme) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.themeDetail,
            arguments: mockTheme.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme color preview
            _buildThemePreview(mockTheme),
            // Theme info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mockTheme.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mockTheme.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Active',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        mockTheme.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(_MockTheme mockTheme) {
    return Container(
      height: 140,
      color: mockTheme.backgroundColor,
      child: Stack(
        children: [
          // Mock storefront layout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nav bar mock
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: mockTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Hero banner mock
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: mockTheme.accentColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: mockTheme.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Product cards mock
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Container(
                        height: 36,
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: mockTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                mockTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: mockTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                mockTheme.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
