import 'package:flutter/material.dart';
import 'notification_manager.dart';

class BudgetSetPage extends StatefulWidget {
  final double remainingEnergy;

  BudgetSetPage({required this.remainingEnergy});

  @override
  _BudgetSetPageState createState() => _BudgetSetPageState();
}

class _BudgetSetPageState extends State<BudgetSetPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalBudget;

  @override
  void initState() {
    super.initState();
    _budgetController.text = widget.remainingEnergy.toStringAsFixed(2);
    _totalBudget = widget.remainingEnergy;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (controller == _startDateController) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        controller.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _setBudget() {
    if (_startDate != null && _endDate != null && _totalBudget != null) {
      final int days = _endDate!.difference(_startDate!).inDays + 1;
      final double dailyBudget = _totalBudget! / days;
      NotificationManager.setDailyBudget(dailyBudget);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Budget set successfully: $dailyBudget kWh/day'),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 0.9),
      appBar: AppBar(
        title: Text('Set Budget'),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Set Budget',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _startDateController,
                      labelText: 'Start Date',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context, _startDateController),
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _endDateController,
                      labelText: 'End Date',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context, _endDateController),
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _budgetController,
                      labelText: 'Total Budget (kWh)',
                      icon: Icons.bolt,
                      readOnly: true,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _setBudget,
                          child: Text(
                            'Set Budget',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Center(
      child: Container(
        width: 600,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon, color: Colors.red),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          readOnly: readOnly,
          onTap: onTap,
        ),
      ),
    );
  }
}
