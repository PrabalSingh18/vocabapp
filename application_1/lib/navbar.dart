import 'dart:ui';
import 'package:flutter/material.dart';
import 'favorites_page.dart';
// Ensure this import points to the file holding the SettingsScreen class we just created
import 'settingscreen.dart'; 

class BottomNavBar extends StatelessWidget {
  // Removed the unused onProfileTap callback

  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Container with a small height to keep it "regular"
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          // Standard mobile BottomAppBar height
          height: 65,
          decoration: BoxDecoration(
            // FIX: Changed .withOpacity to modern .withValues
            color: Colors.black.withValues(alpha: 0.2), // Dark transparent look
            border: const Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Home Icon
              IconButton(
                icon: const Icon(Icons.home_filled, color: Colors.white70, size: 24),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
              ),

              // Favorites Icon
              IconButton(
                icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesPage()),
                  );
                },
              ),

              // Profile Icon
              IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white70, size: 24),
                onPressed: () {
                  // This line now works because SettingsScreen is defined
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}