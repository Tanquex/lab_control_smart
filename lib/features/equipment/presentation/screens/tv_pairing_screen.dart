import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../config/constants/environment.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/session/tv_auth_session.dart';
import 'equipment_screen.dart';

class TvPairingScreen extends StatefulWidget {
  const TvPairingScreen({super.key});

  @override
  State<TvPairingScreen> createState() => _TvPairingScreenState();
}

class _TvPairingScreenState extends State<TvPairingScreen> {
  String _pairingCode = '';
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _requestPairingCode();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Solicita el código de emparejamiento al backend
  Future<void> _requestPairingCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/auth/tv/request'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final code = data['code'] as String;
        setState(() {
          _pairingCode = code;
          _isLoading = false;
        });
        _startPolling(code);
      } else {
        setState(() {
          _errorMessage = 'Error del servidor al generar el código (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor backend. Verifica tu conexión.';
        _isLoading = false;
      });
    }
  }

  // Inicia la consulta periódica (polling) de estado
  void _startPolling(String code) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('${Environment.baseUrl}/auth/tv/status/$code'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final status = data['status'] as String;

          if (status == 'paired') {
            timer.cancel();
            final userData = data['user'] as Map<String, dynamic>;
            
            // Guardar sesión y entrar al Dashboard
            TvAuthSession.setSession(userData);
            _navigateToDashboard();
          } else if (status == 'expired') {
            timer.cancel();
            setState(() {
              _errorMessage = 'El código ha expirado. Genera uno nuevo.';
              _pairingCode = '';
            });
          }
        }
      } catch (_) {
        // Ignorar fallos de red temporales durante el polling
      }
    });
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EquipmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo de la Aplicación
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.monitor_rounded,
                        color: AppTheme.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LABCONTROL',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          'Tablero Informativo TV',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 50),

                // Tarjeta Principal de Vinculación
                Container(
                  width: 650,
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(color: AppTheme.primary),
                            SizedBox(height: 20),
                            Text(
                              'Generando código de vinculación...',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        )
                      : _errorMessage.isNotEmpty && _pairingCode.isEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppTheme.statusUnavailable, size: 54),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _requestPairingCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('GENERAR NUEVO CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'VINCULAR NUEVO DISPOSITIVO',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ingresa el siguiente código en tu aplicación móvil para autorizar este tablero:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                
                                // Contenedor del Código de Emparejamiento
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Text(
                                    _pairingCode,
                                    style: const TextStyle(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primary,
                                      letterSpacing: 8.0,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Text(
                                      'Esperando confirmación desde la App Móvil...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
