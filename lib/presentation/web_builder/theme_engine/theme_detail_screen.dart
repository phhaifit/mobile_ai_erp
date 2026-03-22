import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/web_theme_store.dart';

class ThemeDetailScreen extends StatefulWidget {
  const ThemeDetailScreen({super.key});

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  final WebThemeStore _store = getIt<WebThemeStore>();
  WebTheme? _themeData;
  bool _loaded = false;

  late Color _customPrimary;
  late Color _customAccent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final themeId =
          ModalRoute.of(context)?.settings.arguments as String? ?? '1';
      _loadTheme(themeId);
      _loaded = true;
    }
  }

  Future<void> _loadTheme(String id) async {
    await _store.getThemeById(id);
    if (_store.selectedTheme != null && mounted) {
      setState(() {
        _themeData = _store.selectedTheme;
        _customPrimary = Color(_themeData!.primaryColor ?? 0xFF000000);
        _customAccent = Color(_themeData!.accentColor ?? 0xFFCCCCCC);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_themeData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Theme')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final bgColor = Color(_themeData!.backgroundColor ?? 0xFFFFFFFF);

    return Scaffold(
      appBar: AppBar(
        title: Text(_themeData!.name ?? ''),
        actions: [
          if (_themeData!.isActive == true)
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
            _buildLivePreview(bgColor),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this theme', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _themeData!.description ?? '',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailsSection(theme),
                  const SizedBox(height: 24),
                  _buildColorCustomization(theme),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreview(Color bgColor) {
    return Container(
      width: double.infinity,
      height: 280,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _buildDetailRow(theme, 'Category', _themeData!.category ?? ''),
            const Divider(height: 20),
            _buildDetailRow(theme, 'Fonts', (_themeData!.fonts ?? []).join(', ')),
            const Divider(height: 20),
            _buildDetailRow(
                theme, 'Status', _themeData!.isActive == true ? 'Active' : 'Inactive'),
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
    final origPrimary = Color(_themeData!.primaryColor ?? 0xFF000000);
    final origAccent = Color(_themeData!.accentColor ?? 0xFFCCCCCC);

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
        if (_customPrimary != origPrimary || _customAccent != origAccent)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _customPrimary = origPrimary;
                _customAccent = origAccent;
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
    final origPrimary = Color(_themeData!.primaryColor ?? 0xFF000000);
    final origAccent = Color(_themeData!.accentColor ?? 0xFFCCCCCC);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _customPrimary = origPrimary;
                _customAccent = origAccent;
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
            onPressed: () async {
              await _store.applyTheme(
                _themeData!.id!,
                primaryColor: _customPrimary.toARGB32(),
                accentColor: _customAccent.toARGB32(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _themeData!.isActive == true
                        ? 'Theme settings updated!'
                        : 'Theme "${_themeData!.name}" activated!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            icon: Icon(
                _themeData!.isActive == true ? Icons.save : Icons.check_circle_outline),
            label: Text(_themeData!.isActive == true ? 'Save Changes' : 'Apply Theme'),
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
