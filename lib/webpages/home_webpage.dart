import 'package:admin_mysiswa2/webpages/appointment_webpage.dart';
import 'package:admin_mysiswa2/webpages/history_webpage.dart';
import 'package:admin_mysiswa2/webpages/login_webpage.dart';
import 'package:admin_mysiswa2/webpages/overview_webpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeWebPage extends StatefulWidget {
  @override
  _HomeWebPageState createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AppointmentWebpage(),
    HistoryWebpage(),
    OverviewWebpage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAllAppointments(); // Check all appointments on init
  }

  // Method to check all appointments in the bookings collection
  Future<void> _checkAllAppointments() async {
    final now = DateTime.now();

    print("Starting to check all appointments...");
    print("Current Time (with timezone): $now (timezone: ${now.timeZoneName})");

    QuerySnapshot bookingsSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();

    for (var doc in bookingsSnapshot.docs) {
      DateTime endTime = (doc['endTime'] as Timestamp).toDate(); // Get the endTime from Firestore
      String status = doc['status'];

      print("Appointment ID: ${doc.id}");
      print("End Time (with timezone): $endTime (timezone: ${endTime.timeZoneName})");
      print("Current Status: $status");

      // Check if the current time is after the end time
      if (now.isAfter(endTime)) {
        if (status == 'scheduled') {
          // Update status to 'missed' only if the appointment is still 'scheduled'
          print("Changing status of appointment ${doc.id} to 'missed'...");
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(doc.id)
              .update({
            'status': 'missed',
          });
          print("Status changed to 'missed' for appointment ${doc.id}.");
        } else {
          print("Appointment ${doc.id} already has status: $status.");
        }
      } else {
        print("Appointment ${doc.id} is still ongoing or scheduled for the future.");
      }
    }

    print("Completed checking all appointments.");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const LoginWebPage()), // Navigate directly to LoginWebPage
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/logo.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'SiswaCard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Appointment'),
                  selected: _selectedIndex == 0, // Highlight if selected
                  selectedTileColor:
                      Colors.grey[300], // Background color when selected
                  onTap: () => _onItemTapped(0),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('History'),
                  selected: _selectedIndex == 1, // Highlight if selected
                  selectedTileColor:
                      Colors.grey[300], // Background color when selected
                  onTap: () => _onItemTapped(1),
                ),
                ListTile(
                  leading: const Icon(Icons.stacked_bar_chart),
                  title: const Text('Overview'),
                  selected: _selectedIndex == 2, // Highlight if selected
                  selectedTileColor:
                      Colors.grey[300], // Background color when selected
                  onTap: () => _onItemTapped(2),
                ),
              ],
            ),
          ),
          // Logout button at the bottom of the drawer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Reduce curve
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
            ),
            body: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: _buildDrawer(),
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
            ),
            body: _pages[_selectedIndex],
            drawer: _buildDrawer(),
          );
        }
      },
    );
  }
}
