import 'package:kaisel/kaisel.dart';
import 'package:test/test.dart';

void main() {
  group('KaiselShell & KaiselBranchedShell', () {
    test('KaiselShell executes builder with child', () {
      late Widget capturedChild;

      final widget = KaiselShell(
        builder: (context, child) {
          capturedChild = child;
          return child;
        },
        child: const _TextWidget('ShellContent'),
      );

      Element.inflate(widget);
      expect(capturedChild, isA<_TextWidget>());
      expect((capturedChild as _TextWidget).text, equals('ShellContent'));
    });

    test('KaiselBranchedShell renders active branch and supports branch switching', () {
      late KaiselBranchedShellController capturedController;
      late Widget capturedBranch;

      final widget = KaiselBranchedShell(
        activeBranch: 0,
        branches: const [
          _TextWidget('Tab0'),
          _TextWidget('Tab1'),
          _TextWidget('Tab2'),
        ],
        builder: (context, controller, currentBranch) {
          capturedController = controller;
          capturedBranch = currentBranch;
          return currentBranch;
        },
      );

      final element = Element.inflate(widget);
      expect(capturedController.activeBranch, equals(0));
      expect(capturedController.branchCount, equals(3));
      expect((capturedBranch as _TextWidget).text, equals('Tab0'));

      capturedController.switchBranch(1);
      element.rebuild();

      expect(capturedController.activeBranch, equals(1));
      expect((capturedBranch as _TextWidget).text, equals('Tab1'));
    });
  });
}

class _TextWidget extends LeafWidget {
  const _TextWidget(this.text);
  final String text;
}
