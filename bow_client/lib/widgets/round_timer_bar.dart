import 'package:flutter/material.dart';

/// Smoothly animates [progress] (1.0 = full time left, 0 = empty).
/// When [progress] &lt; [lowThreshold], the bar pulses with a red glow.
class RoundTimerBar extends StatefulWidget {
  const RoundTimerBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.lowThreshold = 0.25,
  });

  final double progress;
  final double height;
  final double lowThreshold;

  @override
  State<RoundTimerBar> createState() => _RoundTimerBarState();
}

class _RoundTimerBarState extends State<RoundTimerBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant RoundTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.lowThreshold != widget.lowThreshold) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    final low = widget.progress < widget.lowThreshold && widget.progress > 0;
    if (low) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        final low = animatedValue < widget.lowThreshold && animatedValue > 0;

        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final pulseT = low ? _pulse.value : 0.0;
            final glow = low ? 8.0 + 14.0 * pulseT : 0.0;
            final scaleY = low ? 1.0 + 0.12 * pulseT : 1.0;

            return Transform.scale(
              scaleY: scaleY,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: low
                      ? [
                          BoxShadow(
                            color: Color.lerp(
                              const Color(0xFFFF4444),
                              const Color(0xFFFF1744),
                              pulseT,
                            )!.withOpacity(0.55 + 0.25 * pulseT),
                            blurRadius: glow,
                            spreadRadius: 1.5 + pulseT,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: widget.height,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth * animatedValue;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: Colors.black.withOpacity(0.28)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                width: w,
                                height: widget.height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: low
                                      ? LinearGradient(
                                          colors: [
                                            Color.lerp(
                                              const Color(0xFFFF8A80),
                                              const Color(0xFFFF5252),
                                              pulseT,
                                            )!,
                                            Color.lerp(
                                              const Color(0xFFFF1744),
                                              const Color(0xFFD50000),
                                              pulseT,
                                            )!,
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFE0F2FE),
                                            Color(0xFFFFFFFF),
                                          ],
                                        ),
                                  boxShadow: low
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFF8A80)
                                                .withOpacity(0.45 + 0.35 * pulseT),
                                            blurRadius: 6 + 6 * pulseT,
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.35),
                                            blurRadius: 4,
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
