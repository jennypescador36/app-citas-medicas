import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../widgets/pantalla_base.dart';
import 'home_screen.dart';

/// HU002 - Inicio de sesion con correo y contrasena.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _cargando = false;

  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final usuario = await _authService.login(_correoController.text, _passwordController.text);
      if (!mounted) return;
      _passwordController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: usuario)),
      );
    } on ApiException catch (e) {
      if (mounted) mostrarMensaje(context, e.mensaje, error: true);
    } catch (e) {
      debugPrint('Error login: $e');
      if (mounted) mostrarMensaje(context, 'No hay conexión con el servidor. Intenta de nuevo.', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _irARegistro() async {
    final correoRegistrado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
    if (correoRegistrado != null && mounted) {
      _correoController.text = correoRegistrado;
      mostrarMensaje(context, 'Registro exitoso. Ingresa tu contraseña para iniciar sesión.');
    }
  }

  InputDecoration _decoracion(String label, IconData icono, {Widget? sufijo}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: kAzul),
      suffixIcon: sufijo,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Medical Center',
      subtitulo: 'Inicia sesión para continuar',
      mostrarVolver: false,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: _decoracion('Correo Electrónico', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El correo electrónico es obligatorio';
                if (!_emailRegex.hasMatch(v.trim())) return 'Ingresa un correo válido (ej. usuario@dominio.com)';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _iniciarSesion(),
              decoration: _decoracion(
                'Contraseña',
                Icons.lock_outline,
                sufijo: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade600),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'La contraseña es obligatoria' : null,
            ),
            const SizedBox(height: 24),
            BotonPrincipal(
              texto: 'Iniciar sesión',
              icono: Icons.login_rounded,
              cargando: _cargando,
              onPressed: _iniciarSesion,
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _cargando ? null : _irARegistro,
              icon: const Icon(Icons.person_add_alt_1_outlined, color: kAzul),
              label: const Text('¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: kAzul, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
