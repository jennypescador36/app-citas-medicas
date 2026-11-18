/// Usuario autenticado (HU002). La contrasena nunca llega desde el backend.
class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String documento;
  final String tipoUsuario;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.documento,
    required this.tipoUsuario,
  });

  bool get esPaciente => tipoUsuario.toUpperCase() == 'PACIENTE';
  bool get esSalud => tipoUsuario.toUpperCase() == 'SALUD';
  bool get esAdmin => tipoUsuario.toUpperCase() == 'ADMIN';

  String get rolLegible {
    if (esSalud) return 'Profesional de la salud';
    if (esAdmin) return 'Administrador';
    return 'Paciente';
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      documento: json['documento'] ?? '',
      tipoUsuario: json['tipoUsuario'] ?? 'PACIENTE',
    );
  }
}
