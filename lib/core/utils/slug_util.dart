/// Utility for generating URL-friendly slugs from strings.
class SlugUtil {
  /// Converts a string to a URL-friendly slug.
  ///
  /// Converts to lowercase, removes Vietnamese accents/diacritics,
  /// replaces non-alphanumeric characters with hyphens,
  /// and trims leading/trailing hyphens.
  ///
  /// Examples:
  /// ```dart
  /// SlugUtil.slugify('Áo nam') => 'ao-nam'
  /// SlugUtil.slugify('Fashion & Style') => 'fashion-style'
  /// SlugUtil.slugify('  Test  ') => 'test'
  /// ```
  static String slugify(String value) {
    if (value.trim().isEmpty) {
      return 'category';
    }

    var result = value.trim().toLowerCase();

    // Remove Vietnamese accents/diacritics
    result = result.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    result = result.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    result = result.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    result = result.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    result = result.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    result = result.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    result = result.replaceAll(RegExp(r'[đ]'), 'd');

    final slug = result
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // remove non-alphanumeric (keep spaces and hyphens)
        .replaceAll(RegExp(r'[\s_]+'), '-') // spaces/underscores → hyphens
        .replaceAll(RegExp(r'-+'), '-') // collapse multiple hyphens
        .replaceAll(RegExp(r'^-+|-+$'), ''); // trim leading/trailing hyphens

    return slug.isEmpty ? 'category' : slug;
  }
}
