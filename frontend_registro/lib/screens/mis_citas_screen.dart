import 'package:flutter/material.dart';
import '../models/cita_model.dart';
import '../services/cita_hu010_service.dart';

class MisCitasScreen extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const MisCitasScreen({
    super.key,
    required this.idUsuario,
    this.nombreUsuario = 'Paciente',
  });

  @override
  MisCitasScreenState createState() => MisCitasScreenState();
}

class MisCitasScreenState extends State<MisCitasScreen> with SingleTickerProviderStateMixin {
  final CitaService _citaService = CitaService();
  late Future<List<Cita>> _futureCitas;
  late TabController _tabController;

  late int _idUsuarioActual;
  late String _nombreUsuarioActual;

  String _filtroEstadoSeleccionado = 'TODAS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _idUsuarioActual = widget.idUsuario;
    _nombreUsuarioActual = widget.nombreUsuario;
    _cargarCitas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarCitas() {
    setState(() {
      _futureCitas = _citaService.obtenerCitasPorUsuario(_idUsuarioActual);
    });
  }

  DateTime _parseFecha(String fechaStr) {
    try {
      final regExp = RegExp(r'(\d{2})/(\d{2})/(\d{4})\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
      final match = regExp.firstMatch(fechaStr.trim());

      if (match != null) {
        int dia = int.parse(match.group(1)!);
        int mes = int.parse(match.group(2)!);
        int anio = int.parse(match.group(3)!);
        int hora = int.parse(match.group(4)!);
        int minuto = int.parse(match.group(5)!);
        String ampm = match.group(6)!.toUpperCase();

        if (ampm == 'PM' && hora < 12) hora += 12;
        if (ampm == 'AM' && hora == 12) hora = 0;

        return DateTime(anio, mes, dia, hora, minuto);
      }
    } catch (_) {}
    return DateTime(2000, 1, 1);
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PROGRAMADA':
        return const Color(0xFF0284C7);
      case 'ATENDIDA':
        return const Color(0xFF0D9488);
      case 'FINALIZADA':
      case 'COMPLETADA':
        return const Color(0xFF16A34A);
      case 'CANCELADA':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF0284C7);
    }
  }

  void _mostrarDetalleCita(BuildContext context, Cita cita) {
    final colorEstado = _obtenerColorEstado(cita.estado);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código Cita #${cita.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        Text(cita.especialidad, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cita.estado.toUpperCase(),
                      style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1, thickness: 1),
              ),
              _buildItemDetalle(Icons.medical_services_outlined, 'Especialidad', cita.especialidad),
              _buildItemDetalle(Icons.person_outline, 'Profesional Médico', 'Dr(a). ${cita.medico}'),
              _buildItemDetalle(Icons.access_time_rounded, 'Fecha y Hora Asignada', cita.fechaHora),
              _buildItemDetalle(Icons.qr_code_2_rounded, 'Código de Registro', 'COD-00${cita.id}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar Detalle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemDetalle(IconData icon, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF0284C7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTarjetaCita(Cita cita) {
    final colorEstado = _obtenerColorEstado(cita.estado);
    final isCancelada = cita.estado.toUpperCase() == 'CANCELADA';

    return InkWell(
      onTap: () => _mostrarDetalleCita(context, cita),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCancelada ? const Color(0xFFFFE0B2).withValues(alpha: 0.6) : const Color(0xFFE0F2FE).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorEstado.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cita.especialidad,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorEstado,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    cita.estado.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Dr(a). ${cita.medico}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cita.fechaHora,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOLista(List<Cita> citas, double anchoPantalla) {
    if (citas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No hay citas disponibles', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    int columnas = anchoPantalla > 750 ? 3 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columnas == 3 ? 2.2 : 3.4,
      ),
      itemCount: citas.length,
      itemBuilder: (context, index) => _buildTarjetaCita(citas[index]),
    );
  }

  Widget _buildListaProximas(List<Cita> citas, double anchoPantalla) {
    List<Cita> listaOrdenada = List.from(citas);
    listaOrdenada.sort((a, b) => _parseFecha(a.fechaHora).compareTo(_parseFecha(b.fechaHora)));

    return _buildGridOLista(listaOrdenada, anchoPantalla);
  }

  Widget _buildListaHistorico(List<Cita> citas, double anchoPantalla) {
    List<Cita> citasFiltradas = List.from(citas);
    if (_filtroEstadoSeleccionado != 'TODAS') {
      citasFiltradas = citas.where((c) => c.estado.toUpperCase() == _filtroEstadoSeleccionado).toList();
    }

    citasFiltradas.sort((a, b) => _parseFecha(a.fechaHora).compareTo(_parseFecha(b.fechaHora)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFiltroChipCompacto('TODAS', 'Todas'),
              const SizedBox(width: 6),
              _buildFiltroChipCompacto('PROGRAMADA', 'Programadas'),
              const SizedBox(width: 6),
              _buildFiltroChipCompacto('ATENDIDA', 'Atendidas'),
              const SizedBox(width: 6),
              _buildFiltroChipCompacto('FINALIZADA', 'Finalizadas'),
              const SizedBox(width: 6),
              _buildFiltroChipCompacto('CANCELADA', 'Canceladas'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildGridOLista(citasFiltradas, anchoPantalla),
      ],
    );
  }

  Widget _buildFiltroChipCompacto(String estadoKey, String label) {
    final isSelected = _filtroEstadoSeleccionado == estadoKey;
    final colorChip = _obtenerColorEstado(estadoKey);

    return InkWell(
      onTap: () => setState(() => _filtroEstadoSeleccionado = estadoKey),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colorChip : colorChip.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorChip : colorChip.withValues(alpha: 0.25),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorChip.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colorChip,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double anchoPantalla = constraints.maxWidth;
              final bool esCelular = anchoPantalla < 600;

              final double anchoCard = esCelular
                  ? anchoPantalla * 0.96
                  : (anchoPantalla < 1100 ? anchoPantalla * 0.92 : 1100);

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: esCelular ? 8 : 24,
                    vertical: esCelular ? 12 : 24,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: anchoCard,
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black26,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: EdgeInsets.all(esCelular ? 16.0 : 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0284C7)),
                                        SizedBox(width: 6),
                                        Text('Volver al menú', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF0284C7),
                                    child: Text(
                                      _nombreUsuarioActual.isNotEmpty ? _nombreUsuarioActual[0].toUpperCase() : 'P',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Citas de $_nombreUsuarioActual',
                                          style: TextStyle(
                                            fontSize: esCelular ? 17 : 22,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Paciente Activo #$_idUsuarioActual',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              height: 48,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0xFF0284C7),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xFF64748B),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: esCelular ? 13 : 14,
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: const [
                                  Tab(text: 'Próximas Citas'),
                                  Tab(text: 'Histórico'),
                                ],
                                onTap: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: 20),

                            FutureBuilder<List<Cita>>(
                              future: _futureCitas,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0284C7))),
                                  );
                                } else if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Text('No se encontraron citas asociadas al usuario #$_idUsuarioActual', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text('No hay citas asignadas a este usuario.', style: TextStyle(color: Colors.grey)),
                                    ),
                                  );
                                }

                                final todas = snapshot.data!;
                                final proximas = todas.where((c) => c.estado.toUpperCase() == 'PROGRAMADA').toList();
                                final historico = todas.where((c) => c.estado.toUpperCase() != 'PROGRAMADA').toList();

                                return _tabController.index == 0
                                    ? _buildListaProximas(proximas, anchoCard)
                                    : _buildListaHistorico(historico, anchoCard);
                              },
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _cargarCitas,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
                                label: const Text('Actualizar Citas', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}