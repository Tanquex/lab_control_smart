import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../domain/entities/equipment.dart';
import 'tv_focusable_card.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback? onPressed;

  const EquipmentCard({
    super.key,
    required this.equipment,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = equipment.availableUnits > 0;
    final bool isLowStock = equipment.availableUnits > 0 && equipment.availableUnits <= 2;

    // Reglas de color según Sección 3.1
    final Color statusColor = !isAvailable
        ? AppTheme.statusUnavailable
        : (isLowStock ? AppTheme.statusWarning : AppTheme.statusAvailable);

    final String statusText = !isAvailable
        ? 'AGOTADO'
        : (isLowStock ? 'STOCK BAJO' : 'DISPONIBLE');

    return TvFocusableCard(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Cabecera: Tag de Categoría y Badge de Disponibilidad
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag de Categoría
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      equipment.categoryId.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de Disponibilidad según Sección 3.3.2
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2. Icono e Información Principal del Equipo
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Contenedor del Icono según Sección 3.3.1 (56x56 px, fondo #F7F8FA, radio 12px)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(equipment.categoryId),
                      size: 26,
                      color: isAvailable ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Título y Código
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          equipment.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Línea divisoria muy suave
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),

            const SizedBox(height: 10),

            // 3. Pie: Ubicación y Contador de Unidades
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ubicación
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          equipment.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Unidades Libres vs Totales
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${equipment.availableUnits}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isAvailable ? statusColor : AppTheme.statusUnavailable,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${equipment.totalUnits} Libres',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('electrónica') || lower.contains('electronica')) {
      return Icons.developer_board_rounded;
    } else if (lower.contains('cómputo') || lower.contains('computo')) {
      return Icons.laptop_chromebook_rounded;
    } else if (lower.contains('redes')) {
      return Icons.router_rounded;
    }
    return Icons.build_circle_rounded;
  }
}
