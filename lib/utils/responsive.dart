import 'package:flutter/material.dart';

/// Shared breakpoints used across the app so every screen agrees on what
/// counts as "mobile", "tablet" and "desktop" width.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

bool isMobileWidth(double width) => width < Breakpoints.mobile;
bool isTabletWidth(double width) => width >= Breakpoints.mobile && width < Breakpoints.desktop;
bool isDesktopWidth(double width) => width >= Breakpoints.desktop;

bool isMobile(BuildContext context) => isMobileWidth(MediaQuery.sizeOf(context).width);
bool isTablet(BuildContext context) => isTabletWidth(MediaQuery.sizeOf(context).width);
bool isDesktop(BuildContext context) => isDesktopWidth(MediaQuery.sizeOf(context).width);

/// Returns a value scaled to the current screen width, useful for paddings
/// and font sizes that should grow slightly on tablets/desktops without
/// needing a bespoke LayoutBuilder on every screen.
double responsiveValue(
  BuildContext context, {
  required double mobile,
  double? tablet,
  double? desktop,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (isDesktopWidth(width)) return desktop ?? tablet ?? mobile;
  if (isTabletWidth(width)) return tablet ?? mobile;
  return mobile;
}

/// Horizontal page padding that grows a little on wider screens so content
/// doesn't hug the edges on tablets/desktops, while staying compact on
/// phones.
double responsiveHorizontalPadding(BuildContext context) => responsiveValue(
      context,
      mobile: 20,
      tablet: 32,
      desktop: 48,
    );

/// Wraps [child] so that on large screens (tablets in landscape, desktop
/// browser windows, etc.) the content is centered with a sensible maximum
/// width instead of stretching edge-to-edge and becoming hard to read, while
/// phones keep using the full available width untouched.
///
/// Used once, app-wide, via [MaterialApp.builder] in `app.dart` so every
/// screen (including pushed detail/create screens) gets consistent
/// responsive behavior without needing to be edited individually.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= maxWidth) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}