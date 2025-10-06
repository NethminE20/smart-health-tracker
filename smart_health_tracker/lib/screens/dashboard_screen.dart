import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'predict_screen.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final ValueNotifier<double> _predictScale = ValueNotifier(1.0);
  final Map<String, double> _cardScales = {};

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _onCardTap(String id) async {
    setState(() => _cardScales[id] = 1.15);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _cardScales[id] = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        final color1 = Color.lerp(Colors.teal.shade300,
            Colors.lightBlue.shade300, _bgAnimation.value)!;
        final color2 = Color.lerp(Colors.green.shade100, Colors.cyan.shade100,
            1 - _bgAnimation.value)!;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.blueAccent,
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                "VitalPulse",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert,
                    color: Colors.black87, size: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 8,
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else if (value == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40), // 👈 More space under title

                  // Row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBouncingCard("heartRate", Icons.favorite,
                          "Heart Rate", "72 bpm", Colors.redAccent),
                      _buildBouncingCard("bmi", Icons.monitor_weight, "BMI",
                          "23.5", Colors.deepPurpleAccent),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBouncingCard("sysBP", Icons.monitor_heart,
                          "Systolic BP", "118 mmHg", Colors.blueAccent),
                      _buildBouncingCard("diaBP", Icons.favorite_outline,
                          "Diastolic BP", "78 mmHg", Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Centered Glucose card
                  Center(
                    child: _buildBouncingCard("glucose", Icons.bloodtype,
                        "Glucose", "92 mg/dL", Colors.orangeAccent),
                  ),

                  const Spacer(),

                  // Prediction button
                  _buildAnimatedButton(
                    label: "Health Prediction",
                    icon: Icons.analytics,
                    color: Colors.greenAccent,
                    scaleNotifier: _predictScale,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PredictScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBouncingCard(
      String id, IconData icon, String title, String value, Color color) {
    _cardScales.putIfAbsent(id, () => 1.0);

    return GestureDetector(
      onTap: () => _onCardTap(id),
      child: AnimatedScale(
        scale: _cardScales[id] ?? 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: 150, // 👈 Fixed width for all cards
          height: 160, // 👈 Fixed height for all cards
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 6,
            shadowColor: color.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required IconData icon,
    required Color color,
    required ValueNotifier<double> scaleNotifier,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      onEnter: (_) => scaleNotifier.value = 1.1,
      onExit: (_) => scaleNotifier.value = 1.0,
      child: ValueListenableBuilder<double>(
        valueListenable: scaleNotifier,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black45,
              ),
            ),
          );
        },
      ),
    );
  }
}
