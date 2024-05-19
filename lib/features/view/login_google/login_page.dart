import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/login_controller.dart';

class LoginGooglePage extends StatelessWidget {
  const LoginGooglePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YouTube App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent, // Color personalizado para la AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.deepOrange.shade300], // Fondo degradado
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Bienvenido a YouTube App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.login), // Icono de Google
                label: const Text('Iniciar sesión con YouTube'),
                onPressed: () async {
                  await authController.signInWithYouTube();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white, // Color del texto e icono del botón
                  textStyle: const TextStyle(fontSize: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bordes redondeados del botón
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => authController.isSignedIn.isTrue
                    ? const Text(
                        'Estás conectado',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : const Text(
                        'Inicia sesión para continuar',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
