import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario_model.dart';
import 'api_exception.dart';

/// HU002 - Inicio de sesion contra /api/usuarios/login.
class AuthService {
  Future<Usuario> login(String correo, String contrasena) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/usuarios/login'),
          headers: headersJson,
          body: jsonEncode({'correo': correo.trim(), 'contrasena': contrasena}),
        )
        .timeout(timeoutApi);

    if (response.statusCode == 200) {
      return Usuario.fromJson(decodificar(response));
    }
    throw ApiException.desdeRespuesta(response, 'No fue posible iniciar sesión (${response.statusCode})');
  }
}
