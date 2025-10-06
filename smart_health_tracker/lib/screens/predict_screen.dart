import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'predict_result_screen.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ageController = TextEditingController();
  final bmiController = TextEditingController();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final heartrateController = TextEditingController();
  final glucoseController = TextEditingController();

  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat(reverse: true);

  late final Animation<double> _animation =
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Dummy analyze function (you can replace with API)
  List<Map<String, dynamic>> analyzeParameters() {
    final double bmi = double.tryParse(bmiController.text) ?? 0;
    final int systolic = int.tryParse(systolicController.text) ?? 0;
    final int diastolic = int.tryParse(diastolicController.text) ?? 0;
    final int heartrate = int.tryParse(heartrateController.text) ?? 0;
    final int glucose = int.tryParse(glucoseController.text) ?? 0;

    List<Map<String, dynamic>> issues = [];

    if (bmi >= 30) {
      issues.add({
        "name": "BMI - Obese",
        "value": bmi,
        "suggestion": "Adopt a calorie-controlled diet and regular exercise."
      });
    } else if (bmi < 18.5) {
      issues.add({
        "name": "BMI - Underweight",
        "value": bmi,
        "suggestion": "Increase calorie intake with healthy foods.",
      });
    }

    if (systolic > 140) {
      issues.add({
        "name": "Systolic BP - High",
        "value": systolic,
        "suggestion": "Reduce salt, manage stress, and consult a doctor."
      });
    } else if (systolic < 90) {
      issues.add({
        "name": "Systolic BP - Low",
        "value": systolic,
        "suggestion": "Stay hydrated and eat small, frequent meals.",
      });
    }

    if (diastolic > 90) {
      issues.add({
        "name": "Diastolic BP - High",
        "value": diastolic,
        "suggestion": "Monitor regularly and reduce sodium intake."
      });
    } else if (diastolic < 60) {
      issues.add({
        "name": "Diastolic BP - Low",
        "value": diastolic,
        "suggestion": "Stay hydrated and consult a doctor if symptoms occur.",
      });
    }

    if (heartrate > 100) {
      issues.add({
        "name": "Heart Rate - High",
        "value": heartrate,
        "suggestion":
            "Reduce caffeine, manage stress, and seek medical advice if persistent."
      });
    } else if (heartrate < 60) {
      issues.add({
        "name": "Heart Rate - Low",
        "value": heartrate,
        "suggestion":
            "Could indicate athletic conditioning, check with doctor.",
      });
    }

    if (glucose > 125) {
      issues.add({
        "name": "Blood Sugar - High",
        "value": glucose,
        "suggestion": "Limit sugar intake and get checked for diabetes."
      });
    } else if (glucose < 70) {
      issues.add({
        "name": "Blood Sugar - Low",
        "value": glucose,
        "suggestion": "Consume fast-acting carbs like fruit juice.",
      });
    }

    return issues;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final color1 = Color.lerp(
            Colors.teal.shade400, Colors.lightBlue.shade200, _animation.value)!;
        final color2 = Color.lerp(Colors.purple.shade200, Colors.cyan.shade200,
            1 - _animation.value)!;

        return Scaffold(
          appBar: AppBar(
            title: const Text("VitalPulse"),
            centerTitle: true,
            backgroundColor: Colors.teal.shade300,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Icon(
                    FontAwesomeIcons.hospitalUser,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildForm(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(ageController, "Age", Icons.person),
          _buildTextField(bmiController, "BMI", Icons.monitor_weight),
          _buildTextField(systolicController, "Systolic BP", Icons.favorite,
              color: Colors.red),
          _buildTextField(
              diastolicController, "Diastolic BP", Icons.favorite_border,
              color: Colors.red),
          _buildTextField(
              heartrateController, "Heart Rate", FontAwesomeIcons.heartPulse,
              color: Colors.red),
          _buildTextField(glucoseController, "Glucose", Icons.bloodtype,
              color: Colors.red),
          const SizedBox(height: 20),
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.health_and_safety, color: Colors.white),
              label: const Text(
                "Check Health",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final issues = analyzeParameters();
                  final condition =
                      issues.isEmpty ? "Healthy" : "Critical"; // simple rule

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PredictResultScreen(
                        condition: condition,
                        results: issues,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold, // 👈 Makes label bold
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: color ?? Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
