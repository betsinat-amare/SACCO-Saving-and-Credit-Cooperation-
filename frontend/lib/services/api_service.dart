import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // For physical device testing, use your PC's IP address
  // For emulator testing, use 10.0.2.2
  static String baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:5000/api';

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

  // Admin: Approve member
  static Future<http.Response> approveMember(
    String userId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/approve-member'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );
  }

  // Admin: Reject member
  static Future<http.Response> rejectMember(String userId, String token) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/reject-member'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );
  }

  // Admin: Approve savings
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

  // Admin: Reject savings
  static Future<http.Response> rejectSavings(
    String savingsId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/reject-savings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'savingsId': savingsId}),
    );
  }

  // Admin: Approve credit
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

  // Admin: Reject credit
  static Future<http.Response> rejectCredit(
    String creditId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/reject-credit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'creditId': creditId}),
    );
  }

  // Admin: Approve payment
  static Future<http.Response> approvePayment(
    String paymentId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/approve-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'paymentId': paymentId}),
    );
  }

  // Admin: Reject payment
  static Future<http.Response> rejectPayment(
    String paymentId,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/admin/reject-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'paymentId': paymentId}),
    );
  }

  // Admin: Get all savings (pending, approved, rejected)
  static Future<http.Response> getAllSavings(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/all-savings'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Admin: Get all credits (pending, approved, rejected)
  static Future<http.Response> getAllCredits(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/all-credits'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Admin: Get all payments (pending, approved, rejected)
  static Future<http.Response> getAllPayments(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/all-payments'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Admin: Get pending savings
  static Future<http.Response> getPendingSavings(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/pending-savings'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Admin: Get pending credits
  static Future<http.Response> getPendingCredits(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/pending-credits'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Admin: Get pending payments
  static Future<http.Response> getPendingPayments(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/admin/pending-payments'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getAllMembers(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/all-members'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> addPayment(
    String userId,
    double amount,
    DateTime date,
    String token,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/payments'),
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

  static Future<http.Response> getPayments(String userId, String token) async {
    return await http.get(
      Uri.parse('$baseUrl/payments/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Add more endpoints as needed (admin approvals, etc.)
}
