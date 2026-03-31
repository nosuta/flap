import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProgressIndicatorHeader extends SliverPersistentHeaderDelegate {
  const ProgressIndicatorHeader({
    required this.loading,
    required this.pulling,
    required this.guide,
  });

  final bool loading;
  final bool pulling;
  final bool guide;

  @override
  double get minExtent => 3;

  @override
  double get maxExtent => 3;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 3,
      child: loading
          ? LinearProgressIndicator()
          : pulling
          ? LinearProgressIndicator(color: scheme.shadow)
          : guide
          ? ColoredBox(color: scheme.secondary)
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fade(duration: 1000.ms, curve: Curves.ease, begin: 1, end: 0.5)
          : null,
    );
  }

  @override
  bool shouldRebuild(ProgressIndicatorHeader oldDelegate) {
    return oldDelegate != this;
  }
}
