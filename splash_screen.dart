import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:tripvisor/screens/landing_screen.dart';
import 'package:tripvisor/widgets/tripvisor_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late AnimationController _particleController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Setup animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 1.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    // Start animations
    _startAnimations();
    
    // Navigate to landing screen after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LandingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void _startAnimations() async {
    // Start background and particle animations immediately
    _backgroundController.forward();
    _particleController.repeat();
    
    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _logoController.forward();
    }
    
    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _textController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _backgroundAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1976D2), // Deep blue sky
                        Color(0xFF42A5F5), // Light blue
                        Color(0xFF66BB6A), // Green landscape
                        Color(0xFFFFB74D), // Sunset orange
                        Color(0xFFFF8A65), // Warm orange
                      ],
                      stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Animated particles
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(_particleAnimation),
              );
            },
          ),
          
          // Travel-themed background elements
          Positioned.fill(
            child: CustomPaint(
              painter: TravelBackgroundPainter(_backgroundAnimation),
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value * 0.1, // Subtle rotation
                        child: Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 25,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Custom logo using reusable widget
                                TripVisorLogo(
                                  size: 120,
                                  showShadow: true,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  logoPath: 'assets/images/logo.png',
                                ),
                                Positioned(
                                  bottom: 25,
                                  right: 25,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 25,
                                    color: Color(0xFFFF5722),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Animated app name
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFE3F2FD)],
                              ).createShader(bounds),
                              child: const Text(
                                'TripVisor',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Travel Companion',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Enhanced loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preparing your journey...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  
  ParticlePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw floating particles (stars, sparkles)
    _drawParticles(canvas, size, paint);
  }
  
  void _drawParticles(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.6);
    
    final particleOffset = animation.value * 100;
    
    // Create floating particles
    for (int i = 0; i < 15; i++) {
      final x = (size.width / 15 * i + particleOffset + i * 20) % size.width;
      final y = (size.height / 10 * (i % 5) + math.sin(animation.value * 2 * math.pi + i) * 20);
      
      if (y > 0 && y < size.height) {
        // Draw sparkle
        _drawSparkle(canvas, Offset(x, y), paint, 2 + math.sin(animation.value * 4 * math.pi + i));
      }
    }
  }
  
  void _drawSparkle(Canvas canvas, Offset center, Paint paint, double size) {
    // Draw a small sparkle/star shape
    canvas.drawCircle(center, size, paint);
    
    // Add cross lines for sparkle effect
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(center.dx - size * 2, center.dy),
      Offset(center.dx + size * 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 2),
      Offset(center.dx, center.dy + size * 2),
      paint,
    );
    
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TravelBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  
  TravelBackgroundPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw animated clouds
    _drawClouds(canvas, size, paint);
    
    // Draw animated mountains
    _drawMountains(canvas, size, paint);
    
    // Draw animated birds
    _drawBirds(canvas, size, paint);
    
    // Draw sun
    _drawSun(canvas, size, paint);
  }
  
  void _drawSun(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.yellow.withOpacity(0.3);
    
    // Sun position
    final sunCenter = Offset(size.width * 0.8, size.height * 0.25);
    
    // Sun rays
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.yellow.withOpacity(0.4);
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + animation.value * math.pi / 4;
      final startX = sunCenter.dx + math.cos(angle) * 35;
      final startY = sunCenter.dy + math.sin(angle) * 35;
      final endX = sunCenter.dx + math.cos(angle) * 50;
      final endY = sunCenter.dy + math.sin(angle) * 50;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
    
    // Sun circle
    paint.style = PaintingStyle.fill;
    paint.color = Colors.yellow.withOpacity(0.2);
    canvas.drawCircle(sunCenter, 30, paint);
  }
  
  void _drawClouds(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.4);
    
    final cloudOffset = animation.value * 15;
    
    // Cloud 1
    _drawCloud(canvas, Offset(size.width * 0.15 + cloudOffset, size.height * 0.2), paint, 1.0);
    
    // Cloud 2
    _drawCloud(canvas, Offset(size.width * 0.7 - cloudOffset * 0.5, size.height * 0.15), paint, 0.8);
    
    // Cloud 3
    _drawCloud(canvas, Offset(size.width * 0.4 + cloudOffset * 0.3, size.height * 0.3), paint, 0.6);
  }
  
  void _drawCloud(Canvas canvas, Offset center, Paint paint, double scale) {
    canvas.drawCircle(Offset(center.dx - 15 * scale, center.dy), 20 * scale, paint);
    canvas.drawCircle(Offset(center.dx, center.dy - 5 * scale), 25 * scale, paint);
    canvas.drawCircle(Offset(center.dx + 15 * scale, center.dy), 22 * scale, paint);
    canvas.drawCircle(Offset(center.dx + 25 * scale, center.dy + 5 * scale), 18 * scale, paint);
  }
  
  void _drawMountains(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.black.withOpacity(0.15);
    
    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.4, size.height * 0.65);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add mountain peaks with snow
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.55), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.5), 10, paint);
  }
  
  void _drawBirds(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.7);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    final birdOffset = animation.value * 40;
    
    // Flying birds
    _drawBird(canvas, Offset(size.width * 0.6 + birdOffset, size.height * 0.3), paint);
    _drawBird(canvas, Offset(size.width * 0.65 + birdOffset, size.height * 0.35), paint);
    _drawBird(canvas, Offset(size.width * 0.7 + birdOffset, size.height * 0.32), paint);
  }
  
  void _drawBird(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    // Left wing
    path.moveTo(center.dx - 6, center.dy);
    path.quadraticBezierTo(center.dx - 2, center.dy - 4, center.dx + 2, center.dy);
    // Right wing
    path.moveTo(center.dx - 6, center.dy);
    path.quadraticBezierTo(center.dx - 2, center.dy + 4, center.dx + 2, center.dy);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
