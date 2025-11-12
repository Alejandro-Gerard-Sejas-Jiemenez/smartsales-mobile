import 'package:flutter/material.dart';
import '../screens/admin/dashboard_screen.dart';
import '../utils/app_colors.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  
  const AdminLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSales 365 - Admin'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implementar logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: const Text(
                'Panel de Administración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Gestión de Ventas'),
              onTap: () {
                // TODO: Implementar navegación a gestión de ventas
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Gestión de Productos'),
              onTap: () {
                // TODO: Implementar navegación a gestión de productos
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Análisis de Ventas'),
              onTap: () {
                // TODO: Implementar navegación a análisis de ventas
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}