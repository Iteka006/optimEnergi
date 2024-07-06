import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictiveAnalyticsPage extends StatefulWidget {
  final List<Map<String, dynamic>> usageData;

  PredictiveAnalyticsPage({required this.usageData});

  @override
  _PredictiveAnalyticsPageState createState() => _PredictiveAnalyticsPageState();
}

class _PredictiveAnalyticsPageState extends State<PredictiveAnalyticsPage> {
  List<BarChartGroupData> _actualDataGroups = [];
  List<BarChartGroupData> _predictedDataGroups = [];
  double _predictedCost = 0.0;
  double _predictedKWh = 0.0;
  final double _ratePerKWh = 227.5; // Assuming Rwf 227.5 per KWh

  @override
  void initState() {
    super.initState();
    _generatePredictions();
  }

  void _generatePredictions() {
    if (widget.usageData.isEmpty) return;

    // Prepare data for linear regression
    List<double> x = [];
    List<double> y = [];
    for (int i = 0; i < widget.usageData.length; i++) {
      x.add(i.toDouble());
      y.add(widget.usageData[i]['kwh']);
    }

    // Perform linear regression
    double n = x.length.toDouble();
    double sumX = x.reduce((a, b) => a + b);
    double sumY = y.reduce((a, b) => a + b);
    double sumXY = 0.0;
    double sumXX = 0.0;

    for (int i = 0; i < n; i++) {
      sumXY += x[i] * y[i];
      sumXX += x[i] * x[i];
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // Predict for the next 6 months
    for (int i = 0; i < 6; i++) {
      double predictedUsage = slope * (x.length + i) + intercept;
      _predictedDataGroups.add(
        BarChartGroupData(
          x: x.length + i,
          barRods: [
            BarChartRodData(
              toY: predictedUsage,
              color: Colors.red,
              width: 20, // Adjust the width to make bars more readable
            ),
          ],
        ),
      );
      _predictedKWh += predictedUsage;
      _predictedCost += predictedUsage * _ratePerKWh; // Calculating cost in Rwf
    }

    // Prepare actual data points
    for (int i = 0; i < x.length; i++) {
      _actualDataGroups.add(
        BarChartGroupData(
          x: x[i].toInt(),
          barRods: [
            BarChartRodData(
              toY: y[i],
              color: Colors.blue,
              width: 20, // Adjust the width to make bars more readable
            ),
          ],
        ),
      );
    }
  }

  List<String> _getMonthLabels() {
    DateTime now = DateTime.now();
    List<String> labels = [];
    for (int i = 0; i < _actualDataGroups.length + _predictedDataGroups.length; i++) {
      DateTime date = now.add(Duration(days: 30 * i));
      labels.add('${date.month}/${date.year}');
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Analytics'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Real-Time Energy'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/real-time-energy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/report');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Predictive Analytics'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/predictive-analytics');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 2,
                  child: BarChart(
                    BarChartData(
                      barGroups: _actualDataGroups + _predictedDataGroups,
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60, // Increase space for Y axis labels
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${value.toInt()} kWh',
                                  style: TextStyle(fontSize: 10), // Adjust font size
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hide right titles
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hide top titles
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              List<String> monthLabels = _getMonthLabels();
                              if (value.toInt() < monthLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    monthLabels[value.toInt()],
                                    style: TextStyle(fontSize: 12), // Adjust font size
                                  ),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(Icons.power, color: Colors.blue),
                title: Text(
                  'Predicted Energy Usage for Next Month',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${_predictedKWh.toStringAsFixed(2)} kWh',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ),
            Card(
              color: Colors.red.shade50,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(Icons.attach_money, color: Colors.red),
                title: Text(
                  'Predicted Cost for Next Month',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${_predictedCost.toStringAsFixed(2)} Rwf',
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
