import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error devuelto por el backend con un mensaje listo para mostrar al usuario.
class ApiException implements Exception {
  final int statusCode;
  final String mensaje;

  ApiException(this.statusCode, this.mensaje);

  factory ApiException.desdeRespuesta(http.Response response, String porDefecto) {
    String mensaje = porDefecto;
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map && data['mensaje'] != null) {
        mensaje = data['mensaje'].toString();
      }
    } catch (_) {
      if (response.body.isNotEmpty && response.body.length < 200) {
        mensaje = response.body;
      }
    }
    return ApiException(response.statusCode, mensaje);
  }

  @override
  String toString() => mensaje;
}

/// Decodifica el cuerpo de la respuesta respetando tildes y eñes.
dynamic decodificar(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

const Map<String, String> headersJson = {'Content-Type': 'application/json'};

/// Tiempo maximo de espera: Render (plan gratuito) puede tardar ~50 s en despertar.
const Duration timeoutApi = Duration(seconds: 70);
