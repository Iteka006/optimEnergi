import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CarbonFootprintPage extends StatelessWidget {
  final List<Map<String, dynamic>> usageData;

  CarbonFootprintPage({required this.usageData});

  double calculateDailyCarbonFootprint(double dailyKwh) {
    const double carbonFactor = 0.92; // kg CO2 per kWh
    return dailyKwh * carbonFactor;
  }

  double calculateMonthlyCarbonFootprint() {
    double totalKwh = 0;
    for (var data in usageData) {
      totalKwh += data['kwh'];
    }
    return calculateDailyCarbonFootprint(totalKwh);
  }

  Future<void> _launchURL() async {
    const url = 'https://www.nature.org/en-us/get-involved/how-to-help/carbon-footprint-calculator/';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      print('Could not launch $url');
      // Optionally, show a dialog or message to the user indicating the error.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find today's date
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    // Find the usage data for today's date
    var todayData = usageData.firstWhere(
      (data) {
        DateTime dataDate = data['date'];
        return dataDate.year == todayDate.year &&
            dataDate.month == todayDate.month &&
            dataDate.day == todayDate.day;
      },
      orElse: () => {}, // Return an empty map if no data is found
    );

    double dailyCarbonFootprint = todayData.isNotEmpty
        ? calculateDailyCarbonFootprint(todayData['kwh'])
        : 0.0;

    // Define a threshold for a good carbon footprint
    const double carbonFootprintThreshold = 20.0; // Example threshold in kg CO2

    // Determine if the footprint is okay or needs improvement
    bool isFootprintOkay = dailyCarbonFootprint <= carbonFootprintThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint'),
      ),
      body: Container(
        color: Color.fromRGBO(244, 244, 244, 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/carbon_footprint.jpg', // Replace with your image path
                    height: 150,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Daily Carbon Footprint:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (todayData.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text(
                    '${todayData['date'].toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${dailyCarbonFootprint.toStringAsFixed(2)} kg CO2',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No data available for today\'s date.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Monthly Carbon Footprint:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                  'Monthly Total',
                  style: const TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  '${calculateMonthlyCarbonFootprint().toStringAsFixed(2)} kg CO2',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Monitoring your carbon footprint helps you understand the environmental impact of your energy usage and encourages you to adopt more sustainable habits. ',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _launchURL,
                                  child: Text(
                                    'Learn more.',
                                    style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
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
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      isFootprintOkay ? Icons.check_circle : Icons.warning,
                      color: isFootprintOkay ? Colors.green : Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isFootprintOkay
                          ? 'Your carbon footprint is within acceptable limits.'
                          : 'You need to reduce your energy usage.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFootprintOkay ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
