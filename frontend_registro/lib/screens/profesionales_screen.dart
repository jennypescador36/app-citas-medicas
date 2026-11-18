import 'package:flutter/material.dart';

import '../models/especialidad_model.dart';
import '../models/usuario_model.dart';
import '../services/especialidad_service.dart';
import '../utils/formato_fecha.dart';
import '../widgets/pantalla_base.dart';
import '../widgets/selector_horario.dart';

/// HU006 - Profesionales de una especialidad con su informacion y disponibilidad.
class ProfesionalesScreen extends StatefulWidget {
  final Usuario usuario;
  final Especialidad especialidad;

  const ProfesionalesScreen({super.key, required this.usuario, required this.especialidad});

  @override
  State<ProfesionalesScreen> createState() => _ProfesionalesScreenState();
}

class _ProfesionalesScreenState extends State<ProfesionalesScreen> {
  final _service = EspecialidadService();
  late Future<List<Profesional>> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() => _future = _service.listarProfesionales(widget.especialidad.id));
  }

  void _verDisponibilidad(Profesional p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Disponibilidad de Dr(a). ${p.nombre}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextoOscuro)),
            Text('${p.especialidad} · ${p.consultorio}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            SelectorHorario(profesionalId: p.id),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: widget.especialidad.nombre,
      subtitulo: 'Profesionales de la especialidad',
      icono: Icons.groups_2_outlined,
      child: FutureBuilder<List<Profesional>>(
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
              mensaje: 'No fue posible cargar los profesionales.\n${snapshot.error}',
              onReintentar: _cargar,
            );
          }
          final profesionales = snapshot.data ?? [];
          if (profesionales.isEmpty) {
            return const EstadoVacio(
              icono: Icons.person_off_outlined,
              mensaje: 'Por ahora no hay profesionales disponibles en esta especialidad.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final p in profesionales) ...[
                _TarjetaProfesional(
                  profesional: p,
                  onVerDisponibilidad: () => _verDisponibilidad(p),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaProfesional extends StatelessWidget {
  final Profesional profesional;
  final VoidCallback onVerDisponibilidad;

  const _TarjetaProfesional({required this.profesional, required this.onVerDisponibilidad});

  @override
  Widget build(BuildContext context) {
    final p = profesional;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAzul.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: kAzul,
                child: Text(p.nombre.isNotEmpty ? p.nombre[0] : 'D',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr(a). ${p.nombre}',
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: kTextoOscuro)),
                    Text('${p.especialidad} · ${p.registroMedico}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _dato(Icons.meeting_room_outlined, p.consultorio),
          _dato(Icons.calendar_today_outlined, 'Atiende: ${p.diasAtencion}'),
          _dato(Icons.schedule_rounded, 'Horario: ${p.horario}'),
          _dato(Icons.email_outlined, p.correo),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (p.tieneDisponibilidad ? const Color(0xFF16A34A) : Colors.redAccent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.tieneDisponibilidad
                  ? 'Próximo horario libre: ${fechaHoraCorta(p.proximaDisponibilidad!)}'
                  : 'Sin disponibilidad en los próximos días',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.tieneDisponibilidad ? const Color(0xFF15803D) : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: p.tieneDisponibilidad ? onVerDisponibilidad : null,
                icon: const Icon(Icons.event_available_outlined, size: 18),
                label: const Text('Ver disponibilidad'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icono, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
        ],
      ),
    );
  }
}
