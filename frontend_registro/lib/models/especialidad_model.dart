/// HU006 - Especialidad medica activa.
class Especialidad {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantidadProfesionales;

  Especialidad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidadProfesionales,
  });

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      cantidadProfesionales: (json['cantidadProfesionales'] as num?)?.toInt() ?? 0,
    );
  }
}

/// HU006 - Profesional de la salud con su informacion basica y disponibilidad.
class Profesional {
  final int id;
  final String nombre;
  final String registroMedico;
  final String correo;
  final String consultorio;
  final int especialidadId;
  final String especialidad;
  final String diasAtencion;
  final String horario;
  final DateTime? proximaDisponibilidad;
  final int horariosLibres;

  Profesional({
    required this.id,
    required this.nombre,
    required this.registroMedico,
    required this.correo,
    required this.consultorio,
    required this.especialidadId,
    required this.especialidad,
    required this.diasAtencion,
    required this.horario,
    required this.proximaDisponibilidad,
    required this.horariosLibres,
  });

  bool get tieneDisponibilidad => proximaDisponibilidad != null;

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] ?? '',
      registroMedico: json['registroMedico'] ?? '',
      correo: json['correo'] ?? '',
      consultorio: json['consultorio'] ?? '',
      especialidadId: (json['especialidadId'] as num?)?.toInt() ?? 0,
      especialidad: json['especialidad'] ?? '',
      diasAtencion: json['diasAtencion'] ?? '',
      horario: json['horario'] ?? '',
      proximaDisponibilidad:
          json['proximaDisponibilidad'] != null ? DateTime.tryParse(json['proximaDisponibilidad']) : null,
      horariosLibres: (json['horariosLibres'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Un dia con sus horas libres (formato HH:mm).
class DiaDisponible {
  final DateTime fecha;
  final String diaSemana;
  final List<String> horas;

  DiaDisponible({required this.fecha, required this.diaSemana, required this.horas});

  /// Fecha en formato yyyy-MM-dd para enviarla al backend.
  String get fechaIso =>
      '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  factory DiaDisponible.fromJson(Map<String, dynamic> json) {
    return DiaDisponible(
      fecha: DateTime.parse(json['fecha']),
      diaSemana: json['diaSemana'] ?? '',
      horas: List<String>.from(json['horas'] ?? const []),
    );
  }
}
