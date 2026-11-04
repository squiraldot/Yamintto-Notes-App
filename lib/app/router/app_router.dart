import 'package:go_router/go_router.dart';
import 'package:yamintto/features/foundation/presentation/foundation_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'foundation',
      builder: (context, state) => const FoundationScreen(),
    ),
  ],
);
