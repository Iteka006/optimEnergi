import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:js' as js;

class ReportPageWeb extends StatefulWidget {
  final List<Map<String, dynamic>> usageData;

  ReportPageWeb({required this.usageData});

  @override
  _ReportPageWebState createState() => _ReportPageWebState();
}

class _ReportPageWebState extends State<ReportPageWeb> {
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _fetchedUsageData = [];
  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedDateData;

  @override
  void initState() {
    super.initState();
    _fetchedUsageData = widget.usageData;
    _fetchUsageData();
  }

  Future<void> _fetchUsageData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('energyUsage').get();
      setState(() {
        _fetchedUsageData = querySnapshot.docs.map((doc) {
          DateTime date = (doc['date'] as Timestamp).toDate();
          return {
            'date': date,
            'kwh': doc['kwh'],
            'condition': doc['condition']
          };
        }).toList();
        _fetchedUsageData.sort((a, b) => b['date'].compareTo(a['date']));
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }
  

Future<void> _sendReportByEmail(BuildContext context) async {
  final email = _emailController.text;
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please enter an email address"),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Construct CSV data
  List<List<dynamic>> rows = [
    ["Date", "kWh Used", "Condition"]
  ];
  for (var data in _fetchedUsageData) {
    List<dynamic> row = [];
    row.add('${data['date'].month}/${data['date'].day}/${data['date'].year}');
    row.add(data['kwh'].toStringAsFixed(2));
    row.add(data['condition']);
    rows.add(row);
  }
  String csv = const ListToCsvConverter().convert(rows);

  // EmailJS send function call
  js.context.callMethod('sendEmail', [
    'Gmail', // Replace with your EmailJS service ID
    'service_gw4c24e', // Replace with your EmailJS template ID
    email, // Recipient email address
    'Please find the attached energy usage report.', // Email message body
    [
      {
        'name': 'energy_usage_report.csv',
        'type': 'text/csv',
        'data': csv,
      }
    ]
  ]);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Report sent to $email"),
      duration: Duration(seconds: 3),
    ),
  );
}


  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Send Report"),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: "Enter email address"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () {
                Navigator.of(context).pop();
                _sendReportByEmail(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedDateData = _fetchedUsageData.firstWhere(
            (data) =>
                data['date'].year == picked.year &&
                data['date'].month == picked.month &&
                data['date'].day == picked.day,
            orElse: () => {});
      });
    }
  }

  Widget _buildDataTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('kWh Used')),
        DataColumn(label: Text('Condition')),
      ],
      rows: List<DataRow>.generate(
        _fetchedUsageData.length,
        (index) {
          final data = _fetchedUsageData[index];
          return DataRow(
            cells: [
              DataCell(Text('${data['date'].month}/${data['date'].day}/${data['date'].year}')),
              DataCell(Text('${data['kwh'].toStringAsFixed(2)} kWh')),
              DataCell(Text(data['condition'])),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateData() {
    if (_selectedDateData == null || _selectedDateData!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No data available for the selected date.',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDataTable(), // Displaying the selected date data in the same format as the report
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Energy Usage Report',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.email, color: Colors.blue),
                    onPressed: () => _showEmailDialog(context),
                  ),
                  SizedBox(width: 8), // Small space between the icons
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ),
            _selectedDate != null
                ? _buildSelectedDateData()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Please select a date to view details.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDataTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}