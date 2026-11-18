import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';

class CitaService {
  String get _baseUrl => ApiConfig.baseUrl;

  Future<List<Cita>> obtenerCitasPorUsuario(int idUsuario) async {
    final url = Uri.parse('$_baseUrl/api/citas/usuario/$idUsuario');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Cita.fromJson(json)).toList();
    } else {
      throw Exception('Error al consultar citas (${response.statusCode})');
    }
  }
}