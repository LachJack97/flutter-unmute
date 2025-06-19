import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedEllipsis extends StatefulWidget {
  final TextStyle? style;
  final Duration dotDelay;
  final int numberOfDots;
  final double minOpacity;
  final double maxOpacity;

  const AnimatedEllipsis({
    super.key,
    this.style,
    this.dotDelay = const Duration(milliseconds: 300),
    this.numberOfDots = 3,
    this.minOpacity = 0.2,
    this.maxOpacity = 1.0,
  });

  @override
  AnimatedEllipsisState createState() => AnimatedEllipsisState();
}

class AnimatedEllipsisState extends State<AnimatedEllipsis>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _dotAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.dotDelay * widget.numberOfDots,
    )..repeat();

    for (int i = 0; i < widget.numberOfDots; i++) {
      _dotAnimations.add(
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 50.0,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: widget.maxOpacity, end: widget.minOpacity)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 50.0,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (i / widget.numberOfDots) * 0.5, // Start time for this dot's animation phase
              (i / widget.numberOfDots) * 0.5 + 0.5, // End time, ensuring overlap for smoother effect
              curve: Curves.linear, // The overall interval curve
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = widget.style ?? defaultTextStyle.style;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.numberOfDots, (index) {
        return FadeTransition(
          opacity: _dotAnimations[index],
          child: Text('.', style: effectiveTextStyle),
        );
      }),
    );
  }
}