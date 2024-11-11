import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'data_base_helper.dart';

class DailyReportScreen extends StatefulWidget {
  final DateTime selectedDate;

  DailyReportScreen({required this.selectedDate});

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  Map<String, dynamic> _reportData = {
    'customerCount': 0,
    'totalAmount': 0.0,
    'totalMeals': 0,
    'detailedMeals': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchReportData(widget.selectedDate);
  }

  Future<void> _fetchReportData(DateTime date) async {
    final reportData = await DatabaseHelper().getDailyReport(date);
    setState(() {
      _reportData = reportData;
    });
  }

  @override
  void didUpdateWidget(DailyReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetchReportData(widget.selectedDate);
    }
  }

  Future<void> _printReport() async {
    try {
      final pdf = _generatePdf(widget.selectedDate);

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'Report (${widget.selectedDate.toLocal().toIso8601String().split('T')[0]}).pdf',
      );
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  pw.Document _generatePdf(DateTime date) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Daily Report for ${date.toLocal()}',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Number of Customers: ${_reportData['customerCount']}'),
              pw.Text(
                  'Total Amount: \$${_reportData['totalAmount'].toStringAsFixed(2)}'),
              pw.Text('Total Number of Meals: ${_reportData['totalMeals']}'),
              pw.SizedBox(height: 16),
              pw.Text('Meal Details:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ..._reportData['detailedMeals'].map<pw.Widget>((meal) {
                return pw.Text('${meal['name']}: ${meal['quantitySold']}');
              }).toList(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Report for ${widget.selectedDate.toLocal()}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Number of Customers: ${_reportData['customerCount']}'),
          Text(
              'Total Amount: \$${_reportData['totalAmount'].toStringAsFixed(2)}'),
          Text('Total Number of Meals: ${_reportData['totalMeals']}'),
          SizedBox(height: 16),
          Text('Meal Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._reportData['detailedMeals'].map<Widget>((meal) {
            return Text('${meal['name']}: ${meal['quantitySold']}');
          }).toList(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _printReport,
            child: Text('Print Report'),
          ),
        ],
      ),
    );
  }
}
