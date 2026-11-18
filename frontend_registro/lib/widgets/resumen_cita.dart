import 'package:flutter/material.dart';

import '../models/cita_model.dart';
import 'pantalla_base.dart';

/// Dialogo con los datos de una cita recien agendada o reprogramada (HU008 / HU012).
Future<void> mostrarResumenCita(
  BuildContext context, {
  required String titulo,
  required Cita cita,
  String? fechaAnterior,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 56),
      title: Text(titulo, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fila(Icons.confirmation_number_outlined, 'Número de cita', '#${cita.id}'),
          _fila(Icons.medical_services_outlined, 'Especialidad', cita.especialidad),
          _fila(Icons.person_outline, 'Profesional', 'Dr(a). ${cita.medico}'),
          if (fechaAnterior != null) _fila(Icons.history_rounded, 'Horario anterior', fechaAnterior, tachado: true),
          _fila(Icons.access_time_rounded, 'Fecha y hora', cita.fechaHora),
          if (cita.consultorio != null) _fila(Icons.meeting_room_outlined, 'Lugar', cita.consultorio!),
          _fila(Icons.flag_outlined, 'Estado', cita.estado),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAzul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ),
      ],
    ),
  );
}

Widget _fila(IconData icono, String titulo, String valor, {bool tachado = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: kAzul),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tachado ? Colors.grey : kTextoOscuro,
                  decoration: tachado ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
