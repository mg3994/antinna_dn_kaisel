import 'package:kaisel/kaisel.dart';
import 'package:test/test.dart';

sealed class TestRoute extends KaiselRoute {
  const TestRoute();
}

final class HomeRoute extends TestRoute {
  const HomeRoute();
}

final class ProfileRoute extends TestRoute {
  const ProfileRoute(this.username);
  final String username;

  @override
  List<Object?> get props => [username];
}

void main() {
  group('KaiselScope & KaiselPageScope', () {
    test('KaiselScope provides KaiselRouter down the widget tree', () {
      final router = KaiselRouter<TestRoute>(initial: const HomeRoute());
      late KaiselRouter retrievedRouter;

      final widget = KaiselScope(
        router: router,
        child: Builder(
          builder: (context) {
            retrievedRouter = context.kaisel;
            return const _DummyWidget();
          },
        ),
      );

      Element.inflate(widget);
      expect(retrievedRouter, same(router));
    });

    test('KaiselScope.maybeOf returns null when no KaiselScope is present', () {
      late KaiselRouter? retrievedRouter;

      final widget = Builder(
        builder: (context) {
          retrievedRouter = KaiselScope.maybeOf(context);
          return const _DummyWidget();
        },
      );

      Element.inflate(widget);
      expect(retrievedRouter, isNull);
    });

    test('KaiselPageScope provides current route to descendants', () {
      const route = ProfileRoute('alice');
      late ProfileRoute retrievedRoute;

      final widget = KaiselPageScope<ProfileRoute>(
        route: route,
        child: Builder(
          builder: (context) {
            retrievedRoute = context.route<ProfileRoute>();
            return const _DummyWidget();
          },
        ),
      );

      Element.inflate(widget);
      expect(retrievedRoute, equals(route));
      expect(retrievedRoute.username, equals('alice'));
    });
  });
}

class _DummyWidget extends LeafWidget {
  const _DummyWidget();
}
