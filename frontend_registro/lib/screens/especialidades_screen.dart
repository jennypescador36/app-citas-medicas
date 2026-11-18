import 'package:flutter/material.dart';

import '../models/especialidad_model.dart';
import '../models/usuario_model.dart';
import '../services/especialidad_service.dart';
import '../widgets/pantalla_base.dart';
import 'profesionales_screen.dart';

/// HU006 - Lista de especialidades medicas activas.
class EspecialidadesScreen extends StatefulWidget {
  final Usuario usuario;

  const EspecialidadesScreen({super.key, required this.usuario});

  @override
  State<EspecialidadesScreen> createState() => _EspecialidadesScreenState();
}

class _EspecialidadesScreenState extends State<EspecialidadesScreen> {
  final _service = EspecialidadService();
  late Future<List<Especialidad>> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() => _future = _service.listarEspecialidades());
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Especialidades médicas',
      subtitulo: 'Elige la atención que necesitas',
      icono: Icons.local_hospital_outlined,
      child: FutureBuilder<List<Especialidad>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: kAzul)),
            );
          }
          if (snapshot.hasError) {
            return EstadoVacio(
              icono: Icons.cloud_off_rounded,
              mensaje: 'No fue posible cargar las especialidades.\n${snapshot.error}',
              onReintentar: _cargar,
            );
          }
          final especialidades = snapshot.data ?? [];
          if (especialidades.isEmpty) {
            return const EstadoVacio(
              icono: Icons.medical_services_outlined,
              mensaje: 'No hay especialidades activas en este momento.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final e in especialidades) ...[
                _TarjetaEspecialidad(
                  especialidad: e,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfesionalesScreen(usuario: widget.usuario, especialidad: e),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaEspecialidad extends StatelessWidget {
  final Especialidad especialidad;
  final VoidCallback onTap;

  const _TarjetaEspecialidad({required this.especialidad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sinProfesionales = especialidad.cantidadProfesionales == 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kAzulClaro.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kAzul.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: kAzul,
              child: Icon(Icons.medical_services_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(especialidad.nombre,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: kTextoOscuro)),
                  const SizedBox(height: 2),
                  Text(especialidad.descripcion, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text(
                    sinProfesionales
                        ? 'Sin profesionales disponibles'
                        : '${especialidad.cantidadProfesionales} profesional(es)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sinProfesionales ? Colors.redAccent : const Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kAzul),
          ],
        ),
      ),
    );
  }
}
