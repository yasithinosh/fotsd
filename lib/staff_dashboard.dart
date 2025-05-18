import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance.dart';
import 'news.dart';
import 'profile.dart';
import 'about.dart';
import 'time_table.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  /// Fetches the user's profile image from Firestore.
  Future<String?> _getProfileImage(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userData['pImage'] as String?;
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<String?> _getUserName(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userData['name'] as String?;
      }
    } catch (e) {
      _showErrorDialog(context, "Error fetching user name: $e");
    }
    return "Staff";
  }

  /// Displays an error message using an AlertDialog.
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.dehaze),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const About()),
            );
          },
        ),
        actions: [
          FutureBuilder<String?>(
            future: _getProfileImage(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                );
              } else if (snapshot.hasError || snapshot.data == null) {
                return IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(snapshot.data!),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<String?>(
          future: _getUserName(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              );
            } else if (snapshot.hasError) {
              _showErrorDialog(context, "Error fetching user name.");
              return const Center(child: Text("Error loading user data."));
            }

            final userName = snapshot.data ?? "Staff";
            return Column(
              children: [
                Container(
                  height: 200,
                  alignment: Alignment.topRight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/facultyimage.jpg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 3, // Distance from the bottom
                        left: 25, // Distance from the left
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildDashboardCard(
                          context, 'Time Table', 'assets/timetable.jpg'),
                      _buildDashboardCard(
                          context, 'QR Scanner', 'assets/qr_scanner.png'),
                      _buildDashboardCard(
                          context, 'Attendance', 'assets/attendance.png'),
                      _buildDashboardCard(
                          context, 'Library', 'assets/library.jpeg'),
                      _buildDashboardCard(
                          context, 'Google Class Room', 'assets/classroom.png'),
                      _buildDashboardCard(context, 'News', 'assets/news.png'),
                      _buildDashboardCard(context, 'Email', 'assets/email.png'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, String imagePath) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _navigateToScreen(context, title);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Navigates to different screens based on the tapped dashboard card.
  void _navigateToScreen(BuildContext context, String title) {
    if (title == 'Time Table') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TimeTableScreen(TimeTableTitle: '',)));
    } else if (title == 'QR Scanner') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const QRScannerScreen()));
    } else if (title == 'Attendance') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
    } else if (title == 'Library') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LibraryScreen()));
    } else if (title == 'Courses') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()));
    } else if (title == 'News') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const NewsScreen()));
    } else if (title == 'Email') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EmailScreen()));
    }
  }
}

/// Dummy placeholder screens for navigation (to be replaced with actual implementations).

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('QR Scanner')),
        body: const Center(child: Text('QR Scanner Screen')));
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: const Center(child: Text('Library Screen')));
  }
}

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Courses')),
        body: const Center(child: Text('Courses Screen')));
  }
}

class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Email')),
        body: const Center(child: Text('Email Screen')));
  }
}
