import 'dart:convert';
import 'package:flutter/services.dart';

class GoogleCredentials {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String authUri;
  final String tokenUri;

  GoogleCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.authUri,
    required this.tokenUri,
  });

  factory GoogleCredentials.fromJson(Map<String, dynamic> json) {
    final installed = json['installed'];
    return GoogleCredentials(
      clientId: installed['client_id'],
      clientSecret: installed['client_secret'],
      redirectUri: installed['redirect_uris'][0],
      authUri: installed['auth_uri'],
      tokenUri: installed['token_uri'],
    );
  }

  static Future<GoogleCredentials> load() async {
    final data = await rootBundle.loadString('assets/credentials.json');
    final jsonResult = jsonDecode(data);
    return GoogleCredentials.fromJson(jsonResult);
  }
}
