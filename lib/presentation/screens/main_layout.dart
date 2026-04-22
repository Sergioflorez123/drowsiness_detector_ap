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
    return Scaffold(
      backgroundColor: const Color(0xFF030A1A),
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF06122A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1EE7FF).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00CFFF).withOpacity(0.14),
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
            ),
            _NavIconButton(
              icon: Icons.drive_eta_outlined,
              selected: navigationShell.currentIndex == 1,
              onTap: () => _goBranch(1),
            ),
            _NavIconButton(
              icon: Icons.map_outlined,
              selected: navigationShell.currentIndex == 2,
              onTap: () => _goBranch(2),
            ),
            _NavIconButton(
              icon: Icons.bar_chart_outlined,
              selected: navigationShell.currentIndex == 3,
              onTap: () => _goBranch(3),
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
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1EE7FF) : const Color(0xFF476781);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? const Color(0xFF0B203E) : Colors.transparent,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
