import 'package:flutter/material.dart';

class FancyActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final bool isPrimary; // True for Play, False for Download/Secondary

  const FancyActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24.0,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(size * 0.3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFA91079), Color(0xFFD62976)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: !isPrimary ? Border.all(color: Colors.white24, width: 1) : null,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFA91079).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}
