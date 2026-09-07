import 'package:kaisel/kaisel.dart';
import 'package:test/test.dart';

sealed class ModRoute extends KaiselRoute {
  const ModRoute();
}

final class ModHome extends ModRoute {
  const ModHome();
}

void main() {
  group('KaiselModule & KaiselAdaptive', () {
    test('KaiselModule binds sub-router and calls builder', () {
      final subRouter = KaiselRouter<ModRoute>(initial: const ModHome());
      late KaiselRouter retrievedSubRouter;

      final moduleWidget = KaiselModule(
        router: subRouter,
        builder: (context, router) {
          retrievedSubRouter = context.kaisel;
          return const _DummyWidget();
        },
      );

      Element.inflate(moduleWidget);
      expect(retrievedSubRouter, same(subRouter));
    });

    test('KaiselAdaptive renders stack mode when compact', () {
      late AdaptiveLayoutMode capturedMode;

      final adaptiveWidget = KaiselAdaptive(
        isCompact: true,
        master: const _DummyWidget(),
        detail: const _DummyWidget(),
        builder: (context, mode, master, detail) {
          capturedMode = mode;
          return master;
        },
      );

      Element.inflate(adaptiveWidget);
      expect(capturedMode, equals(AdaptiveLayoutMode.stack));
    });

    test('KaiselAdaptive renders split mode when not compact with detail', () {
      late AdaptiveLayoutMode capturedMode;

      final adaptiveWidget = KaiselAdaptive(
        isCompact: false,
        master: const _DummyWidget(),
        detail: const _DummyWidget(),
        builder: (context, mode, master, detail) {
          capturedMode = mode;
          return master;
        },
      );

      Element.inflate(adaptiveWidget);
      expect(capturedMode, equals(AdaptiveLayoutMode.split));
    });
  });
}

class _DummyWidget extends LeafWidget {
  const _DummyWidget();
}
