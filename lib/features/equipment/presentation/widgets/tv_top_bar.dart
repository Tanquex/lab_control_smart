import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';

class TvTopBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const TvTopBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<TvTopBar> createState() => _TvTopBarState();
}

class _TvTopBarState extends State<TvTopBar> {
  final List<Map<String, dynamic>> _tabs = const [
    {'title': 'Stock de Equipos', 'icon': Icons.inventory_2_rounded},
    {'title': 'Pedidos y Turnos', 'icon': Icons.assignment_turned_in_rounded},
    {'title': 'Resumen del Lab', 'icon': Icons.dashboard_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo / Título de LabControl
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_rounded,
                  color: AppTheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'LAB',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        TextSpan(
                          text: 'CONTROL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Tablero Informativo TV',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 40),

          // Botones de Navegación D-Pad
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = widget.selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _TvTabButton(
                      title: tab['title'],
                      icon: tab['icon'],
                      isSelected: isSelected,
                      onPressed: () => widget.onTabSelected(index),
                      autofocus: index == 0,
                    ),
                  );
                }),
              ),
            ),
          ),

          // Indicador de Estado en Vivo (Live Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.statusAvailable.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.statusAvailable.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.statusAvailable,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'EN VIVO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.statusAvailable,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TvTabButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool autofocus;

  const _TvTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_TvTabButton> createState() => _TvTabButtonState();
}

class _TvTabButtonState extends State<_TvTabButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary
                : (_isFocused
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.background),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primary
                  : (widget.isSelected
                      ? AppTheme.primary
                      : Colors.transparent),
              width: 2,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : (_isFocused ? AppTheme.primary : AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
                  color: widget.isSelected
                      ? Colors.white
                      : (_isFocused ? AppTheme.primary : AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
