import 'package:flutter/material.dart';

import '../models/cita_model.dart';
import '../services/agenda_service.dart';
import '../services/api_exception.dart';
import '../utils/formato_fecha.dart';
import '../widgets/pantalla_base.dart';
import '../widgets/resumen_cita.dart';
import '../widgets/selector_horario.dart';

/// HU012 - Reprogramacion de una cita PROGRAMADA a un nuevo horario libre del mismo profesional.
/// Devuelve true al hacer pop si la cita se reprogramo.
class ReprogramarCitaScreen extends StatefulWidget {
  final int idUsuario;
  final Cita cita;

  const ReprogramarCitaScreen({super.key, required this.idUsuario, required this.cita});

  @override
  State<ReprogramarCitaScreen> createState() => _ReprogramarCitaScreenState();
}

class _ReprogramarCitaScreenState extends State<ReprogramarCitaScreen> {
  final _agendaService = AgendaService();
  final _selectorKey = GlobalKey<SelectorHorarioState>();
  String? _fecha;
  String? _hora;
  bool _guardando = false;

  Future<void> _confirmar() async {
    if (_fecha == null || _hora == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirmar reprogramación'),
        content: Text(
          'Horario actual: ${widget.cita.fechaHora}\n'
          'Nuevo horario: ${fechaCorta(DateTime.parse(_fecha!))} a las ${hora12(_hora!)}\n\n'
          'El horario actual quedará libre para otros pacientes.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reprogramar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _guardando = true);
    try {
      final (cita, anterior) = await _agendaService.reprogramar(
        idCita: widget.cita.id,
        idUsuario: widget.idUsuario,
        fecha: _fecha!,
        hora: _hora!,
      );
      if (!mounted) return;
      await mostrarResumenCita(context, titulo: '¡Cita reprogramada!', cita: cita, fechaAnterior: anterior);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, error: true);
      if (e.statusCode == 409) _selectorKey.currentState?.recargar();
    } catch (e) {
      if (mounted) mostrarMensaje(context, 'No hay conexión con el servidor. Intenta de nuevo.', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    return PantallaBase(
      titulo: 'Reprogramar cita',
      subtitulo: 'Cita #${cita.id} · ${cita.especialidad}',
      icono: Icons.update_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kNaranja.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cita actual', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9A3412))),
                const SizedBox(height: 6),
                Text('Dr(a). ${cita.medico}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(cita.especialidad),
                Text(cita.fechaHora, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextoOscuro)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Elige el nuevo horario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextoOscuro)),
          const SizedBox(height: 10),
          SelectorHorario(
            key: _selectorKey,
            profesionalId: cita.idProfesional!,
            onSeleccion: (fecha, hora) => setState(() {
              _fecha = fecha;
              _hora = hora;
            }),
          ),
          const SizedBox(height: 24),
          BotonPrincipal(
            texto: 'Confirmar nuevo horario',
            icono: Icons.check_rounded,
            cargando: _guardando,
            onPressed: (_fecha != null && _hora != null) ? _confirmar : null,
          ),
        ],
      ),
    );
  }
}
