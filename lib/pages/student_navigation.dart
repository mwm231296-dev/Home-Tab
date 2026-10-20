import 'package:flutter/material.dart';

class StudentDrawer extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const StudentDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 48),
                SizedBox(height: 12),
                Text('Manajemen Mahasiswa'),
              ],
            ),
          ),
          for (var i = 0; i < 2; i++)
            ListTile(
              selected: selected == i,
              leading: Icon(
                i == 0 ? Icons.people_outline : Icons.person_add_outlined,
              ),
              title: Text(i == 0 ? 'Daftar Mahasiswa' : 'Input Form Mahasiswa'),
              onTap: () {
                Navigator.pop(context);
                onSelect(i);
              },
            ),
        ],
      ),
    ),
  );
}

class StudentBottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const StudentBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selected,
    onDestinationSelected: onSelect,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Daftar Mahasiswa',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_add_outlined),
        selectedIcon: Icon(Icons.person_add),
        label: 'Input Mahasiswa',
      ),
    ],
  );
}
