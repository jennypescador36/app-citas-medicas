import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/especialidad_model.dart';
import 'api_exception.dart';

/// HU006 - Especialidades, profesionales y disponibilidad.
class EspecialidadService {
  Future<List<Especialidad>> listarEspecialidades() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/especialidades'), headers: headersJson)
        .timeout(timeoutApi);
    if (response.statusCode != 200) {
      throw ApiException.desdeRespuesta(response, 'No fue posible cargar las especialidades');
    }
    return (decodificar(response) as List).map((e) => Especialidad.fromJson(e)).toList();
  }

  Future<List<Profesional>> listarProfesionales(int especialidadId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/especialidades/$especialidadId/profesionales'), headers: headersJson)
        .timeout(timeoutApi);
    if (response.statusCode != 200) {
      throw ApiException.desdeRespuesta(response, 'No fue posible cargar los profesionales');
    }
    return (decodificar(response) as List).map((e) => Profesional.fromJson(e)).toList();
  }

  Future<List<DiaDisponible>> disponibilidad(int profesionalId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/profesionales/$profesionalId/disponibilidad'), headers: headersJson)
        .timeout(timeoutApi);
    if (response.statusCode != 200) {
      throw ApiException.desdeRespuesta(response, 'No fue posible consultar la disponibilidad');
    }
    return (decodificar(response) as List).map((e) => DiaDisponible.fromJson(e)).toList();
  }
}
