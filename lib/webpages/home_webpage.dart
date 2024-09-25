import 'package:admin_mysiswa2/webpages/appointment_webpage.dart';
import 'package:admin_mysiswa2/webpages/history_webpage.dart';
import 'package:admin_mysiswa2/webpages/login_webpage.dart';
import 'package:admin_mysiswa2/webpages/overview_webpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeWebPage extends StatefulWidget {
  @override
  _HomeWebPageState createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage> {
  int _selectedIndex = 0;
  String? _username; // Variable to hold the username

  final List<Widget> _pages = [
    const AppointmentWebpage(),
    HistoryWebpage(),
    OverviewWebpage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the username on init
  }

  Future<void> _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _username =
              userDoc['username']; // Retrieve the username from Firestore
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_username != null)
                    Row(
                      children: [
                        Text(
                          _username!,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.person),
                        const SizedBox(width: 30),
                      ],
                    ),
                ],
              ),
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Home Page'),
                  if (_username != null)
                    Row(
                      children: [
                        Text(
                          _username!,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.person),
                      ],
                    ),
                ],
              ),
            ),
            body: _pages[_selectedIndex],
            drawer: _buildDrawer(),
          );
        }
      },
    );
  }
}
