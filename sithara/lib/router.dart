import 'package:go_router/go_router.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/invite_screen.dart';
import 'features/catalog/screens/home_screen.dart';
import 'features/catalog/screens/category_screen.dart';
import 'features/catalog/screens/collection_screen.dart';
import 'features/catalog/screens/product_detail_screen.dart';
import 'features/upload/screens/pick_screen.dart';
import 'features/upload/screens/bg_removal_screen.dart';
import 'features/upload/screens/tag_review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/invite/:token', builder: (ctx, state) => InviteScreen(token: state.pathParameters['token']!)),
    GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
    GoRoute(path: '/category/:id', builder: (ctx, state) => CategoryScreen(categoryId: state.pathParameters['id']!)),
    GoRoute(path: '/collection/:id', builder: (ctx, state) => CollectionScreen(collectionId: state.pathParameters['id']!)),
    GoRoute(path: '/product/:id', builder: (ctx, state) => ProductDetailScreen(productId: state.pathParameters['id']!)),
    GoRoute(path: '/upload/pick', builder: (ctx, state) => const PickScreen()),
    GoRoute(path: '/upload/bg-removal', builder: (ctx, state) => const BgRemovalScreen()),
    GoRoute(path: '/upload/tags', builder: (ctx, state) => const TagReviewScreen()),
  ],
);
