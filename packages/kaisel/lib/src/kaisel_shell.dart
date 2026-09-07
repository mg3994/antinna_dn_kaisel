import 'dartnative_framework.dart';

/// Builder signature for rendering shell layouts (e.g., sidebars, navigation bars).
typedef ShellBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// Builder signature for branched shell tab layouts.
typedef BranchedShellBuilder = Widget Function(
  BuildContext context,
  KaiselBranchedShellController controller,
  Widget currentBranch,
);

/// A widget that wraps nested child routes within a shell layout (e.g. app bar, drawer, bottom nav).
class KaiselShell extends StatefulWidget {
  const KaiselShell({
    super.key,
    required this.builder,
    required this.child,
  });

  /// The shell layout builder.
  final ShellBuilder builder;

  /// The child content widget.
  final Widget child;

  @override
  State<KaiselShell> createState() => _KaiselShellState();
}

class _KaiselShellState extends State<KaiselShell> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}

/// Controller exposing branch navigation actions to a [KaiselBranchedShellBuilder].
class KaiselBranchedShellController {
  KaiselBranchedShellController({
    required this.activeBranch,
    required this.branchCount,
    required void Function(int index) onSwitchBranch,
  }) : _onSwitchBranch = onSwitchBranch;

  /// Currently active branch index.
  final int activeBranch;

  /// Total number of branches.
  final int branchCount;

  final void Function(int index) _onSwitchBranch;

  /// Switch the active branch to [index].
  void switchBranch(int index) {
    if (index >= 0 && index < branchCount) {
      _onSwitchBranch(index);
    }
  }
}

/// A stateful shell for multi-tab navigation where each tab branch maintains its own independent stack history.
class KaiselBranchedShell extends StatefulWidget {
  const KaiselBranchedShell({
    super.key,
    required this.activeBranch,
    required this.branches,
    required this.builder,
  });

  /// The index of the currently active branch.
  final int activeBranch;

  /// The list of branch content widgets.
  final List<Widget> branches;

  /// The layout builder hosting the active branch and tab bar.
  final BranchedShellBuilder builder;

  @override
  State<KaiselBranchedShell> createState() => _KaiselBranchedShellState();
}

class _KaiselBranchedShellState extends State<KaiselBranchedShell> {
  late int _currentBranch;

  @override
  void initState() {
    super.initState();
    _currentBranch = widget.activeBranch;
  }

  @override
  void didUpdateWidget(KaiselBranchedShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeBranch != oldWidget.activeBranch) {
      _currentBranch = widget.activeBranch;
    }
  }

  void _switchBranch(int index) {
    if (_currentBranch != index) {
      setState(() {
        _currentBranch = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = KaiselBranchedShellController(
      activeBranch: _currentBranch,
      branchCount: widget.branches.length,
      onSwitchBranch: _switchBranch,
    );

    final currentWidget = (_currentBranch >= 0 && _currentBranch < widget.branches.length)
        ? widget.branches[_currentBranch]
        : const Builder(builder: _emptyWidget);

    return widget.builder(context, controller, currentWidget);
  }

  static Widget _emptyWidget(BuildContext context) => const _SizedBox();
}

class _SizedBox extends StatelessWidget {
  const _SizedBox();
  @override
  Widget build(BuildContext context) => this;
}
