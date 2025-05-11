import 'package:get/get.dart';
import 'package:trend_press/app/views/bookmark/bookmarked_news_screen.dart';
import 'package:trend_press/app/views/home/NewsDetailScreen.dart';
import '../views/splash/splash_screen.dart';
import '../views/home/HomeScreen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.bookmark,
      page: () => const BookmarkedNewsScreen(),
    ),
    
  ];
}
