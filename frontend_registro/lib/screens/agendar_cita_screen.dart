import 'package:flutter/material.dart';

import '../models/especialidad_model.dart';
import '../models/usuario_model.dart';
import '../services/agenda_service.dart';
import '../services/api_exception.dart';
import '../services/especialidad_service.dart';
import '../utils/formato_fecha.dart';
import '../widgets/pantalla_base.dart';
import '../widgets/resumen_cita.dart';
import '../widgets/selector_horario.dart';
import 'mis_citas_screen.dart';

/// HU008 - Agendamiento de cita: especialidad -> profesional -> fecha -> hora -> confirmar.
class AgendarCitaScreen extends StatefulWidget {
  final Usuario usuario;
  final int? especialidadInicialId;
  final int? profesionalInicialId;

  const AgendarCitaScreen({
    super.key,
    required this.usuario,
    this.especialidadInicialId,
    this.profesionalInicialId,
  });

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  final _especialidadService = EspecialidadService();
  final _agendaService = AgendaService();
  final _selectorKey = GlobalKey<SelectorHorarioState>();

  List<Especialidad> _especialidades = [];
  List<Profesional> _profesionales = [];
  Especialidad? _especialidad;
  Profesional? _profesional;
  String? _fecha;
  String? _hora;

  bool _cargandoEspecialidades = true;
  bool _cargandoProfesionales = false;
  bool _agendando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEspecialidades();
  }

  Future<void> _cargarEspecialidades() async {
    setState(() {
      _cargandoEspecialidades = true;
      _error = null;
    });
    try {
      final lista = await _especialidadService.listarEspecialidades();
      if (!mounted) return;
      setState(() {
        _especialidades = lista;
        _cargandoEspecialidades = false;
      });
      final inicial = lista.where((e) => e.id == widget.especialidadInicialId).toList();
      if (inicial.isNotEmpty) await _seleccionarEspecialidad(inicial.first);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoEspecialidades = false;
        _error = 'No fue posible cargar las especialidades.\n$e';
      });
    }
  }

  Future<void> _seleccionarEspecialidad(Especialidad? e) async {
    setState(() {
      _especialidad = e;
      _profesional = null;
      _profesionales = [];
      _fecha = null;
      _hora = null;
      _cargandoProfesionales = e != null;
    });
    if (e == null) return;
    try {
      final lista = await _especialidadService.listarProfesionales(e.id);
      if (!mounted || _especialidad?.id != e.id) return;
      setState(() {
        _profesionales = lista;
        _cargandoProfesionales = false;
        final inicial = lista.where((p) => p.id == widget.profesionalInicialId).toList();
        if (inicial.isNotEmpty && inicial.first.tieneDisponibilidad) _profesional = inicial.first;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _cargandoProfesionales = false);
      mostrarMensaje(context, 'No fue posible cargar los profesionales: $err', error: true);
    }
  }

  Future<void> _confirmar() async {
    if (_profesional == null || _fecha == null || _hora == null) return;
    final p = _profesional!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirmar cita'),
        content: Text(
          '${p.especialidad}\nDr(a). ${p.nombre}\n${fechaCorta(DateTime.parse(_fecha!))} a las ${hora12(_hora!)}\n${p.consultorio}',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Agendar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _agendando = true);
    try {
      final cita = await _agendaService.agendar(
        idUsuario: widget.usuario.id,
        idProfesional: p.id,
        fecha: _fecha!,
        hora: _hora!,
      );
      if (!mounted) return;
      await mostrarResumenCita(context, titulo: '¡Cita agendada!', cita: cita);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MisCitasScreen(idUsuario: widget.usuario.id, nombreUsuario: widget.usuario.nombre),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, error: true);
      // El horario pudo haber sido tomado por otro paciente: refrescar la disponibilidad
      if (e.statusCode == 409) _selectorKey.currentState?.recargar();
    } catch (e) {
      if (mounted) mostrarMensaje(context, 'No hay conexión con el servidor. Intenta de nuevo.', error: true);
    } finally {
      if (mounted) setState(() => _agendando = false);
    }
  }

  InputDecoration _decoracion(String label, IconData icono) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: kAzul),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );

  Widget _paso(int numero, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: kAzul,
              child: Text('$numero', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Agendar cita',
      subtitulo: 'Elige especialidad, profesional, fecha y hora',
      icono: Icons.edit_calendar_outlined,
      child: _cargandoEspecialidades
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: kAzul)),
            )
          : _error != null
              ? EstadoVacio(icono: Icons.cloud_off_rounded, mensaje: _error!, onReintentar: _cargarEspecialidades)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _paso(1, 'Especialidad'),
                    DropdownButtonFormField<int>(
                      key: ValueKey('esp-${_especialidad?.id}'),
                      initialValue: _especialidad?.id,
                      isExpanded: true,
                      decoration: _decoracion('Selecciona la especialidad', Icons.medical_services_outlined),
                      items: [
                        for (final e in _especialidades)
                          DropdownMenuItem(
                            value: e.id,
                            enabled: e.cantidadProfesionales > 0,
                            child: Text(
                              e.cantidadProfesionales > 0 ? e.nombre : '${e.nombre} (sin profesionales)',
                              style: TextStyle(color: e.cantidadProfesionales > 0 ? kTextoOscuro : Colors.grey),
                            ),
                          ),
                      ],
                      onChanged: (id) => _seleccionarEspecialidad(_especialidades.firstWhere((e) => e.id == id)),
                    ),
                    const SizedBox(height: 16),
                    if (_especialidad != null) ...[
                      _paso(2, 'Profesional'),
                      if (_cargandoProfesionales)
                        const LinearProgressIndicator(color: kAzul)
                      else if (_profesionales.isEmpty)
                        const EstadoVacio(
                          icono: Icons.person_off_outlined,
                          mensaje: 'No hay profesionales disponibles en esta especialidad.',
                        )
                      else
                        DropdownButtonFormField<int>(
                          key: ValueKey('prof-${_especialidad!.id}-${_profesional?.id}'),
                          initialValue: _profesional?.id,
                          isExpanded: true,
                          decoration: _decoracion('Selecciona el profesional', Icons.person_outline),
                          items: [
                            for (final p in _profesionales)
                              DropdownMenuItem(
                                value: p.id,
                                enabled: p.tieneDisponibilidad,
                                child: Text(
                                  p.tieneDisponibilidad
                                      ? 'Dr(a). ${p.nombre} · ${p.horario}'
                                      : 'Dr(a). ${p.nombre} (sin disponibilidad)',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: p.tieneDisponibilidad ? kTextoOscuro : Colors.grey),
                                ),
                              ),
                          ],
                          onChanged: (id) => setState(() {
                            _profesional = _profesionales.firstWhere((p) => p.id == id);
                            _fecha = null;
                            _hora = null;
                          }),
                        ),
                      const SizedBox(height: 16),
                    ],
                    if (_profesional != null) ...[
                      _paso(3, 'Fecha y hora'),
                      SelectorHorario(
                        key: _selectorKey,
                        profesionalId: _profesional!.id,
                        onSeleccion: (fecha, hora) => setState(() {
                          _fecha = fecha;
                          _hora = hora;
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                    BotonPrincipal(
                      texto: 'Confirmar cita',
                      icono: Icons.check_rounded,
                      cargando: _agendando,
                      onPressed: (_profesional != null && _fecha != null && _hora != null) ? _confirmar : null,
                    ),
                  ],
                ),
    );
  }
}
