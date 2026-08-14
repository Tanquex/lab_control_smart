import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/models/equipment_model.dart';
import '../../data/repositories/equipment_repository.dart';
import '../widgets/equipment_card.dart';
import '../widgets/tv_top_bar.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final EquipmentRepository _repository = EquipmentRepository();
  List<EquipmentModel> _equipmentList = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final items = await _repository.getEquipmentList();
    setState(() {
      _equipmentList = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cálculo de estadísticas rápidas para la cabecera
    final totalEquipments = _equipmentList.length;
    final totalUnits = _equipmentList.fold<int>(0, (sum, item) => sum + item.totalUnits);
    final availableUnits = _equipmentList.fold<int>(0, (sum, item) => sum + item.availableUnits);
    final rentedUnits = totalUnits - availableUnits;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra de Navegación Superior para Smart TV (Top Bar)
            TvTopBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),

            // 2. Contenido según pestaña seleccionada
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildStockView(
                      totalEquipments: totalEquipments,
                      totalUnits: totalUnits,
                      availableUnits: availableUnits,
                      rentedUnits: rentedUnits,
                    )
                  : _buildPlaceholderView(_selectedTabIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockView({
    required int totalEquipments,
    required int totalUnits,
    required int availableUnits,
    required int rentedUnits,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera Informativa Desahogada
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catálogo de Equipos y Stock',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Monitoreo en tiempo real de disponibilidad en laboratorios',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              // Chips Informativos de Métricas (Diseño Limpio)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MetricChip(
                      label: 'TOTAL',
                      value: '$totalUnits',
                      color: AppTheme.primary,
                      icon: Icons.inventory_rounded,
                    ),
                    const SizedBox(width: 10),
                    _MetricChip(
                      label: 'DISPONIBLES',
                      value: '$availableUnits',
                      color: AppTheme.statusAvailable,
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 10),
                    _MetricChip(
                      label: 'EN PRÉSTAMO',
                      value: '$rentedUnits',
                      color: AppTheme.statusWarning,
                      icon: Icons.assignment_return_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Rejilla Adaptativa de Equipos Enfocables por D-Pad / Teclado
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 3;
                      double childAspectRatio = 1.20;

                      if (constraints.maxWidth < 900) {
                        crossAxisCount = 2;
                        childAspectRatio = 1.25;
                      } else if (constraints.maxWidth < 1300) {
                        crossAxisCount = 3;
                        childAspectRatio = 1.20;
                      } else {
                        crossAxisCount = 4;
                        childAspectRatio = 1.25;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount: _equipmentList.length,
                        itemBuilder: (context, index) {
                          final item = _equipmentList[index];
                          return EquipmentCard(
                            equipment: item,
                            onPressed: () {
                              _showEquipmentDetailsDialog(context, item);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(int tabIndex) {
    final title = tabIndex == 1 ? 'Pedidos y Turnos de Préstamo' : 'Resumen Informativo del Laboratorio';
    final subtitle = tabIndex == 1
        ? 'Próximamente: Lista de turnos activos y cola de devolución para pantalla de TV'
        : 'Próximamente: Avisos del laboratorio y horarios de atención';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabIndex == 1 ? Icons.assignment_outlined : Icons.info_outline_rounded,
            size: 64,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipmentDetailsDialog(BuildContext context, EquipmentModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_rounded, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código: ${item.code}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Ubicación: ${item.location}', style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Text('Unidades Totales: ${item.totalUnits}', style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Text('Unidades Disponibles: ${item.availableUnits}', style: const TextStyle(color: AppTheme.statusAvailable, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CERRAR', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
