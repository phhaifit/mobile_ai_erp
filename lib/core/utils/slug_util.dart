/// Utility for generating URL-friendly slugs from strings.
class SlugUtil {
  /// Converts a string to a URL-friendly slug.
  ///
  /// Converts to lowercase, removes special characters (replacing with hyphens),
  /// and trims leading/trailing hyphens. Returns 'category' if result is empty.
  ///
  /// Examples:
  /// ```dart
  /// SlugUtil.slugify('Hello World') => 'hello-world'
  /// SlugUtil.slugify('Fashion & Style') => 'fashion-style'
  /// SlugUtil.slugify('  Test  ') => 'test'
  /// SlugUtil.slugify('!!!') => 'category'
  /// ```
  static String slugify(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'category' : slug;
  }
}
