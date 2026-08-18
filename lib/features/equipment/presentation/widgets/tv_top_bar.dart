import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/session/tv_auth_session.dart';

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
  late final List<FocusNode> _focusNodes;

  final List<Map<String, dynamic>> _tabs = const [
    {'title': 'Stock de Equipos', 'icon': Icons.inventory_2_rounded},
    {'title': 'Pedidos y Turnos', 'icon': Icons.assignment_turned_in_rounded},
    {'title': 'Resumen del Lab', 'icon': Icons.dashboard_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_tabs.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

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
                      key: ValueKey('tv_tab_$index'),
                      focusNode: _focusNodes[index],
                      title: tab['title'],
                      icon: tab['icon'],
                      isSelected: isSelected,
                      onPressed: () {
                        widget.onTabSelected(index);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Sesión de TV vinculada (si existe)
          if (TvAuthSession.isPaired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    TvAuthSession.pairedUser?['name'] ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
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
  final FocusNode focusNode;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TvTabButton({
    super.key,
    required this.focusNode,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<_TvTabButton> createState() => _TvTabButtonState();
}

class _TvTabButtonState extends State<_TvTabButton> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    _isFocused = widget.focusNode.hasFocus;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter ||
              key == LogicalKeyboardKey.select ||
              key == LogicalKeyboardKey.space) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          widget.focusNode.requestFocus();
          widget.onPressed();
        },
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
