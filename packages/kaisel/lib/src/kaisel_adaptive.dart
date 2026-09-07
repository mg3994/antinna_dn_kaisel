import 'dartnative_framework.dart';

/// Layout mode for [KaiselAdaptive].
enum AdaptiveLayoutMode {
  /// Stack mode — single pane view.
  stack,

  /// Split mode — dual pane master-detail view.
  split,
}

/// Builder for multi-pane adaptive layouts (e.g. Master-Detail on tablet / desktop).
typedef AdaptivePaneBuilder = Widget Function(
  BuildContext context,
  AdaptiveLayoutMode mode,
  Widget master,
  Widget? detail,
);

/// A responsive adaptive layout widget that presents a single stack or a dual split-pane.
class KaiselAdaptive extends StatefulWidget {
  const KaiselAdaptive({
    super.key,
    required this.isCompact,
    required this.master,
    this.detail,
    required this.builder,
  });

  /// Whether the current screen breakpoint is compact (e.g. phone portrait).
  final bool isCompact;

  /// The master pane widget.
  final Widget master;

  /// The detail pane widget (if available).
  final Widget? detail;

  /// Layout builder.
  final AdaptivePaneBuilder builder;

  @override
  State<KaiselAdaptive> createState() => _KaiselAdaptiveState();
}

class _KaiselAdaptiveState extends State<KaiselAdaptive> {
  @override
  Widget build(BuildContext context) {
    final mode = widget.isCompact || widget.detail == null
        ? AdaptiveLayoutMode.stack
        : AdaptiveLayoutMode.split;

    return widget.builder(
      context,
      mode,
      widget.master,
      widget.detail,
    );
  }
}
