import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';

class CitaService {
  String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

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