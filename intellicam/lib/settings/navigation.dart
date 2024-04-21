import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/pages/home.dart';
import 'package:ai_shield_app/pages/auth/login.dart';
import 'package:ai_shield_app/pages/auth/registration.dart';
import 'package:ai_shield_app/pages/auth/forget_password.dart';
import 'package:ai_shield_app/pages/surveillance.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> parentNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homePageNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> authNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> surveillanceNavigatorKey = GlobalKey<NavigatorState>();

  static const String homePath = '/home';
  static const String authPath = '/auth';
  static const String loginPath = '$authPath/login';
  static const String registrationPath = '$authPath/registration';
  static const String forgetPasswordPath = '$authPath/forget-password';
  static const String surveillancePath = '/surveillance';

  static final NavigationHelper _instance = NavigationHelper._internal();

  static late final GoRouter router;
  
  static NavigationHelper get instance => _instance;
  
  factory NavigationHelper() {
    return _instance;
  }

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  NavigationHelper._internal() {
    // Router initialization happens here.
    final routes = [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            navigatorKey: homePageNavigatorKey,
            routes: [
              GoRoute(
                path: homePath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const HomePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: surveillanceNavigatorKey,
            routes: [
              GoRoute(
                path: surveillancePath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const SurveillancePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: authNavigatorKey,
            routes: [
              GoRoute(
                path: loginPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const LoginPage(),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: registrationPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const RegistrationPage(),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: forgetPasswordPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const ForgetPasswordPage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            //child: Menu(
            child: navigationShell,
            //),
            state: state,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: homePath,
      routes: routes,
    );
  }

  static Page getPage({
      required Widget child,
      required GoRouterState state,
    }) {
      return MaterialPage(
        key: state.pageKey,
        child: child,
      );
    }
}
