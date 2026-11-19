import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

/// Cita vista desde el medico.
class CitaPaciente {
  final int id;
  final String especialidad;
  final String fechaHora;
  final DateTime? fechaInicio;
  final String estado;

  CitaPaciente({
    required this.id,
    required this.especialidad,
    required this.fechaHora,
    required this.fechaInicio,
    required this.estado,
  });

  factory CitaPaciente.fromJson(Map<String, dynamic> json) => CitaPaciente(
        id: (json['id'] as num).toInt(),
        especialidad: json['especialidad'] ?? '',
        fechaHora: json['fechaHora'] ?? '',
        fechaInicio: json['fechaInicio'] != null ? DateTime.tryParse(json['fechaInicio']) : null,
        estado: json['estado'] ?? '',
      );
}

/// Paciente asignado al medico con sus citas en orden ascendente.
class PacienteAsignado {
  final int id;
  final String nombre;
  final String documento;
  final String correo;
  final String? proximaCita;
  final List<CitaPaciente> citas;

  PacienteAsignado({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.correo,
    required this.proximaCita,
    required this.citas,
  });

  factory PacienteAsignado.fromJson(Map<String, dynamic> json) => PacienteAsignado(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] ?? '',
        documento: json['documento'] ?? '',
        correo: json['correo'] ?? '',
        proximaCita: json['proximaCita'],
        citas: (json['citas'] as List? ?? []).map((c) => CitaPaciente.fromJson(c)).toList(),
      );
}

/// Datos del profesional y sus pacientes.
class AgendaMedico {
  final String nombre;
  final String especialidad;
  final String consultorio;
  final String horario;
  final List<PacienteAsignado> pacientes;

  AgendaMedico({
    required this.nombre,
    required this.especialidad,
    required this.consultorio,
    required this.horario,
    required this.pacientes,
  });

  factory AgendaMedico.fromJson(Map<String, dynamic> json) => AgendaMedico(
        nombre: json['nombre'] ?? '',
        especialidad: json['especialidad'] ?? '',
        consultorio: json['consultorio'] ?? '',
        horario: json['horario'] ?? '',
        pacientes: (json['pacientes'] as List? ?? []).map((p) => PacienteAsignado.fromJson(p)).toList(),
      );
}

class MedicoService {
  Future<AgendaMedico> pacientesAsignados(int idUsuarioMedico) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/medicos/$idUsuarioMedico/pacientes'), headers: headersJson)
        .timeout(timeoutApi);
    if (response.statusCode != 200) {
      throw ApiException.desdeRespuesta(response, 'No fue posible cargar tus pacientes');
    }
    return AgendaMedico.fromJson(decodificar(response));
  }
}
