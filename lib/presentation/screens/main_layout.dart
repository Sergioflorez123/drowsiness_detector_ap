import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030A1A) : const Color(0xFFEFF7FF),
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF06122A) : const Color(0xFFDDF0FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isDark ? const Color(0xFF1EE7FF) : const Color(0xFF008DBD))
                .withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF00CFFF) : const Color(0xFF00A4D6))
                  .withOpacity(0.14),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            _NavIconButton(
              icon: Icons.remove_red_eye_outlined,
              selected: navigationShell.currentIndex == 0,
              onTap: () => _goBranch(0),
              isDark: isDark,
            ),
            _NavIconButton(
              icon: Icons.drive_eta_outlined,
              selected: navigationShell.currentIndex == 1,
              onTap: () => _goBranch(1),
              isDark: isDark,
            ),
            _NavIconButton(
              icon: Icons.map_outlined,
              selected: navigationShell.currentIndex == 2,
              onTap: () => _goBranch(2),
              isDark: isDark,
            ),
            _NavIconButton(
              icon: Icons.bar_chart_outlined,
              selected: navigationShell.currentIndex == 3,
              onTap: () => _goBranch(3),
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (isDark ? const Color(0xFF1EE7FF) : const Color(0xFF006A8F))
        : (isDark ? const Color(0xFF476781) : const Color(0xFF5F87A1));
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? (isDark ? const Color(0xFF0B203E) : const Color(0xFFC4E7FF))
                : Colors.transparent,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
