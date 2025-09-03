import 'package:flutter/material.dart';

class TripVisorLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final Color? backgroundColor;
  final String? logoPath;

  const TripVisorLogo({
    super.key,
    this.size = 60,
    this.showShadow = false,
    this.backgroundColor,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = logoPath ?? 'assets/images/logo.png';
    
    Widget logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to branded airplane icon
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF1976D2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.airplanemode_active,
                size: size * 0.6,
                color: const Color(0xFF1976D2),
              ),
            );
          },
        ),
      ),
    );

    return logoWidget;
  }
}

class TripVisorLogoWithText extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final bool showShadow;
  final MainAxisAlignment alignment;
  final Color? textColor;
  final String? logoPath;

  const TripVisorLogoWithText({
    super.key,
    this.logoSize = 40,
    this.fontSize = 24,
    this.showShadow = false,
    this.alignment = MainAxisAlignment.center,
    this.textColor,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        TripVisorLogo(
          size: logoSize,
          showShadow: showShadow,
          logoPath: logoPath,
        ),
        const SizedBox(width: 12),
        Text(
          'TripVisor',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor ?? Theme.of(context).primaryColor,
            shadows: showShadow
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

// App Bar Logo Component
class AppBarLogo extends StatelessWidget {
  final double size;
  final String? logoPath;

  const AppBarLogo({
    super.key,
    this.size = 35,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return TripVisorLogo(
      size: size,
      logoPath: logoPath,
      backgroundColor: Colors.white.withOpacity(0.1),
    );
  }
}

// Loading Screen Logo
class LoadingLogo extends StatefulWidget {
  final double size;
  final String? logoPath;

  const LoadingLogo({
    super.key,
    this.size = 80,
    this.logoPath,
  });

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: TripVisorLogo(
            size: widget.size,
            showShadow: true,
            logoPath: widget.logoPath,
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
