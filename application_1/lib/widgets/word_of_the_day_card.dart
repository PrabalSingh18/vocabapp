import 'package:flutter/material.dart';
import '../wordmodel.dart'; 

class WordOfTheDayCard extends StatelessWidget {
  final WordData word;
  final VoidCallback onTap;

  const WordOfTheDayCard({super.key, required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          // UPDATED: Used .withValues(alpha: ...) to resolve deprecation
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "WORD OF THE DAY",
                      style: TextStyle(
                        // UPDATED: Modern alpha handling
                        color: Colors.amber.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 14, 
                  color: Colors.white.withValues(alpha: 0.3)
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              word.word.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                // UPDATED: High precision opacity
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}