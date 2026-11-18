import 'package:flutter/material.dart';

import '../models/usuario_model.dart';
import '../widgets/pantalla_base.dart';
import 'especialidades_screen.dart';
import 'login_screen.dart';
import 'mis_citas_screen.dart';

/// Opcion del menu principal, visible solo para los roles indicados (HU002).
class _OpcionMenu {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final Set<String> roles;
  final Widget Function(Usuario usuario) destino;

  const _OpcionMenu({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.roles,
    required this.destino,
  });
}

/// Menu principal despues del inicio de sesion. Cada rol ve solo sus funciones.
class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  static final List<_OpcionMenu> _opciones = [
    _OpcionMenu(
      titulo: 'Especialidades médicas',
      descripcion: 'Conoce las especialidades, profesionales y su disponibilidad',
      icono: Icons.local_hospital_outlined,
      color: kAzul,
      roles: {'PACIENTE', 'SALUD', 'ADMIN'},
      destino: (u) => EspecialidadesScreen(usuario: u),
    ),
    _OpcionMenu(
      titulo: 'Mis citas',
      descripcion: 'Consulta tus citas próximas y el histórico',
      icono: Icons.calendar_month_outlined,
      color: const Color(0xFF0D9488),
      roles: {'PACIENTE'},
      destino: (u) => MisCitasScreen(idUsuario: u.id, nombreUsuario: u.nombre),
    ),
  ];

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = usuario.tipoUsuario.toUpperCase();
    final opciones = _opciones.where((o) => o.roles.contains(rol)).toList();

    return PantallaBase(
      titulo: 'Hola, ${usuario.nombre}',
      subtitulo: usuario.rolLegible,
      icono: usuario.esSalud ? Icons.medical_services_outlined : Icons.person_outline,
      mostrarVolver: false,
      acciones: [
        TextButton.icon(
          onPressed: () => _cerrarSesion(context),
          icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
          label: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
      child: opciones.isEmpty
          ? const EstadoVacio(
              icono: Icons.lock_outline,
              mensaje: 'Tu rol aún no tiene funciones habilitadas en la aplicación.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final opcion in opciones) ...[
                  _TarjetaOpcion(
                    opcion: opcion,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => opcion.destino(usuario)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final _OpcionMenu opcion;
  final VoidCallback onTap;

  const _TarjetaOpcion({required this.opcion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: opcion.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: opcion.color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: opcion.color, borderRadius: BorderRadius.circular(16)),
              child: Icon(opcion.icono, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opcion.titulo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextoOscuro)),
                  const SizedBox(height: 2),
                  Text(opcion.descripcion, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: opcion.color),
          ],
        ),
      ),
    );
  }
}
