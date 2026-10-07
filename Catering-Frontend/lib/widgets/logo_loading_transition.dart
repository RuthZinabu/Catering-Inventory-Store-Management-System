import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Professional loading animation using the app's logo with smooth reveal,
/// scale, and orbital motion effects.
///
/// Inspired by premium food app loading patterns with an original implementation.
class LogoLoadingTransition extends StatefulWidget {
  /// Size of the logo (width and height)
  final double size;

  /// Duration of one complete animation cycle
  final Duration duration;

  /// Background color (defaults to transparent)
  final Color? backgroundColor;

  /// Whether the animation should repeat indefinitely
  final bool repeat;

  /// Path to the logo asset
  final String? logoAssetPath;

  const LogoLoadingTransition({
    super.key,
    this.size = 120,
    this.duration = const Duration(milliseconds: 2200),
    this.backgroundColor,
    this.repeat = true,
    this.logoAssetPath,
  });

  @override
  State<LogoLoadingTransition> createState() => _LogoLoadingTransitionState();
}

class _LogoLoadingTransitionState extends State<LogoLoadingTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _orbitalAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Reveal animation: 0.0 to 1.0 (first 40% of duration)
    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    );

    // Scale animation: subtle pulse after reveal (40% to 75% of duration)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40.0, // Stay at 1.0 during reveal
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.90)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.90, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 25.0, // Pause before repeat
      ),
    ]).animate(_controller);

    // Rotation animation: small tilt during motion (40% to 75% of duration)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.03)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 17.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.03, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 17.5,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 25.0,
      ),
    ]).animate(_controller);

    // Orbital animation: rotating arcs around the logo
    _orbitalAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: SizedBox(
          width: widget.size * 1.8,
          height: widget.size * 1.8,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _LogoLoadingPainter(
                  revealProgress: _revealAnimation.value,
                  scale: _scaleAnimation.value,
                  rotation: _rotationAnimation.value,
                  orbitalProgress: _orbitalAnimation.value,
                ),
                child: Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Opacity(
                        opacity: _revealAnimation.value,
                        child: ClipPath(
                          clipper: _RevealClipper(_revealAnimation.value),
                          child: widget.logoAssetPath != null
                              ? Image.asset(
                                  widget.logoAssetPath!,
                                  width: widget.size,
                                  height: widget.size,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  'assets/images/halal_logo.png',
                                  width: widget.size,
                                  height: widget.size,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom clipper to reveal logo progressively from bottom to top
class _RevealClipper extends CustomClipper<Path> {
  final double progress;

  _RevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final revealHeight = size.height * progress;

    path.addRect(Rect.fromLTWH(
      0,
      size.height - revealHeight,
      size.width,
      revealHeight,
    ));

    return path;
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// Custom painter for orbital motion effects around the logo
class _LogoLoadingPainter extends CustomPainter {
  final double revealProgress;
  final double scale;
  final double rotation;
  final double orbitalProgress;

  _LogoLoadingPainter({
    required this.revealProgress,
    required this.scale,
    required this.rotation,
    required this.orbitalProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only show orbital effects after logo is mostly revealed
    if (revealProgress < 0.3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Dark green color matching the logo
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Calculate opacity based on animation progress
    final orbitalOpacity = (revealProgress - 0.3) / 0.7;
    paint.color = paint.color.withOpacity(0.15 * orbitalOpacity);

    // Draw 3 rotating arcs at different positions
    for (int i = 0; i < 3; i++) {
      final angle = (orbitalProgress * 2 * math.pi) + (i * 2 * math.pi / 3);
      final arcSweepAngle = math.pi / 3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + (i * 8)),
        angle,
        arcSweepAngle,
        false,
        paint,
      );
    }

    // Draw small orbiting dots
    if (revealProgress > 0.6) {
      final dotPaint = Paint()
        ..color = const Color(0xFF1B5E20).withOpacity(0.3 * orbitalOpacity)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 2; i++) {
        final angle = (orbitalProgress * 2 * math.pi) + (i * math.pi);
        final dotRadius = radius + 15;
        final dotX = center.dx + dotRadius * math.cos(angle);
        final dotY = center.dy + dotRadius * math.sin(angle);

        canvas.drawCircle(Offset(dotX, dotY), 3.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_LogoLoadingPainter oldDelegate) {
    return oldDelegate.revealProgress != revealProgress ||
        oldDelegate.scale != scale ||
        oldDelegate.rotation != rotation ||
        oldDelegate.orbitalProgress != orbitalProgress;
  }
}
