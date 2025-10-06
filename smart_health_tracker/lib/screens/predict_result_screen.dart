import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PredictResultScreen extends StatelessWidget {
  final String condition; // e.g., "Critical"
  final List<Map<String, dynamic>> results;

  const PredictResultScreen({
    super.key,
    required this.condition,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    Color conditionColor;
    if (condition.toLowerCase() == "healthy") {
      conditionColor = Colors.green;
    } else if (condition.toLowerCase() == "risk") {
      conditionColor = Colors.orange;
    } else {
      conditionColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("VitalPulse"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      backgroundColor: Colors.teal.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Animated condition banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: conditionColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Condition: $condition",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable list of issues
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + index * 100),
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.warning,
                            color: Colors.redAccent, size: 30),
                        title: Text(
                          item["name"],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Value: ${item["value"]}",
                                style: GoogleFonts.poppins(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              "Suggestion: ${item["suggestion"]}",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
