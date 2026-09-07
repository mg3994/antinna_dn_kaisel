/// Pure-Dart widget abstractions matching DartNative's element/widget architecture.
library;

typedef VoidCallback = void Function();
typedef WidgetBuilder = Widget Function(BuildContext context);

abstract class Key {
  const factory Key(String value) = ValueKey<String>;
  const Key._();
}

class ValueKey<T> extends Key {
  final T value;
  const ValueKey(this.value) : super._();

  @override
  bool operator ==(Object other) => other is ValueKey<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class UniqueKey extends Key {
  UniqueKey() : super._();
}

abstract class Widget {
  const Widget({this.key});
  final Key? key;
}

/// A leaf widget that terminates the widget tree traversal.
class LeafWidget extends Widget {
  const LeafWidget({super.key});
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});
  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});
  State<StatefulWidget> createState();
}

abstract class State<T extends StatefulWidget> {
  late T _widget;
  late BuildContext _context;
  bool _mounted = false;

  T get widget => _widget;
  BuildContext get context => _context;
  bool get mounted => _mounted;

  void initState() {}
  void didUpdateWidget(covariant T oldWidget) {}
  void didChangeDependencies() {}

  void setState(VoidCallback fn) {
    fn();
    _element?.rebuild();
  }

  void dispose() {
    _mounted = false;
  }

  Widget build(BuildContext context);

  _StatefulElement? _element;
}

abstract class BuildContext {
  Widget get widget;
  bool get mounted;
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();
}

abstract class InheritedWidget extends Widget {
  const InheritedWidget({super.key, required this.child});
  final Widget child;

  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

class Builder extends StatelessWidget {
  final WidgetBuilder builder;
  const Builder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context);
}

/// Lightweight pure-Dart element tree runner for executing DartNative widget trees in tests and runtime.
abstract class Element implements BuildContext {
  Element(this._widget);

  Widget _widget;

  @override
  Widget get widget => _widget;

  Element? parent;
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  final Map<Type, InheritedElement> _inheritedWidgets = {};

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    final ancestor = _inheritedWidgets[T];
    if (ancestor != null) {
      ancestor.addDependent(this);
      return ancestor.widget as T;
    }
    return null;
  }

  void mount(Element? parentElement) {
    parent = parentElement;
    if (parentElement != null) {
      _inheritedWidgets.addAll(parentElement._inheritedWidgets);
    }
    _mounted = true;
  }

  void rebuild();

  void unmount() {
    _mounted = false;
  }

  static Element inflate(Widget widget, [Element? parent]) {
    final Element element;
    if (widget is StatelessWidget) {
      element = _StatelessElement(widget);
    } else if (widget is StatefulWidget) {
      element = _StatefulElement(widget);
    } else if (widget is InheritedWidget) {
      element = InheritedElement(widget);
    } else if (widget is LeafWidget) {
      element = _LeafElement(widget);
    } else {
      throw UnsupportedError('Unsupported widget type: ${widget.runtimeType}');
    }
    element.mount(parent);
    element.rebuild();
    return element;
  }
}

class _LeafElement extends Element {
  _LeafElement(super.widget);

  @override
  void rebuild() {}
}

class _StatelessElement extends Element {
  _StatelessElement(StatelessWidget super.widget);

  Element? child;

  @override
  void rebuild() {
    final built = (widget as StatelessWidget).build(this);
    if (child == null) {
      child = Element.inflate(built, this);
    } else if (child!.widget.runtimeType == built.runtimeType &&
        child!.widget.key == built.key) {
      child!._widget = built;
      child!.rebuild();
    } else {
      child!.unmount();
      child = Element.inflate(built, this);
    }
  }

  @override
  void unmount() {
    child?.unmount();
    super.unmount();
  }
}

class _StatefulElement extends Element {
  _StatefulElement(StatefulWidget widget)
      : state = widget.createState(),
        super(widget) {
    state._widget = widget;
    state._context = this;
    state._element = this;
  }

  final State<StatefulWidget> state;
  Element? child;

  @override
  void mount(Element? parentElement) {
    super.mount(parentElement);
    state._mounted = true;
    state.initState();
    state.didChangeDependencies();
  }

  @override
  void rebuild() {
    final oldWidget = widget as StatefulWidget;
    final built = state.build(this);
    if (child == null) {
      child = Element.inflate(built, this);
    } else if (child!.widget.runtimeType == built.runtimeType &&
        child!.widget.key == built.key) {
      child!._widget = built;
      state.didUpdateWidget(oldWidget);
      child!.rebuild();
    } else {
      child!.unmount();
      child = Element.inflate(built, this);
    }
  }

  @override
  void unmount() {
    child?.unmount();
    state.dispose();
    super.unmount();
  }
}

class InheritedElement extends Element {
  InheritedElement(InheritedWidget super.widget) {
    _inheritedWidgets[widget.runtimeType] = this;
  }

  final Set<Element> _dependents = {};
  Element? child;

  void addDependent(Element dependent) {
    _dependents.add(dependent);
  }

  @override
  void rebuild() {
    final inheritedWidget = widget as InheritedWidget;
    final built = inheritedWidget.child;

    if (child == null) {
      child = Element.inflate(built, this);
    } else if (child!.widget.runtimeType == built.runtimeType &&
        child!.widget.key == built.key) {
      child!._widget = built;
      if (inheritedWidget.updateShouldNotify(inheritedWidget)) {
        for (final dependent in _dependents) {
          dependent.rebuild();
        }
      }
      child!.rebuild();
    } else {
      child!.unmount();
      child = Element.inflate(built, this);
    }
  }

  @override
  void unmount() {
    child?.unmount();
    _dependents.clear();
    super.unmount();
  }
}
