import 'package:flutter/material.dart';

import '../models/usuario_model.dart';
import '../services/medico_service.dart';
import '../widgets/pantalla_base.dart';

/// Vista del medico: pacientes asignados y sus citas en orden ascendente.
class MisPacientesScreen extends StatefulWidget {
  final Usuario usuario;

  const MisPacientesScreen({super.key, required this.usuario});

  @override
  State<MisPacientesScreen> createState() => _MisPacientesScreenState();
}

class _MisPacientesScreenState extends State<MisPacientesScreen> {
  final _service = MedicoService();
  late Future<AgendaMedico> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() => setState(() => _future = _service.pacientesAsignados(widget.usuario.id));

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Mis pacientes',
      subtitulo: 'Dr(a). ${widget.usuario.nombre}',
      icono: Icons.groups_outlined,
      acciones: [
        IconButton(onPressed: _cargar, tooltip: 'Actualizar', icon: const Icon(Icons.refresh_rounded, color: kAzul)),
      ],
      child: FutureBuilder<AgendaMedico>(
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
              mensaje: 'No fue posible cargar tus pacientes.\n${snapshot.error}',
              onReintentar: _cargar,
            );
          }
          final agenda = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                child: Text(
                  '${agenda.especialidad} · ${agenda.consultorio} · ${agenda.horario}\n'
                  '${agenda.pacientes.length} paciente(s) asignado(s)',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                ),
              ),
              const SizedBox(height: 14),
              if (agenda.pacientes.isEmpty)
                const EstadoVacio(
                  icono: Icons.person_search_outlined,
                  mensaje: 'Aún no tienes pacientes asignados. Aparecerán cuando agenden citas contigo.',
                )
              else
                for (final p in agenda.pacientes) ...[
                  _TarjetaPaciente(paciente: p),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }
}

Color colorEstado(String estado) {
  switch (estado.toUpperCase()) {
    case 'PROGRAMADA':
      return const Color(0xFF0284C7);
    case 'ATENDIDA':
      return const Color(0xFF0D9488);
    case 'FINALIZADA':
      return const Color(0xFF16A34A);
    case 'CANCELADA':
      return const Color(0xFFE11D48);
    default:
      return Colors.grey;
  }
}

class _TarjetaPaciente extends StatelessWidget {
  final PacienteAsignado paciente;

  const _TarjetaPaciente({required this.paciente});

  @override
  Widget build(BuildContext context) {
    final p = paciente;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAzul.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: CircleAvatar(
            backgroundColor: kAzul,
            child: Text(p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : 'P',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextoOscuro)),
          subtitle: Text(
            p.proximaCita != null ? 'Próxima cita: ${p.proximaCita}' : 'Sin citas próximas · Doc. ${p.documento}',
            style: TextStyle(fontSize: 12, color: p.proximaCita != null ? kAzul : Colors.grey.shade600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Documento ${p.documento} · ${p.correo}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 8),
            for (final c in p.citas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(child: Text(c.fechaHora, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: colorEstado(c.estado), borderRadius: BorderRadius.circular(12)),
                      child: Text(c.estado.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
