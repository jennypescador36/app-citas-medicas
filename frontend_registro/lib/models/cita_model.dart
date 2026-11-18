class Cita {
  final int id;
  final String especialidad;
  final String medico;
  final String fechaHora;
  final String estado;
  final int? idProfesional;
  final String? consultorio;

  Cita({
    required this.id,
    required this.especialidad,
    required this.medico,
    required this.fechaHora,
    required this.estado,
    this.idProfesional,
    this.consultorio,
  });

  bool get esProgramada => estado.toUpperCase() == 'PROGRAMADA';

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] ?? 0,
      especialidad: json['especialidad'] ?? 'Medicina General',
      medico: json['medico'] ?? 'Especialista Asignado',
      fechaHora: json['fechaHora'] ?? '01/01/2026 - 08:00 AM',
      estado: json['estado'] ?? 'PROGRAMADA',
      idProfesional: (json['idProfesional'] as num?)?.toInt(),
      consultorio: json['consultorio'],
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
