import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5000/api';

  static Future<http.Response> register(
    String name,
    String email,
    String password,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> addSavings(
    String userId,
    double amount,
    DateTime date,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/savings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
        'date': date.toIso8601String(),
      }),
    );
  }

  static Future<http.Response> addCredit(
    String userId,
    double amount,
    DateTime date,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/credits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
        'date': date.toIso8601String(),
      }),
    );
  }

  static Future<http.Response> getSavings(String userId, String token) async {
    return await http.get(
      Uri.parse('$baseUrl/savings/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getCredits(String userId, String token) async {
    return await http.get(
      Uri.parse('$baseUrl/credits/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getStats(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getPendingMembers(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/pending-members'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> approveMember(
    String userId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/approve'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );
  }

  static Future<http.Response> getPendingSavings(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/pending-savings'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> approveSavings(
    String savingsId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/approve-savings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'savingsId': savingsId}),
    );
  }

  static Future<http.Response> getPendingCredits(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/pending-credits'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> approveCredit(
    String creditId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/approve-credit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'creditId': creditId}),
    );
  }

  // Add more endpoints as needed (admin approvals, etc.)
}
