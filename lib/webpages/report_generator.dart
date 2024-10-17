import 'dart:html' as html; // Add this import for web functionality
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = false;

  // Method to fetch appointments from Firestore based on selected date range
  Future<void> _fetchAppointments() async {
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both from and to dates.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('date', isGreaterThanOrEqualTo: _fromDate)
          .where('date', isLessThanOrEqualTo: _toDate)
          .get();

      List<Map<String, dynamic>> fetchedAppointments =
          querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime date = (data['date'] as Timestamp).toDate();
        return {
          'name': data['name'] ?? 'Unknown',
          'studentId': data['studentId'] ?? 'Unknown',
          'faculty': data['faculty'] ?? 'Unknown',
          'date': DateFormat('dd/MM/yyyy').format(date),
          'purpose': data['purpose'] ?? 'Unknown',
          'status': data['status'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _appointments = fetchedAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching appointments: $e')),
      );
    }
  }

  // Method to select date for "From" and "To" separately
  Future<void> _selectDate({required bool isFromDate}) async {
    DateTime initialDate = isFromDate
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = pickedDate;
        } else {
          _toDate = pickedDate;
        }
      });
      // Fetch appointments after date is selected
      _fetchAppointments();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Method to generate and download PDF
  Future<void> _generateAndDownloadPdf() async {
    if (_appointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No appointments available to generate a report.')),
      );
      return; // Exit early
    }

    final pdf = pw.Document();

    // Load the font
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MySiswa Card Appointment Report',
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'From: ${_formatDate(_fromDate)}  To: ${_formatDate(_toDate)}',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  pw.Text('NO', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('NAME', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('STUDENT ID', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('DATE', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('PURPOSE', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('STATUS', style: const pw.TextStyle(fontSize: 9)),
                ],
                data: _appointments.asMap().entries.map((entry) {
                  int index = entry.key; // Get index
                  var appointment = entry.value; // Get the appointment
                  return [
                    pw.Text((index + 1).toString(),
                        style: const pw.TextStyle(fontSize: 9)), // Row number
                    pw.Text(appointment['name'],
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(appointment['studentId'],
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(appointment['date'],
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(appointment['purpose'],
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(appointment['status'],
                        style: const pw.TextStyle(fontSize: 9)),
                  ];
                }).toList(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30), // NO column fixed width
                  1: const pw.FixedColumnWidth(150), // NAME column fixed width
                  2: const pw.FixedColumnWidth(70),  // STUDENT ID fixed width
                  3: const pw.FixedColumnWidth(50),  // DATE fixed width
                  4: const pw.FixedColumnWidth(70), // PURPOSE fixed width
                  5: const pw.FixedColumnWidth(60),  // STATUS fixed width
                },
              ),
            ],
          );
        },
      ),
    );

    // Save PDF file
    final pdfBytes = await pdf.save();

    // Use dart:html to download the PDF
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'appointment_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Pickers for "From" and "To"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // From Date Picker
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(isFromDate: true),
                    icon: const Icon(Icons.date_range),
                    label: Text('From: ${_formatDate(_fromDate)}'),
                  ),
                ),
                const SizedBox(width: 20),
                // To Date Picker
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(isFromDate: false),
                    icon: const Icon(Icons.date_range),
                    label: Text('To: ${_formatDate(_toDate)}'),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _generateAndDownloadPdf,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text('Generate PDF',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Data Table
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Align(
                      alignment: Alignment.topCenter, // Align to top center
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('STUDENT ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('PURPOSE', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _appointments.map((appointment) {
                            return DataRow(cells: [
                              DataCell(Text(appointment['name'])),
                              DataCell(Text(appointment['studentId'])),
                              DataCell(Text(appointment['date'])),
                              DataCell(Text(appointment['purpose'])),
                              DataCell(Text(appointment['status'])),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
