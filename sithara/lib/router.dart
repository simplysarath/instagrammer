import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/invite_screen.dart';
import 'features/catalog/screens/home_screen.dart';
import 'features/catalog/screens/category_screen.dart';
import 'features/catalog/screens/collection_screen.dart';
import 'features/catalog/screens/product_detail_screen.dart';
import 'features/upload/screens/pick_screen.dart';
import 'features/upload/screens/bg_removal_screen.dart';
import 'features/upload/screens/tag_review_screen.dart';

GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isInvite = state.matchedLocation.startsWith('/invite');

      if (!isLoggedIn && !isLoggingIn && !isInvite) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';
      return null;
    },
    refreshListenable: _AuthListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(
        path: '/invite/:token',
        builder: (ctx, state) =>
            InviteScreen(token: state.pathParameters['token']!),
      ),
      GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
      GoRoute(
        path: '/category/:id',
        builder: (ctx, state) =>
            CategoryScreen(categoryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/collection/:id',
        builder: (ctx, state) =>
            CollectionScreen(collectionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (ctx, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/upload/pick',
          builder: (ctx, state) => const PickScreen()),
      GoRoute(
          path: '/upload/bg-removal',
          builder: (ctx, state) => const BgRemovalScreen()),
      GoRoute(
          path: '/upload/tags',
          builder: (ctx, state) => const TagReviewScreen()),
    ],
  );
}

// Listenable that notifies go_router when auth state changes
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
