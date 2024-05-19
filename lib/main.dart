import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/login_controller.dart';
import 'package:youtube_jamc/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.app.youtube_jamc/auth');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleAuthCode':
        String code = call.arguments;
        // Manejar el código de autorización
        _handleAuthCode(code);
        break;
      default:
        throw MissingPluginException('No se maneja el método: ${call.method}');
    }
  }

  void _handleAuthCode(String code) {
    AuthController controller = Get.find();
    controller.codeRecived(code);
    print("Código de autorización recibido: $code");
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Youtube video',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      getPages: getAppRoutes(),
    );
  }
}
