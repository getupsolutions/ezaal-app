import 'package:flutter/material.dart';

class TopToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onFinish;

   const TopToast({super.key, 
    required this.message,
    required this.duration,
    required this.onFinish,
  });

  @override
  State<TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<TopToast> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    // Fade in
    Future.microtask(() {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });

    // Stay, then fade out, then remove
    Future.delayed(widget.duration, () {
      if (!mounted) return;
      setState(() => _opacity = 0);

      Future.delayed(const Duration(milliseconds: 250), () {
        widget.onFinish();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return IgnorePointer(
      ignoring: true, // no clicks, no buttons
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 250),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: BoxConstraints(maxWidth: media.size.width * 0.92),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
