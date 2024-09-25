import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentWebpage extends StatefulWidget {
  const AppointmentWebpage({super.key});

  @override
  State<AppointmentWebpage> createState() => _AppointmentWebpageState();
}

class _AppointmentWebpageState extends State<AppointmentWebpage> {
  Future<List<Map<String, dynamic>>> fetchBookingData() async {
    List<Map<String, dynamic>> combinedData = [];

    QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: ['scheduled', 'in-progress'])
        .get();

    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;

      final date = (bookingData['date'] as Timestamp).toDate();
      final formattedDate = date.toLocal().toString().split(' ')[0];
      final timeSlot = bookingData['timeSlot'] ?? 'N/A';

      combinedData.add({
        'name': bookingData['name'] ?? 'No Name', // Directly use name from booking
        'phone_number': bookingData['phoneNumber'] ?? 'No Phone Number', // Directly use phone number
        'dateTime': date, // Store the date as DateTime for sorting
        'dateTimeSlot': '$formattedDate\n$timeSlot',
        'status': bookingData['status'] ?? 'scheduled',
        'bookingId': doc.id,
      });
    }

    // Sort the combinedData list by dateTime in ascending order
    combinedData.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));

    return combinedData;
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String action,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this appointment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm(); // Execute the action
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(String bookingId) async {
    _showConfirmationDialog(
      context: context,
      action: 'cancel',
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .update({'status': 'canceled by admin'});

          // Refresh the page after canceling
          setState(() {});
        } catch (e) {
          print('Error canceling appointment: $e');
        }
      },
    );
  }

  void _completeAppointment(String bookingId) async {
    _showConfirmationDialog(
      context: context,
      action: 'complete',
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .update({'status': 'completed'});

          // Refresh the page after marking as completed
          setState(() {});
        } catch (e) {
          print('Error completing appointment: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A P P O I N T M E N T       M A N A G E M E N T'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchBookingData(),  // Using simplified method
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No Appointments Found'));
                      }

                      List<Map<String, dynamic>> bookingsData = snapshot.data!;

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(50),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(),
                            3: FlexColumnWidth(),
                            4: FlexColumnWidth(),
                            5: FlexColumnWidth(),
                          },
                          border: TableBorder.all(color: Colors.grey, width: 1),
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'NO.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'STUDENT NAME',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'DATE & TIME',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'PHONE NUMBER',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'STATUS',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'ACTION',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            for (int index = 0; index < bookingsData.length; index++)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('${index + 1}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(bookingsData[index]['name']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(bookingsData[index]['dateTimeSlot']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(bookingsData[index]['phone_number']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(bookingsData[index]['status']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _cancelAppointment(
                                              bookingsData[index]['bookingId']),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              )),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () => _completeAppointment(
                                              bookingsData[index]['bookingId']),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              )),
                                          child: const Text(
                                            'Completed',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
