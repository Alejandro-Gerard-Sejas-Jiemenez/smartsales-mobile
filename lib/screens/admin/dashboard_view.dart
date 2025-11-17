import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/common/custom_app_bar.dart';
// Prediction card removed for top-products (not used)
import '../../models/category.dart';
import '../../utils/app_colors.dart';

class DashboardView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Category> categories;
  final int? selectedCategoryId;
  final int selectedPeriodMonths;
  final Map<String, dynamic>? predictionData;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onPeriodChanged;
  final VoidCallback onRetry;

  const DashboardView({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedPeriodMonths,
    required this.predictionData,
    required this.onCategoryChanged,
    required this.onPeriodChanged,
    required this.onRetry,
  }) : super(key: key);

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
    final trendData = (predictionData?['trend_data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final barSeries = (predictionData?['bar_series'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(title: 'Dashboard', showBackButton: false),
      body: isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
          : error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Error al cargar predicciones', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Text(error ?? '', style: TextStyle(color: AppColors.textSecondary)),
                    SizedBox(height: 8),
                    TextButton(onPressed: onRetry, child: Text('Reintentar'))
                  ]))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Predicciones de Ventas', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: 12),

                    Card(
                      elevation: 2,
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(children: [
                          Expanded(
                            child: DropdownButton<int?>(
                              value: selectedCategoryId,
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              items: [DropdownMenuItem<int?>(value: null, child: Text('Todas las categorías'))]
                                  .followedBy(categories.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.nombre))))
                                  .toList(),
                              onChanged: onCategoryChanged,
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(width: 1, height: 36, color: AppColors.border),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButton<int>(
                              value: selectedPeriodMonths,
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              items: [1, 3, 6, 12].map((m) => DropdownMenuItem(value: m, child: Text('Próx. $m m'))).toList(),
                              onChanged: onPeriodChanged,
                            ),
                          ),
                        ]),
                      ),
                    ),

                    SizedBox(height: 14),

                    // Banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.info.withOpacity(0.9)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Total Predicho', style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 6),
                            Text(formatCurrency(predictionData?['expected_sales'] ?? 0), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text('Para: ${categories.firstWhere((c) => c.id == selectedCategoryId, orElse: () => Category(id: 0, nombre: 'Todas', estado: true)).nombre}', style: TextStyle(color: Colors.white70)),
                          ]),
                        ),
                        SizedBox(width: 12),
                        SizedBox(width: 56, child: Center(child: Icon(Icons.show_chart, color: Colors.white30, size: 36))),
                      ]),
                    ),

                    SizedBox(height: 14),

                    // Cards placeholder (removed Productos Top card)
                    SizedBox.shrink(),

                    SizedBox(height: 20),

                    // Productos top list removed (not used)

                    // Line chart
                    Container(
                      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                      padding: EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Tendencia de Ventas', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
                        SizedBox(height: 14),
                        SizedBox(
                          height: 200,
                          child: LineChart(LineChartData(gridData: FlGridData(show: false), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [
                            LineChartBarData(
                              spots: trendData.map<FlSpot>((point) => FlSpot((point['x'] as num).toDouble(), (point['y'] as num).toDouble())).toList(),
                              isCurved: true,
                              color: AppColors.chartLine,
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: AppColors.chartLine.withOpacity(0.08)),
                            )
                          ])),
                        ),
                      ]),
                    ),

                    SizedBox(height: 16),

                    // Bar chart + values
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Predicción de Ventas (Barras)', style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            child: Builder(builder: (context) {
                              final List<Map<String, dynamic>> bars = barSeries;
                              if (bars.isEmpty) return Center(child: Text('No hay datos'));
                              final maxVal = bars.map((b) => (b['value'] as num).toDouble()).fold<double>(0.0, (p, n) => n > p ? n : p);
                              final groups = List.generate(bars.length, (i) {
                                final val = (bars[i]['value'] as num).toDouble();
                                return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: val, color: AppColors.chartLine, width: 18)]);
                              });

                              String bottomTitle(int index) => bars[index]['name'] as String;

                              return BarChart(BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (maxVal * 1.2).clamp(10, double.infinity),
                                barGroups: groups,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= bars.length) return SizedBox.shrink();
                                    if (idx == 0 || idx == bars.length - 1 || idx == (bars.length / 2).floor()) {
                                      return Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(bottomTitle(idx), style: TextStyle(fontSize: 12)));
                                    }
                                    return SizedBox.shrink();
                                  })),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: false),
                              ));
                            }),
                          ),
                          SizedBox(height: 10),
                          // values list
                          Builder(builder: (context) {
                            final List<Map<String, dynamic>> bars = barSeries;
                            if (bars.isEmpty) return SizedBox.shrink();
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: bars.map((b) {
                                final name = b['name'] as String;
                                final amount = (b['value'] as num).toDouble();
                                return Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(height: 4), Text(formatCurrency(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))]),
                                );
                              }).toList()),
                            );
                          }),
                        ]),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Tendencias Históricas (Barras agrupadas: Count + Monto)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Tendencias Históricas (Últimos meses)', style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 260,
                            child: Builder(builder: (context) {
                              final List<Map<String, dynamic>> bars = barSeries;
                              if (bars.isEmpty) return Center(child: Text('No hay datos'));
                              final counts = bars.map((b) => (b['count'] as num).toDouble()).toList();
                              final amounts = bars.map((b) => (b['value'] as num).toDouble()).toList();
                              final maxCount = counts.fold<double>(0.0, (p, n) => n > p ? n : p);
                              final maxAmount = amounts.fold<double>(0.0, (p, n) => n > p ? n : p);
                              final scale = maxAmount > 0 ? (maxAmount / (maxCount > 0 ? maxCount : 1)) : 1.0;
                              final groups = List.generate(bars.length, (i) {
                                final c = counts[i];
                                final a = amounts[i] / (scale == 0 ? 1 : scale);
                                return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: c, width: 10, color: AppColors.chartLine), BarChartRodData(toY: a, width: 10, color: AppColors.accent)], barsSpace: 6);
                              });

                              String bottomTitle(int index) => bars[index]['name'] as String;

                              final maxCombined = [...counts, ...amounts.map((a) => a / (scale == 0 ? 1 : scale))].fold<double>(0.0, (p, n) => n > p ? n : p);
                              final chartMax = (maxCombined * 1.2).clamp(1, double.infinity);

                              return Column(children: [
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: chartMax.toDouble(),
                                      barGroups: groups,
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                                          final idx = v.toInt();
                                          if (idx < 0 || idx >= bars.length) return SizedBox.shrink();
                                          if (idx == 0 || idx == bars.length - 1 || idx == (bars.length / 2).floor()) {
                                            return Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(bottomTitle(idx), style: TextStyle(fontSize: 12)));
                                          }
                                          return SizedBox.shrink();
                                        })),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      gridData: FlGridData(show: false),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 6, children: [
                                  Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 12, height: 12, color: AppColors.chartLine), SizedBox(width: 6), Text('Cantidad de predicciones', style: TextStyle(fontSize: 12))]),
                                  Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 12, height: 12, color: AppColors.accent), SizedBox(width: 6), Text('Monto (normalizado)', style: TextStyle(fontSize: 12))])
                                ])
                              ]);
                            }),
                          )
                        ]),
                      ),
                    ),
                  ]),
                ),
    );
  }
}
