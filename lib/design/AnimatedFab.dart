import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/chatbot_page.dart';

class AnimatedFab extends StatefulWidget {
  const AnimatedFab({super.key});

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));

    _colorAnimation =
        ColorTween(begin: Colors.blueAccent, end: Colors.deepPurpleAccent)
            .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return FloatingActionButton(
            onPressed: () => Get.to(() => ChatbotPage()),
            backgroundColor: _colorAnimation.value,
            foregroundColor: Colors.white,
            child: const Icon(Icons.message, size: 28),
          );
        },
      ),
    );
  }
}
