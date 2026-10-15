import 'package:flutter/material.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/features/login/presentation/pages/login.dart';
import 'package:gear_up_bloc/features/login/presentation/pages/sign_up_page.dart';
import 'package:gear_up_bloc/features/splash/presentation/pages/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: RoutesName.defaultPath,
  routes: <RouteBase>[
    GoRoute(
      path: RoutesName.defaultPath,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: RoutesName.loginPath,
      builder: (BuildContext context, GoRouterState state) {
        return const Login();
      },
    ),
    GoRoute(
      path: RoutesName.signUp,
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpPage();
      },
    ),
    GoRoute(
      path: RoutesName.homePage,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(child: Text('GearUp Catalog Home Coming Next!')),
        );
      },
    ),
  ],
);