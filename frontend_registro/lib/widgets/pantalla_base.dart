import 'package:flutter/material.dart';

const Color kAzul = Color(0xFF0284C7);
const Color kAzulClaro = Color(0xFFE0F2FE);
const Color kTextoOscuro = Color(0xFF0F172A);
const Color kNaranja = Color(0xFFFF8A65);

/// Estructura visual comun: fondo degradado azul + tarjeta blanca centrada.
class PantallaBase extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final Widget child;
  final bool mostrarVolver;
  final List<Widget> acciones;

  const PantallaBase({
    super.key,
    required this.titulo,
    required this.child,
    this.subtitulo,
    this.icono = Icons.health_and_safety_outlined,
    this.mostrarVolver = true,
    this.acciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final ancho = constraints.maxWidth;
              final esCelular = ancho < 600;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: esCelular ? 8 : 24, vertical: esCelular ? 12 : 24),
                  child: SizedBox(
                    width: esCelular ? ancho * 0.96 : (ancho < 1100 ? ancho * 0.8 : 820),
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black26,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: EdgeInsets.all(esCelular ? 16 : 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (mostrarVolver || acciones.isNotEmpty)
                              Row(
                                children: [
                                  if (mostrarVolver)
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      borderRadius: BorderRadius.circular(10),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kAzul),
                                            SizedBox(width: 6),
                                            Text('Volver', style: TextStyle(color: kAzul, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  ...acciones,
                                ],
                              ),
                            if (mostrarVolver || acciones.isNotEmpty) const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: kAzulClaro, borderRadius: BorderRadius.circular(24)),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: kAzul, borderRadius: BorderRadius.circular(18)),
                                    child: Icon(icono, size: 30, color: Colors.white),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(titulo,
                                            style: TextStyle(
                                                fontSize: esCelular ? 18 : 22,
                                                fontWeight: FontWeight.bold,
                                                color: kTextoOscuro)),
                                        if (subtitulo != null)
                                          Text(subtitulo!,
                                              style: const TextStyle(
                                                  fontSize: 12, color: kAzul, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            child,
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

/// Mensaje flotante de exito (verde) o error (rojo).
void mostrarMensaje(BuildContext context, String mensaje, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Bloque para estados vacios o de error.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final VoidCallback? onReintentar;

  const EstadoVacio({super.key, required this.icono, required this.mensaje, this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icono, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(mensaje, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          if (onReintentar != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Boton principal azul de ancho completo.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  const BotonPrincipal({super.key, required this.texto, this.onPressed, this.cargando = false, this.icono});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAzul,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: cargando
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icono != null) ...[Icon(icono), const SizedBox(width: 8)],
                  Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
