import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mis_citas_screen.dart';

class CitaHu010Service {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String documento,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('http://10.0.2.2:8080/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'documento': documento,
          'correo': correo,
          'telefono': telefono,
          'password': password,
        }),
      );

      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final registro = data.isNotEmpty ? data : {'id': 1, 'nombre': nombre};
        return {'exito': true, 'data': registro};
      }

      final mensaje = data['mensaje'] ?? data['message'] ?? 'No se pudo registrar el usuario.';
      return {'exito': false, 'mensaje': mensaje};
    } catch (_) {
      return {'exito': false, 'mensaje': 'Error de conexión. Intenta nuevamente.'};
    }
  }
}

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  RegistroScreenState createState() => RegistroScreenState();
}

class RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final CitaHu010Service _service = CitaHu010Service();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final resultado = await _service.registrarUsuario(
      nombre: _nombreController.text.trim(),
      documento: _documentoController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (resultado['exito'] == true) {
      final usuario = resultado['data'];
      final int idUsuario = usuario['id'] ?? 1;
      final String nombreUsuario = usuario['nombre'] ?? _nombreController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Bienvenido a MediAgenda.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MisCitasScreen(
            idUsuario: idUsuario,
            nombreUsuario: nombreUsuario,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje'] ?? 'Error al registrar'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    }
  }

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
              final double anchoPantalla = constraints.maxWidth;
              final bool esCelular = anchoPantalla < 600;
              final double anchoCard = esCelular ? anchoPantalla * 0.94 : 520;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: anchoCard,
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: EdgeInsets.all(esCelular ? 20.0 : 32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital_rounded,
                                      size: 32,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Crear Cuenta Médica',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Regístrate para gestionar y consultar tus citas',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              _buildInput(
                                controller: _nombreController,
                                label: 'Nombre Completo',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _documentoController,
                                label: 'Número de Documento',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu documento' : null,
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _correoController,
                                label: 'Correo Electrónico',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Ingresa tu correo';
                                  if (!v.contains('@')) return 'Correo inválido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildInput(
                                controller: _telefonoController,
                                label: 'Teléfono Celular',
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu teléfono' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: (v) =>
                                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0284C7)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _registrar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'Registrarme',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MisCitasScreen(
                                        idUsuario: 1,
                                        nombreUsuario: 'Paciente Demo',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0284C7)),
                                label: const Text(
                                  'Ir directo a Mis Citas (HU010)',
                                  style: TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0284C7)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}