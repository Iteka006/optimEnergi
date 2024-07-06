import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> usageData;

  ReportPage({required this.usageData});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/energy_usage_report.csv';
      final file = File(path);

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
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Report downloaded at $path"),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to download report: $e"),
          duration: Duration(seconds: 3),
        ),
      );
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

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/energy_usage_report.csv';
      final file = File(path);

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
      await file.writeAsString(csv);

      String username = 'itekanice@gmail.com';
      String password = 'mpqysqkcrkyuskxy'; // Add your email password

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Your Name')
        ..recipients.add(email)
        ..subject = 'Energy Usage Report'
        ..text = 'Please find the attached energy usage report.'
        ..attachments.add(FileAttachment(file));

      try {
        final sendReport = await send(message, smtpServer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Report sent to $email"),
            duration: Duration(seconds: 3),
          ),
        );
      } on MailerException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send report: $e"),
            duration: Duration(seconds: 3),
          ),
        );
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to prepare report for sending: $e"),
          duration: Duration(seconds: 3),
        ),
      );
    }
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
        child: Column(
          children: [
            Text(
              'Date: ${_selectedDateData!['date'].month}/${_selectedDateData!['date'].day}/${_selectedDateData!['date'].year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'kWh Used: ${_selectedDateData!['kwh'].toStringAsFixed(2)} kWh',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Condition: ${_selectedDateData!['condition']}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Energy Usage Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.download),
                  label: Text("Download"),
                  onPressed: () => _downloadReport(context),
                ),
                TextButton.icon(
                  icon: Icon(Icons.email),
                  label: Text("Email"),
                  onPressed: () => _showEmailDialog(context),
                ),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text("Search"),
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
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }
}
