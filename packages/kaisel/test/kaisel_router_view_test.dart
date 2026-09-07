import 'package:kaisel/kaisel.dart';
import 'package:test/test.dart';

sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class HomeRoute extends AppRoute {
  const HomeRoute();
}

final class DetailRoute extends AppRoute {
  final String id;
  const DetailRoute(this.id);

  @override
  List<Object?> get props => [id];
}

void main() {
  group('KaiselRouterView', () {
    test('renders current route and updates when router pushes', () async {
      final router = KaiselRouter<AppRoute>(initial: const HomeRoute());
      late AppRoute renderedRoute;

      final routerView = KaiselRouterView<AppRoute>(
        router: router,
        pageBuilder: (context, route) {
          renderedRoute = route;
          return const _DummyWidget();
        },
      );

      final element = Element.inflate(routerView);
      expect(renderedRoute, isA<HomeRoute>());

      await router.push(const DetailRoute('42'));
      element.rebuild();
      expect(renderedRoute, isA<DetailRoute>());
      expect((renderedRoute as DetailRoute).id, equals('42'));
    });
  });
}

class _DummyWidget extends LeafWidget {
  const _DummyWidget();
}
