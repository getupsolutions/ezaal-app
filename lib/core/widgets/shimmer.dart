// universal_shimmer.dart
import 'package:flutter/material.dart';

enum ShimmerDirection { ltr, rtl, ttb, btt, tlbr, trbl }

class UniversalShimmer extends StatefulWidget {
  /// If [child] is provided, the shimmer will be applied over the child.
  /// If [child] is null, a plain rectangular placeholder is shown (useful with width/height).
  final Widget? child;

  /// Colors for base and highlight
  final Color baseColor;
  final Color highlightColor;

  /// Animation loop duration
  final Duration period;

  /// Border radius for the placeholder or for applying rounded corners to child mask
  final BorderRadius? borderRadius;

  /// If false, just show the child (no shimmer).
  final bool enabled;

  /// Direction of shimmer animation
  final ShimmerDirection direction;

  /// Optional width/height when child==null
  final double? width;
  final double? height;

  const UniversalShimmer({
    Key? key,
    this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.period = const Duration(milliseconds: 1400),
    this.borderRadius,
    this.enabled = true,
    this.direction = ShimmerDirection.ltr,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _UniversalShimmerState createState() => _UniversalShimmerState();
}

class _UniversalShimmerState extends State<UniversalShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(covariant UniversalShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      _controller.reset();
      _controller.repeat();
    }
    if (!widget.enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build gradient aligned to direction and animated by offset
  LinearGradient _createGradient(double slide) {
    // center of the highlight moves with `slide` value
    // highlight is the middle color stop
    final colors = [widget.baseColor, widget.highlightColor, widget.baseColor];

    // create stops such that highlight is narrow
    final double highlightWidth = 0.2;
    final double mid = slide.clamp(-1.0, 2.0); // safe bounds

    final stops = [
      (mid - highlightWidth / 2).clamp(0.0, 1.0),
      (mid).clamp(0.0, 1.0),
      (mid + highlightWidth / 2).clamp(0.0, 1.0),
    ];

    // Determine begin/end based on direction
    Alignment begin = Alignment.centerLeft;
    Alignment end = Alignment.centerRight;

    switch (widget.direction) {
      case ShimmerDirection.ltr:
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
      case ShimmerDirection.rtl:
        begin = Alignment.centerRight;
        end = Alignment.centerLeft;
        break;
      case ShimmerDirection.ttb:
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
      case ShimmerDirection.btt:
        begin = Alignment.bottomCenter;
        end = Alignment.topCenter;
        break;
      case ShimmerDirection.tlbr:
        begin = Alignment.topLeft;
        end = Alignment.bottomRight;
        break;
      case ShimmerDirection.trbl:
        begin = Alignment.topRight;
        end = Alignment.bottomLeft;
        break;
    }

    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
      tileMode: TileMode.clamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If shimmer disabled, return child or placeholder as-is
    if (!widget.enabled) {
      return widget.child ??
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 12.0,
            decoration: BoxDecoration(
              color: widget.baseColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
            ),
          );
    }

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(6.0);

    final child =
        widget.child ??
        Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 12.0,
          decoration: BoxDecoration(
            color: widget.baseColor,
            borderRadius: borderRadius,
          ),
        );

    // Wrap in AnimatedBuilder for performance; ShaderMask paints the gradient over child
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final slide = _shimmerAnimation.value;
        final gradient = _createGradient(slide);

        return ClipRRect(
          borderRadius: borderRadius,
          child: ShaderMask(
            shaderCallback: (bounds) {
              // Create a rectangle gradient large enough for animation
              return gradient.createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: child,
          ),
        );
      },
    );
  }
}

/// Small helper: Skeleton placeholders that combine shapes (circle/rect) and spacing
class ShimmerSkeleton extends StatelessWidget {
  final int lines;
  final double spacing;
  final double lineHeight;
  final BorderRadius borderRadius;
  final bool showAvatar;
  final double avatarRadius;
  final double widthFactor; // width of each line as fraction (0..1)
  final UniversalShimmer shimmerConfig;

  const ShimmerSkeleton({
    Key? key,
    this.lines = 3,
    this.spacing = 8,
    this.lineHeight = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.showAvatar = false,
    this.avatarRadius = 24,
    this.widthFactor = 0.85,
    this.shimmerConfig = const UniversalShimmer(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (showAvatar) {
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UniversalShimmer(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              borderRadius: BorderRadius.circular(avatarRadius),
              baseColor: shimmerConfig.baseColor,
              highlightColor: shimmerConfig.highlightColor,
              period: shimmerConfig.period,
              enabled: true,
              child: const SizedBox.shrink(),
            ),
            SizedBox(width: spacing.toDouble()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  lines,
                  (i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i == lines - 1 ? 0 : spacing.toDouble(),
                    ),
                    child: UniversalShimmer(
                      width: double.infinity,
                      height: lineHeight,
                      borderRadius: borderRadius,
                      baseColor: shimmerConfig.baseColor,
                      highlightColor: shimmerConfig.highlightColor,
                      period: shimmerConfig.period,
                      enabled: true,
                      child: FractionallySizedBox(
                        widthFactor: widthFactor - (i * 0.05).clamp(0.0, 0.25),
                        alignment: Alignment.centerLeft,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      children.addAll(
        List.generate(
          lines,
          (i) => Padding(
            padding: EdgeInsets.only(
              bottom: i == lines - 1 ? 0 : spacing.toDouble(),
            ),
            child: UniversalShimmer(
              width: double.infinity,
              height: lineHeight,
              borderRadius: borderRadius,
              baseColor: shimmerConfig.baseColor,
              highlightColor: shimmerConfig.highlightColor,
              period: shimmerConfig.period,
              enabled: true,
              child: FractionallySizedBox(
                widthFactor: widthFactor - (i * 0.05).clamp(0.0, 0.25),
                alignment: Alignment.centerLeft,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    }

    return Column(children: children);
  }
}
