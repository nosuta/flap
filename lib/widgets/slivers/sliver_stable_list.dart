import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// A SliverList that can apply a scroll offset correction
/// (e.g., when items are inserted at the top) to keep the
/// viewport visually stable.
class SliverStableList extends SuperSliverList {
  const SliverStableList({super.key, required super.delegate});

  SliverStableList.builder({
    super.key,
    required super.itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.extentPrecalculationPolicy,
    super.listController,
    super.extentEstimation,
    super.delayPopulatingCacheArea,
    super.layoutKeptAliveChildren,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.builder();

  @override
  RenderSliverStableList createRenderObject(BuildContext context) {
    // The element implements RenderSliverBoxChildManager.
    return RenderSliverStableList(
      childManager: context as SliverMultiBoxAdaptorElement,
    );
  }
}

/// Render object that subclasses the stock RenderSliverList
/// and injects scrollOffsetCorrection when requested.
class RenderSliverStableList extends RenderSliverList {
  RenderSliverStableList({required super.childManager});

  double _pendingCorrection = 0.0;

  /// Call this after you prepend items to tell the sliver
  /// how much vertical extent was inserted above the viewport.
  void applyTopInsertExtent(double extent) {
    if (extent == 0) return;
    _pendingCorrection += extent;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // If we have a pending correction, publish it and exit early.
    if (_pendingCorrection != 0.0) {
      geometry = SliverGeometry(scrollOffsetCorrection: _pendingCorrection);
      _pendingCorrection = 0.0;
      return;
    }
    // Otherwise, do normal SliverList layout.
    super.performLayout();
  }
}
