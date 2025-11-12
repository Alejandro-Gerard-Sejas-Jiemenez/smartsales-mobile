import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/common/custom_app_bar.dart';
import '../../components/dashboard/prediction_card.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _predictionService = PredictionService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _predictionData;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    try {
      setState(() => _isLoading = true);
      final data = await _predictionService.getMockPredictions(); // Using mock data for testing
      setState(() {
        _predictionData = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error al cargar predicciones',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadPredictions,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predicciones de Ventas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Tarjetas de predicción
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          PredictionCard(
                            title: 'Ventas Esperadas',
                            value: 'Bs. ${_predictionData?['expected_sales'] ?? 0}',
                            percentage: _predictionData?['sales_growth'] ?? 0,
                            icon: Icons.trending_up,
                            isPositive: true,
                          ),
                          PredictionCard(
                            title: 'Productos Top',
                            value: '${_predictionData?['top_products_count'] ?? 0}',
                            percentage: _predictionData?['products_growth'] ?? 0,
                            icon: Icons.star_outline,
                            isPositive: true,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Gráfico de tendencias
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tendencia de Ventas',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(show: true),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _predictionData?['trend_data']
                                            ?.map<FlSpot>((point) => FlSpot(
                                                point['x'].toDouble(),
                                                point['y'].toDouble()))
                                            ?.toList() ??
                                            [],
                                        isCurved: true,
                                        color: AppColors.chartLine,
                                        barWidth: 2,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color:
                                              AppColors.chartLine.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}