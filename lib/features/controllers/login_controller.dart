import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  String clientId = '';
  String clientSecret = '';
  String redirectUri = '';
  String authUri = '';
  String tokenUri = '';

  var isSignedIn = false.obs;

  static const platform = MethodChannel('com.app.youtube_jamc/auth');

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _loadConfig();
    await _checkAuthState();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _loadConfig() async {
    try {
      final jsonString = await rootBundle.loadString('config.json');
      final config = json.decode(jsonString);
      clientId = config['web']['client_id'];
      clientSecret = config['web']['client_secret'];
      redirectUri = config['web']['redirect_uris'][0]; // Ajusta esto según tu configuración
      authUri = config['web']['auth_uri'];
      tokenUri = config['web']['token_uri'];
      print('Configuration loaded successfully');
    } catch (e) {
      print("Error loading config: $e");
      Get.snackbar('Config Error', 'Failed to load configuration: $e');
    }
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken != null && accessToken.isNotEmpty) {
      isSignedIn.value = true;
      Get.offAllNamed("/home");
    } else {
      isSignedIn.value = false;
    }
  }

  Future<void> signInWithYouTube() async {
    try {
      final url = Uri.https('accounts.google.com', '/o/oauth2/auth', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'email https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtube',
        'access_type': 'offline',
        'state': 'some_random_state', // Agrega un estado para manejar la solicitud
        'include_granted_scopes': 'true',
      });

      print("Launching authentication URL: $url");

      await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: 'youtubejamc', // Esquema de URL personalizado de tu aplicación
        preferEphemeral: true, // Intenta usar una sesión efímera si es posible
      );
    } catch (error) {
      print("Authentication error: $error");
      Get.snackbar('Login Error', 'Failed to sign in with YouTube: $error');
    }
  }

  Future<void> codeRecived(String? code) async {
    try {
      if (code != null) {
        await _getToken(code);
        isSignedIn.value = true;
        Get.offAllNamed("/home");
      } else {
        print("Authorization code not found in the result.");
        Get.snackbar('Login Error', 'Authorization code not found.');
      }
    } catch (error) {
      print("Authentication error: $error");
      Get.snackbar('Login Error', 'Failed to sign in with YouTube: $error');
    }
  }

  Future<void> _getToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse(tokenUri),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': code,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        print("Access Token: $accessToken");
        print("Refresh Token: $refreshToken");
      } else {
        print("Failed to get token: ${response.body}");
        throw Exception('Failed to get token');
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar('Token Error', 'Failed to get token: $e');
    }
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleAuthCode':
        String code = call.arguments;
        codeRecived(code);
        await _getToken(code); // Manejar el código de autorización
        break;
      default:
        throw MissingPluginException('No se maneja el método: ${call.method}');
    }
  }

  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse(tokenUri),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': clientId,
            'client_secret': clientSecret,
            'refresh_token': refreshToken,
            'grant_type': 'refresh_token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'];

          await prefs.setString('accessToken', accessToken);
        } else {
          print("Failed to refresh token: ${response.body}");
          throw Exception('Failed to refresh token');
        }
      } catch (e) {
        print("Error: $e");
        Get.snackbar('Token Error', 'Failed to refresh token: $e');
      }
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    isSignedIn.value = false;
    Get.offAllNamed("/login");
  }
}
