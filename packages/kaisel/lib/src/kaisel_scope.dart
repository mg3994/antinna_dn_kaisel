import 'package:kaisel_core/kaisel_core.dart';
import 'dartnative_framework.dart';

/// Binds a [KaiselRouter] to the widget tree and exposes it to descendants.
class KaiselScope extends InheritedWidget {
  const KaiselScope({
    super.key,
    required this.router,
    required super.child,
  });

  /// The active [KaiselRouter] provided to this subtree.
  final KaiselRouter router;

  /// Returns the nearest [KaiselRouter] ancestor in the widget tree.
  static KaiselRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KaiselScope>();
    if (scope == null) {
      throw StateError(
        'KaiselScope.of() called with a context that does not contain a KaiselScope.\n'
        'Ensure that a KaiselScope (or KaiselShell/KaiselRouter) ancestor is present in the widget tree.',
      );
    }
    return scope.router;
  }

  /// Returns the nearest [KaiselRouter] ancestor, or null if none is found.
  static KaiselRouter? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KaiselScope>()?.router;
  }

  @override
  bool updateShouldNotify(KaiselScope oldWidget) => router != oldWidget.router;
}

/// Exposes the current [KaiselRoute] instance for the page being built.
class KaiselPageScope<T extends KaiselRoute> extends InheritedWidget {
  const KaiselPageScope({
    super.key,
    required this.route,
    required super.child,
  });

  /// The active page route.
  final T route;

  /// Returns the nearest ancestor route of type [R].
  static R of<R extends KaiselRoute>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KaiselPageScope<R>>();
    if (scope == null) {
      throw StateError(
        'KaiselPageScope.of<$R>() called with a context that does not contain a matching route scope.',
      );
    }
    return scope.route;
  }

  /// Returns the nearest ancestor route of type [R], or null if none found.
  static R? maybeOf<R extends KaiselRoute>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KaiselPageScope<R>>()?.route;
  }

  @override
  bool updateShouldNotify(KaiselPageScope<T> oldWidget) => route != oldWidget.route;
}

/// Convenience extensions on [BuildContext] for navigation lookup.
extension KaiselBuildContextX on BuildContext {
  /// The active [KaiselRouter] for this context.
  KaiselRouter get kaisel => KaiselScope.of(this);

  /// The active [KaiselRoute] of type [T] for this context.
  T route<T extends KaiselRoute>() => KaiselPageScope.of<T>(this);
}
