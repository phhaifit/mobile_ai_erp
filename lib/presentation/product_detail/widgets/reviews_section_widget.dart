import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:intl/intl.dart';

class ReviewsSectionWidget extends StatelessWidget {
  final List<ProductReview> reviews;
  final double averageRating;
  final int reviewCount;

  const ReviewsSectionWidget({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Reviews',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _RatingSummary(
          averageRating: averageRating,
          reviewCount: reviewCount,
          reviews: reviews,
        ),
        const SizedBox(height: 20),
        ...reviews.map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ReviewCard(review: review, colorScheme: colorScheme),
            )),
        if (reviewCount > reviews.length)
          Center(
            child: OutlinedButton(
              onPressed: () => _openAllReviews(context),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('View All $reviewCount Reviews'),
            ),
          ),
      ],
    );
  }

  void _openAllReviews(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AllReviewsPage(
          reviews: reviews,
          averageRating: averageRating,
          reviewCount: reviewCount,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-page "All Reviews" screen
// ---------------------------------------------------------------------------

class _AllReviewsPage extends StatelessWidget {
  final List<ProductReview> reviews;
  final double averageRating;
  final int reviewCount;

  const _AllReviewsPage({
    required this.reviews,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Reviews ($reviewCount)'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _RatingSummary(
                averageRating: averageRating,
                reviewCount: reviewCount,
                reviews: reviews,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ReviewCard(
              review: reviews[index - 1],
              colorScheme: colorScheme,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rating summary card
// ---------------------------------------------------------------------------

class _RatingSummary extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final List<ProductReview> reviews;

  const _RatingSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  Map<int, int> get _distribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final star = r.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dist = _distribution;
    final maxCount =
        dist.values.fold(0, (a, b) => a > b ? a : b).clamp(1, 999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              _StarRow(rating: averageRating, size: 18),
              const SizedBox(height: 4),
              Text(
                '$reviewCount reviews',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        child: Text(
                          '$star',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: count / maxCount,
                            minHeight: 6,
                            backgroundColor:
                                colorScheme.onSurface.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amber),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single review card
// ---------------------------------------------------------------------------

class _ReviewCard extends StatelessWidget {
  final ProductReview review;
  final ColorScheme colorScheme;

  const _ReviewCard({required this.review, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy').format(review.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _StarRow(rating: review.rating, size: 13),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (review.imageUrls != null && review.imageUrls!.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(
                      context,
                      review.imageUrls!,
                      index,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.imageUrls![index],
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: colorScheme.secondary,
                          child: Icon(
                            Icons.image_outlined,
                            color:
                                colorScheme.onSecondary.withValues(alpha: 0.4),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => _ReviewImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fullscreen review image viewer
// ---------------------------------------------------------------------------

class _ReviewImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ReviewImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ReviewImageViewer> createState() => _ReviewImageViewerState();
}

class _ReviewImageViewerState extends State<_ReviewImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: widget.imageUrls.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              )
            : null,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Star row helper
// ---------------------------------------------------------------------------

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (rating >= starValue - 0.5) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }),
    );
  }
}
