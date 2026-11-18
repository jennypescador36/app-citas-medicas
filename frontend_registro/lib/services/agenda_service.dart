import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/cita_model.dart';
import 'api_exception.dart';

/// HU008 - Agendamiento de citas.
class AgendaService {
  /// [fecha] en formato yyyy-MM-dd y [hora] en formato HH:mm.
  Future<Cita> agendar({
    required int idUsuario,
    required int idProfesional,
    required String fecha,
    required String hora,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/citas/agendar'),
          headers: headersJson,
          body: jsonEncode({
            'idUsuario': idUsuario,
            'idProfesional': idProfesional,
            'fecha': fecha,
            'hora': hora,
          }),
        )
        .timeout(timeoutApi);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Cita.fromJson(decodificar(response));
    }
    throw ApiException.desdeRespuesta(response, 'No fue posible agendar la cita');
  }
}
