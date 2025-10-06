import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predict_response.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // change later for mobile device (use your LAN IP)

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Signup
  static Future<bool> signup(
      String username, String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/signup/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // success if inserted_id returned
        return data["inserted_id"] != null;
      } else {
        print("Signup failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during signup: $e");
      return false;
    }
  }

  // Login
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data["access_token"]); // save JWT
      return true;
    }
    return false;
  }

  // Get Profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/users/profile/get"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Predict Health
  static Future<PredictResponse> predictHealth({
    required int age,
    required double bmi,
    required int systolicbp,
    required int diastolicbp,
    required int heartrate,
    required int glucose,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/ml/predict/"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "age": age,
        "bmi": bmi,
        "systolicbp": systolicbp,
        "diastolicbp": diastolicbp,
        "heartrate": heartrate,
        "glucose": glucose,
      }),
    );

    print("Predict response: ${response.statusCode} ${response.body}"); // debug

    if (response.statusCode == 200) {
      return PredictResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to predict: ${response.body}");
    }
  }

// 🔥 Update Profile (added)
  static Future<bool> updateProfile({
    required String name,
    int? age,
    String? bio,
    File? file,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/users/profile"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = name;
      if (age != null) request.fields['age'] = age.toString();
      if (bio != null && bio.isNotEmpty) request.fields['bio'] = bio;

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profile_picture", file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Profile update response: ${response.statusCode} ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }
}
