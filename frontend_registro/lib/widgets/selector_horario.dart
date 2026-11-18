import 'package:flutter/material.dart';

import '../models/especialidad_model.dart';
import '../services/especialidad_service.dart';
import '../utils/formato_fecha.dart';
import 'pantalla_base.dart';

/// Muestra los dias y horas libres de un profesional y permite elegir uno.
/// Se usa para consultar disponibilidad (HU006), agendar (HU008) y reprogramar (HU012).
class SelectorHorario extends StatefulWidget {
  final int profesionalId;

  /// Se llama con (fecha yyyy-MM-dd, hora HH:mm) o (null, null) si se deselecciona.
  final void Function(String? fecha, String? hora)? onSeleccion;

  const SelectorHorario({super.key, required this.profesionalId, this.onSeleccion});

  @override
  State<SelectorHorario> createState() => SelectorHorarioState();
}

class SelectorHorarioState extends State<SelectorHorario> {
  final _service = EspecialidadService();
  late Future<List<DiaDisponible>> _future;
  DiaDisponible? _dia;
  String? _hora;

  @override
  void initState() {
    super.initState();
    recargar();
  }

  @override
  void didUpdateWidget(covariant SelectorHorario oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profesionalId != widget.profesionalId) recargar();
  }

  /// Vuelve a consultar la disponibilidad (por ejemplo, si el horario fue tomado por otro paciente).
  void recargar() {
    setState(() {
      _dia = null;
      _hora = null;
      _future = _service.disponibilidad(widget.profesionalId);
    });
    widget.onSeleccion?.call(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final seleccionable = widget.onSeleccion != null;
    return FutureBuilder<List<DiaDisponible>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: kAzul)),
          );
        }
        if (snapshot.hasError) {
          return EstadoVacio(
            icono: Icons.cloud_off_rounded,
            mensaje: 'No fue posible consultar la disponibilidad.\n${snapshot.error}',
            onReintentar: recargar,
          );
        }
        final dias = snapshot.data ?? [];
        if (dias.isEmpty) {
          return const EstadoVacio(
            icono: Icons.event_busy_rounded,
            mensaje: 'El profesional no tiene horarios disponibles en los próximos días.',
          );
        }
        final diaActual = _dia ?? dias.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dias.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final d = dias[i];
                  final activo = d.fechaIso == diaActual.fechaIso;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _dia = d;
                        _hora = null;
                      });
                      widget.onSeleccion?.call(null, null);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 74,
                      decoration: BoxDecoration(
                        color: activo ? kAzul : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(fechaCorta(d.fecha).split(' ').first,
                              style: TextStyle(color: activo ? Colors.white70 : Colors.grey.shade600, fontSize: 12)),
                          Text(fechaCorta(d.fecha).split(' ').skip(1).join(' '),
                              style: TextStyle(
                                  color: activo ? Colors.white : kTextoOscuro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(seleccionable ? 'Hora disponible' : 'Horas disponibles',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in diaActual.horas)
                  ChoiceChip(
                    label: Text(hora12(h)),
                    selected: _hora == h && _dia?.fechaIso == diaActual.fechaIso,
                    selectedColor: kAzul,
                    labelStyle: TextStyle(
                      color: _hora == h ? Colors.white : kTextoOscuro,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: !seleccionable
                        ? null
                        : (sel) {
                            setState(() {
                              _dia = diaActual;
                              _hora = sel ? h : null;
                            });
                            widget.onSeleccion?.call(sel ? diaActual.fechaIso : null, sel ? h : null);
                          },
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
