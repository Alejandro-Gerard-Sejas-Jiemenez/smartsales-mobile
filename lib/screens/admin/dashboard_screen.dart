import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import '../../services/prediction_service.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
// Reverted VentaService/top product integration per user request

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _predictionService = PredictionService();
  final _categoryService = CategoryService();
  // VentaService usage removed

  bool _isLoading = true;
  String? _error;

  List<Category> _categories = [];
  int? _selectedCategoryId; // null = todas
  int _selectedPeriodMonths = 3;

  Map<String, dynamic>? _predictionData;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _loadCategories();
    await _loadPredictions();
  }

  Future<void> _loadCategories() async {
    try {
      final List<Category> raw = await _categoryService.getCategories();
      setState(() => _categories = raw);
    } catch (e) {
      print('CategoryService: error fetching categories: $e');
    }
  }

  double _parseVenta(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    try {
      return double.parse(v.toString());
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> _loadPredictions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final List<dynamic> list = await _predictionService.getPredictions(categoriaId: _selectedCategoryId);

      // DEBUG: imprimir resumen y algunas claves de los objetos recibidos para diagnosticar por qué
      // no se detectan productos en las predicciones.
      try {
        print('Dashboard: received predictions count=${list.length}');
        final int sample = list.length >= 3 ? 3 : list.length;
        for (int i = 0; i < sample; i++) {
          final item = list[i];
          if (item is Map) {
            print('Dashboard: pred[$i] keys=${item.keys.toList()}');
            if (item.containsKey('producto') || item.containsKey('producto_nombre') || item.containsKey('producto_name')) {
              final probe = item['producto'] ?? item['producto_nombre'] ?? item['producto_name'];
              print('Dashboard: pred[$i] producto probe=$probe');
            }
          } else {
            print('Dashboard: pred[$i] is not Map: ${item.runtimeType}');
          }
        }
      } catch (e) {
        print('Dashboard: debug print failed: $e');
      }

      final Map<String, Map<String, dynamic>> grouped = {};
      for (final item in list) {
        if (item is! Map) continue;
        DateTime dt;
        try {
          dt = DateTime.parse(item['periodo_inicio']?.toString() ?? DateTime.now().toIso8601String());
        } catch (_) {
          dt = DateTime.now();
        }
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        final venta = _parseVenta(item['venta_predicha']);
        if (!grouped.containsKey(key)) {
          grouped[key] = {'name': '${_shortMonth(dt.month)} ${dt.year}', 'venta': 0.0, 'count': 0};
        }
        grouped[key]!['venta'] = (grouped[key]!['venta'] as double) + venta;
        grouped[key]!['count'] = (grouped[key]!['count'] as int) + 1;
      }

      final chartData = grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final visible = chartData.reversed.take(_selectedPeriodMonths).toList().reversed.toList();

      double expectedSales = 0.0;
      final List<Map<String, dynamic>> trend = [];
      final List<Map<String, dynamic>> barSeries = [];
      // calcular top products (si la respuesta contiene producto/producto_nombre)
      final Map<String, Map<String, dynamic>> productStats = {};
      int itemsWithProduct = 0;
      for (final item in list) {
        if (item is! Map) continue;
        // extraer nombre/id del producto probando múltiples rutas posibles
        String prodName = '';

        // casos comunes
        if (item.containsKey('producto_nombre')) prodName = (item['producto_nombre'] ?? '').toString();
        if (prodName.isEmpty && item.containsKey('producto_name')) prodName = (item['producto_name'] ?? '').toString();
        // producto puede venir como id o objeto
        if (prodName.isEmpty && item.containsKey('producto')) {
          final p = item['producto'];
          if (p is Map) {
            prodName = (p['nombre'] ?? p['name'] ?? p['titulo'] ?? '').toString();
          } else if (p != null) {
            prodName = p.toString();
          }
        }
        // otros campos posibles
        if (prodName.isEmpty && item.containsKey('producto_id')) prodName = (item['producto_id'] ?? '').toString();
        if (prodName.isEmpty && item.containsKey('producto_nombre_html')) prodName = (item['producto_nombre_html'] ?? '').toString();

        if (prodName.isEmpty) continue; // no hay info de producto en este item

        itemsWithProduct += 1;
        final venta = _parseVenta(item['venta_predicha']);
        productStats.putIfAbsent(prodName, () => {'name': prodName, 'value': 0.0, 'count': 0});
        productStats[prodName]!['value'] = (productStats[prodName]!['value'] as double) + venta;
        productStats[prodName]!['count'] = (productStats[prodName]!['count'] as int) + 1;
      }

      // ordenar y tomar top 5
      final topProductsList = productStats.values.toList();
      topProductsList.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
      final topProducts = topProductsList.take(5).map((m) => {'name': m['name'], 'predicted_sales': m['value'], 'count': m['count']}).toList();

      print('Dashboard: itemsWithProduct=$itemsWithProduct, totalPredictions=${list.length}, topProducts=${topProducts.length}');

  // Use client-side computed topProducts (server call was reverted)
      for (int i = 0; i < visible.length; i++) {
        final v = (visible[i].value['venta'] as double);
        expectedSales += v;
        trend.add({'x': i.toDouble(), 'y': v});
        barSeries.add({'name': visible[i].value['name'] as String, 'value': v, 'count': visible[i].value['count'] as int});
      }

      setState(() {
        _predictionData = {
          'expected_sales': expectedSales,
          'sales_growth': 0.0,
          'top_products_count': topProducts.length,
          'products_growth': 0.0,
          'trend_data': trend,
          'bar_series': barSeries,
          'top_products': topProducts,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _shortMonth(int month) {
    const names = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    if (month < 1 || month > 12) return '';
    return names[month];
  }

  // selected category name is resolved in the view; keep minimal state here.

  String formatCurrency(dynamic value) {
    double v = 0.0;
    if (value == null) return 'Bs. 0.00';
    if (value is num) v = value.toDouble();
    else {
      try {
        v = double.parse(value.toString());
      } catch (_) {
        v = 0.0;
      }
    }
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';
    final withSep = intPart.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return 'Bs. $withSep.$decPart';
  }

  @override
  Widget build(BuildContext context) {
    return DashboardView(
      isLoading: _isLoading,
      error: _error,
      categories: _categories,
      selectedCategoryId: _selectedCategoryId,
      selectedPeriodMonths: _selectedPeriodMonths,
      predictionData: _predictionData,
      onCategoryChanged: (v) {
        setState(() => _selectedCategoryId = v);
        _loadPredictions();
      },
      onPeriodChanged: (v) {
        if (v == null) return;
        setState(() => _selectedPeriodMonths = v);
        _loadPredictions();
      },
      onRetry: _loadPredictions,
    );
  }
}