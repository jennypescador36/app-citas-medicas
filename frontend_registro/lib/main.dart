import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';
import 'screens/login_screen.dart';
import 'services/api_exception.dart';

void main() {
  runApp(const MiAppSalud());
}

class MiAppSalud extends StatelessWidget {
  const MiAppSalud({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Center - Citas Médicas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFFF8A65),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _tipoUsuario = 'PACIENTE';
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/api/usuarios/registro');

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'documento': _documentoController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'correo': _correoController.text.trim(),
          'contrasena': _passwordController.text,
          'tipoUsuario': _tipoUsuario,
        }),
      )
          .timeout(timeoutApi);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Map<String, dynamic> data = {};
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(utf8.decode(response.bodyBytes));
        } catch (_) {}
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        // HU001 -> HU002: volver al inicio de sesion con el correo ya diligenciado
        final correoRegistrado = (data['correo'] ?? _correoController.text.trim()).toString();
        _limpiarFormulario();
        Navigator.pop(context, correoRegistrado);
      } else {
        String errorMsg = data['mensaje'] ?? data['error'] ?? 'Error del servidor (${response.statusCode})';
        _mostrarSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      debugPrint('Detalle del error HTTP: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarSnackBar('No hay conexión con el servidor. Intenta de nuevo.', Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _documentoController.clear();
    _nombreController.clear();
    _correoController.clear();
    _passwordController.clear();
    setState(() => _tipoUsuario = 'PACIENTE');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool esCelular = size.width < 600;

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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: esCelular ? 12 : 24,
                vertical: esCelular ? 12 : 24,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: esCelular ? size.width * 0.96 : (size.width < 1100 ? size.width * 0.75 : 560),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: Padding(
                    padding: EdgeInsets.all(esCelular ? 20.0 : 36.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.health_and_safety_outlined, size: 36, color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Medical Center',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      Text(
                                        'Crea tu cuenta para agendar',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Campo Número de Documento: solo acepta dígitos
                          _buildTextField(
                            controller: _documentoController,
                            label: 'Número de Documento',
                            icon: Icons.badge_outlined,
                            type: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'El número de documento es obligatorio';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) {
                                return 'Solo se permiten números';
                              }
                              if (v.trim().length < 5) {
                                return 'Ingresa un número de documento válido (mínimo 5 dígitos)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Campo Nombre Completo
                          _buildTextField(
                            controller: _nombreController,
                            label: 'Nombre Completo',
                            icon: Icons.person_outline,
                            type: TextInputType.name,
                          ),
                          const SizedBox(height: 14),

                          // Campo Correo Electrónico: exige @ y dominio válido
                          _buildTextField(
                            controller: _correoController,
                            label: 'Correo Electrónico',
                            icon: Icons.email_outlined,
                            type: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'El correo electrónico es obligatorio';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Ingresa un correo válido con @ y dominio (ej. usuario@dominio.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0284C7)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade600),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Debe tener al menos 6 caracteres' : null,
                          ),
                          const SizedBox(height: 20),

                          const Text('Tipo de Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _tipoUsuario = 'PACIENTE'),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _tipoUsuario == 'PACIENTE' ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Paciente',
                                        style: TextStyle(
                                          color: _tipoUsuario == 'PACIENTE' ? Colors.white : const Color(0xFF64748B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _tipoUsuario = 'SALUD'),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _tipoUsuario == 'SALUD' ? const Color(0xFFFF8A65) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Médico / Salud',
                                        style: TextStyle(
                                          color: _tipoUsuario == 'SALUD' ? Colors.white : const Color(0xFF64748B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                  shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.login_rounded, color: Color(0xFF0284C7)),
                            label: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType type,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0284C7)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        errorMaxLines: 2,
      ),
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
    );
  }
}