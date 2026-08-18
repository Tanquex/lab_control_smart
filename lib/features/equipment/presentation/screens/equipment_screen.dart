import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/models/equipment_model.dart';
import '../../data/repositories/equipment_repository.dart';
import '../widgets/equipment_card.dart';
import '../widgets/tv_focusable_card.dart';
import '../widgets/tv_top_bar.dart';
import '../../../reservations/data/models/reservation_model.dart';
import '../../../reservations/data/repositories/reservations_repository.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final EquipmentRepository _repository = EquipmentRepository();
  final ReservationsRepository _reservationsRepository = ReservationsRepository();
  
  List<EquipmentModel> _equipmentList = [];
  List<ReservationModel> _reservationsList = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresco en tiempo real cada 10 segundos para pantalla de TV
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final equipments = await _repository.getEquipmentList();
    final reservations = await _reservationsRepository.getReservationsList();
    if (mounted) {
      setState(() {
        _equipmentList = equipments;
        _reservationsList = reservations;
        _isLoading = false;
      });
    }
  }

  Future<void> _silentRefreshData() async {
    final equipments = await _repository.getEquipmentList();
    final reservations = await _reservationsRepository.getReservationsList();
    if (mounted) {
      setState(() {
        _equipmentList = equipments;
        _reservationsList = reservations;
      });
    }
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
                  : (_selectedTabIndex == 1
                      ? _buildReservationsView()
                      : _buildLabSummaryView(
                          totalEquipments: totalEquipments,
                          totalUnits: totalUnits,
                          availableUnits: availableUnits,
                          rentedUnits: rentedUnits,
                        )),
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
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera Informativa Desahogada con padding horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Wrap(
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
                        clipBehavior: Clip.hardEdge,
                        padding: const EdgeInsets.only(left: 28, right: 28, bottom: 24, top: 10),
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

  Widget _buildReservationsView() {
    // Filtrar préstamos activos (active y pending)
    final activeReservations = _reservationsList
        .where((res) => res.status == 'active' || res.status == 'pending')
        .toList();
    final now = DateTime.now();

    // Identificar vencidos y próximos a vencer
    final expiredReservations = activeReservations
        .where((res) => res.returnDate.isBefore(now))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUMNA IZQUIERDA: Tabla de préstamos activos
          Expanded(
            flex: 2,
            child: Card(
              color: AppTheme.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Préstamos Activos y Turnos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: activeReservations.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay préstamos activos en este momento',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2.8),
                                  1: FlexColumnWidth(1.2),
                                  2: FlexColumnWidth(2.8),
                                  3: FlexColumnWidth(1.2),
                                  4: FlexColumnWidth(1.2),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Alumno',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Matrícula',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Equipo',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Devolución',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Estado',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...activeReservations.map((res) {
                                    final isExpired = res.returnDate.isBefore(now);
                                    final isClose = !isExpired &&
                                        res.returnDate.difference(now).inMinutes <= 15;

                                    Color stateColor = AppTheme.statusAvailable;
                                    String stateText = 'Activo';
                                    if (isExpired) {
                                      stateColor = AppTheme.statusUnavailable;
                                      stateText = 'Vencido';
                                    } else if (isClose) {
                                      stateColor = AppTheme.statusWarning;
                                      stateText = 'Por Vencer';
                                    }

                                    final timeStr =
                                        '${res.returnDate.hour.toString().padLeft(2, '0')}:${res.returnDate.minute.toString().padLeft(2, '0')}';

                                    return TableRow(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade100,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            res.userName ?? 'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            res.studentId ?? 'N/A',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            res.equipmentName ?? 'Equipo',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            timeStr,
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: stateColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: stateColor.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              stateText.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: stateColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // COLUMNA DERECHA: Alertas y actividad reciente
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // 1. Panel de Equipos Vencidos (Alertas Críticas)
                Expanded(
                  child: Card(
                    color: AppTheme.cardSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.statusUnavailable,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Equipos Vencidos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: expiredReservations.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay entregas demoradas',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: expiredReservations.length,
                                    itemBuilder: (context, index) {
                                      final res = expiredReservations[index];
                                      final delay = now.difference(res.returnDate);
                                      final delayStr = delay.inHours > 0
                                          ? '+${delay.inHours}h ${delay.inMinutes % 60}m'
                                          : '+${delay.inMinutes} min';

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusUnavailable.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppTheme.statusUnavailable.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    res.userName ?? 'Alumno',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textPrimary,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    res.equipmentName ?? 'Equipo',
                                                    style: const TextStyle(
                                                      color: AppTheme.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.statusUnavailable,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                delayStr,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 2. Historial o Actividad Reciente
                Expanded(
                  child: Card(
                    color: AppTheme.cardSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.history_rounded, color: AppTheme.primary, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Actividad Reciente',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _reservationsList.length > 5
                                  ? 5
                                  : _reservationsList.length,
                              itemBuilder: (context, index) {
                                final res = _reservationsList[index];
                                final isCompleted = res.status == 'completed';
                                final isCancelled = res.status == 'cancelled';

                                String actionText = 'reservó';
                                Color actionColor = AppTheme.primary;
                                IconData actionIcon = Icons.add_circle_outline_rounded;

                                if (isCompleted) {
                                  actionText = 'devolvió';
                                  actionColor = AppTheme.statusAvailable;
                                  actionIcon = Icons.assignment_return_rounded;
                                } else if (isCancelled) {
                                  actionText = 'canceló';
                                  actionColor = AppTheme.textSecondary;
                                  actionIcon = Icons.cancel_outlined;
                                } else if (res.status == 'active') {
                                  actionText = 'recogió';
                                  actionColor = AppTheme.statusWarning;
                                  actionIcon = Icons.check_circle_outline_rounded;
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(actionIcon, size: 18, color: actionColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textPrimary,
                                              height: 1.3,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: res.userName ?? 'Alumno',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(text: ' $actionText '),
                                              TextSpan(
                                                text: res.equipmentName ?? 'Equipo',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabSummaryView({
    required int totalEquipments,
    required int totalUnits,
    required int availableUnits,
    required int rentedUnits,
  }) {
    final availablePercent = totalUnits > 0 ? (availableUnits / totalUnits) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gráfica de disponibilidad y resumen general
          Expanded(
            flex: 1,
            child: Card(
              color: AppTheme.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Disponibilidad de Inventario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: availablePercent,
                            strokeWidth: 22,
                            backgroundColor: AppTheme.statusWarning.withOpacity(0.2),
                            color: AppTheme.statusAvailable,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(availablePercent * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.statusAvailable,
                              ),
                            ),
                            const Text(
                              'Disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppTheme.statusAvailable,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Disponible ($availableUnits uds)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppTheme.statusWarning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'En Uso ($rentedUnits uds)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // 2. Resumen de Categorías
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Métricas por Categoría',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.7,
                    children: [
                      _buildCategorySummaryCard(
                        category: 'Electrónica',
                        icon: Icons.developer_board_rounded,
                        color: AppTheme.primary,
                        equipmentList: _equipmentList,
                      ),
                      _buildCategorySummaryCard(
                        category: 'Cómputo',
                        icon: Icons.laptop_chromebook_rounded,
                        color: Colors.blue.shade600,
                        equipmentList: _equipmentList,
                      ),
                      _buildCategorySummaryCard(
                        category: 'Redes',
                        icon: Icons.router_rounded,
                        color: Colors.purple.shade600,
                        equipmentList: _equipmentList,
                      ),
                      _buildCategorySummaryCard(
                        category: 'Otros',
                        icon: Icons.build_circle_rounded,
                        color: Colors.grey.shade600,
                        equipmentList: _equipmentList,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySummaryCard({
    required String category,
    required IconData icon,
    required Color color,
    required List<EquipmentModel> equipmentList,
  }) {
    final catEquipments = equipmentList.where((eq) {
      final cat = eq.categoryId.toLowerCase();
      if (category == 'Otros') {
        return !cat.contains('electrónica') &&
            !cat.contains('electronica') &&
            !cat.contains('cómputo') &&
            !cat.contains('computo') &&
            !cat.contains('redes');
      }
      return cat.contains(category.toLowerCase().substring(0, 4));
    }).toList();

    final catTotalUnits = catEquipments.fold<int>(0, (sum, eq) => sum + eq.totalUnits);
    final catAvailableUnits = catEquipments.fold<int>(0, (sum, eq) => sum + eq.availableUnits);
    final catRentedUnits = catTotalUnits - catAvailableUnits;

    return Card(
      color: AppTheme.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${catEquipments.length} modelos de equipos',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Disp: $catAvailableUnits',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.statusAvailable,
                        ),
                      ),
                      Text(
                        'En Uso: $catRentedUnits',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
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
              if (item.imageUrl.isNotEmpty)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.background,
                        child: const Icon(Icons.broken_image_rounded, size: 40, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
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
