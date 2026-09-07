import 'package:kaisel_core/kaisel_core.dart';
import 'dartnative_framework.dart';
import 'kaisel_scope.dart';

/// Builder signature for rendering a mounted module.
typedef ModuleBuilder = Widget Function(
  BuildContext context,
  KaiselRouter moduleRouter,
);

/// A widget that mounts a modular sub-router into the widget tree.
class KaiselModule extends StatefulWidget {
  const KaiselModule({
    super.key,
    required this.router,
    required this.builder,
  });

  /// The sub-router managed by this module.
  final KaiselRouter router;

  /// The builder constructing the module UI.
  final ModuleBuilder builder;

  @override
  State<KaiselModule> createState() => _KaiselModuleState();
}

class _KaiselModuleState extends State<KaiselModule> {
  @override
  Widget build(BuildContext context) {
    return KaiselScope(
      router: widget.router,
      child: Builder(
        builder: (innerContext) => widget.builder(innerContext, widget.router),
      ),
    );
  }
}
