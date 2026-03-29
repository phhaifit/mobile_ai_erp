import 'package:flutter/material.dart';

/// Empty state UI for shopping cart
class EmptyCartState extends StatelessWidget {
  final VoidCallback onContinueShopping;
  final String? title;
  final String? message;
  final String? buttonText;
  final IconData? icon;

  const EmptyCartState({
    Key? key,
    required this.onContinueShopping,
    this.title,
    this.message,
    this.buttonText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.shopping_cart_outlined,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title ?? 'Your Cart is Empty',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message ?? 'Start shopping to add items to your cart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Button
              ElevatedButton(
                onPressed: onContinueShopping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText ?? 'Continue Shopping',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state with illustration option
class EmptyCartIllustration extends StatelessWidget {
  final String? illustrationUrl;

  const EmptyCartIllustration({
    Key? key,
    this.illustrationUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration or placeholder
          if (illustrationUrl != null)
            Image.network(
              illustrationUrl!,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            )
          else
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Empty Cart',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Nothing in your cart yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
