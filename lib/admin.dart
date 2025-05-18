import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'attendance.dart';
import 'main.dart';
import 'news.dart';
import 'about.dart';
import 'student_dashboard.dart';
import 'time_table.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _launchWebsite(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorDialog(context, "Could not launch $url");
    }
  }

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
        title: const Text('Admin Dashboard'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const CircleAvatar(
                radius: 20,
                child: Icon(Icons.logout_rounded,
                    color: Color.fromARGB(255, 221, 136, 9)),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                      child: const Text(
                        "Admin User",
                        style: TextStyle(
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

  void _navigateToScreen(BuildContext context, String title) {
    if (title == 'Library') {
      _launchWebsite('https://lib.rjt.ac.lk/', context);
    } else if (title == 'Time Table') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TimeTableScreen(
                    TimeTableTitle: '',
                  )));
    } else if (title == 'Attendance') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
    } else if (title == 'Courses') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()));
    } else if (title == 'News') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AdminNews()));
    } else if (title == 'Email') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EmailScreen()));
    }
  }
}

/// admin Login
class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Adminlogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ignore: unused_element
  void _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == "yasithinosh1@gmail.com" && password == "Admin@2001") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
