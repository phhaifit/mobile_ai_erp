import 'package:flutter/material.dart';

class LoyaltyPointCard extends StatelessWidget {
  final int points;
  final VoidCallback? onTap; // 1. Add the callback

  const LoyaltyPointCard({
    super.key,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // 2. Wrap with InkWell to make it clickable
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loyalty Points',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Add a small hint that it's clickable
                Text(
                  'Tap to view history >',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
            Text(
              '$points pts',
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}