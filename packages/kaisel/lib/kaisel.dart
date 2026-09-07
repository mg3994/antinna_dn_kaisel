/// Declarative router and navigation for DartNative.
///
/// Re-exports pure-Dart navigation core from [kaisel_core] along with
/// DartNative router widgets and scopes.
library;

export 'package:kaisel_core/kaisel_core.dart';

export 'src/dartnative_framework.dart'
    show
        BuildContext,
        Builder,
        Element,
        InheritedWidget,
        Key,
        LeafWidget,
        State,
        StatefulWidget,
        StatelessWidget,
        UniqueKey,
        ValueKey,
        Widget,
        WidgetBuilder;
export 'src/kaisel_adaptive.dart';
export 'src/kaisel_module.dart';
export 'src/kaisel_router_view.dart';
export 'src/kaisel_scope.dart';
export 'src/kaisel_shell.dart';
