class Cita {
  final int id;
  final String especialidad;
  final String medico;
  final String fechaHora;
  final String estado;

  Cita({
    required this.id,
    required this.especialidad,
    required this.medico,
    required this.fechaHora,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] ?? 0,
      especialidad: json['especialidad'] ?? 'Medicina General',
      medico: json['medico'] ?? 'Especialista Asignado',
      fechaHora: json['fechaHora'] ?? '01/01/2026 - 08:00 AM',
      estado: json['estado'] ?? 'PROGRAMADA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'especialidad': especialidad,
      'medico': medico,
      'fechaHora': fechaHora,
      'estado': estado,
    };
  }
}
