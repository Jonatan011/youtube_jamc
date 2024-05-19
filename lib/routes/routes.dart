import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:youtube_jamc/features/view/home/page/home_page.dart';
import 'package:youtube_jamc/features/view/login_google/login_page.dart';
import 'package:youtube_jamc/features/view/splash/splash_screen.dart';

List<GetPage> getAppRoutes() {
  return [
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: '/loginpage', page: () => const LoginGooglePage()),
    GetPage(name: '/home', page: () => const HomePage()),
  ];
}
