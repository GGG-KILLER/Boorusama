// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routeObserver = RouteObserver();

final routerProvider = Provider<GoRouter>((ref) {
  final analytics = ref.watch(analyticsProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      analytics.getAnalyticsObserver(),
      routeObserver,
    ],
    routes: [
      Routes.home(ref),
      ...danbooruRoutes,
    ],
  );
});
