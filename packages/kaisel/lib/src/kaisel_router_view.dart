import 'package:kaisel_core/kaisel_core.dart';
import 'dartnative_framework.dart';
import 'kaisel_scope.dart';

/// Page builder signature converting a [KaiselRoute] to a DartNative page [Widget].
typedef KaiselPageBuilder<R extends KaiselRoute> = Widget Function(
  BuildContext context,
  R route,
);

/// A DartNative widget that binds a [KaiselRouter] and renders the current page,
/// synchronizing stack mutations with DartNative's native navigation stack.
class KaiselRouterView<R extends KaiselRoute> extends StatefulWidget {
  const KaiselRouterView({
    super.key,
    required this.router,
    required this.pageBuilder,
  });

  /// The active [KaiselRouter] instance managing the navigation stack.
  final KaiselRouter<R> router;

  /// Builder that converts each route into its corresponding page [Widget].
  final KaiselPageBuilder<R> pageBuilder;

  @override
  State<KaiselRouterView<R>> createState() => _KaiselRouterViewState<R>();
}

class _KaiselRouterViewState<R extends KaiselRoute>
    extends State<KaiselRouterView<R>> {
  @override
  void initState() {
    super.initState();
    widget.router.addListener(_onRouterChanged);
  }

  @override
  void didUpdateWidget(KaiselRouterView<R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.router != oldWidget.router) {
      oldWidget.router.removeListener(_onRouterChanged);
      widget.router.addListener(_onRouterChanged);
    }
  }

  @override
  void dispose() {
    widget.router.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = widget.router.current;
    final pageWidget = widget.pageBuilder(context, currentRoute);

    return KaiselScope(
      router: widget.router,
      child: KaiselPageScope<R>(
        route: currentRoute,
        child: pageWidget,
      ),
    );
  }
}
