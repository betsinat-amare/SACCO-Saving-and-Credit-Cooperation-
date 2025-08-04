import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/savings.dart';
import '../models/credit.dart';
import '../models/payment.dart';
import '../models/stats.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  bool _loading = false;
  String? _error;
  List<User> _allMembers = [];
  List<Savings> _allSavings = [];
  List<Credit> _allCredits = [];
  List<Payment> _allPayments = [];
  CooperativeStats? _stats;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Fetch all data
      final statsRes = await ApiService.getStats(auth.token!);
      final membersRes = await ApiService.getAllMembers(auth.token!);
      final savingsRes = await ApiService.getAllSavings(auth.token!);
      final creditsRes = await ApiService.getAllCredits(auth.token!);
      final paymentsRes = await ApiService.getAllPayments(auth.token!);

      if (statsRes.statusCode == 200) {
        final statsData = jsonDecode(statsRes.body);
        setState(() {
          _stats = CooperativeStats.fromJson(statsData['stats']);
        });
      }

      if (membersRes.statusCode == 200) {
        final membersData = jsonDecode(membersRes.body);
        setState(() {
          _allMembers =
              (membersData['users'] as List?)
                  ?.map((e) => User.fromJson(e))
                  .toList() ??
              [];
        });
      }

      if (savingsRes.statusCode == 200) {
        final savingsData = jsonDecode(savingsRes.body);
        setState(() {
          _allSavings =
              (savingsData['savings'] as List?)
                  ?.map((e) => Savings.fromJson(e))
                  .toList() ??
              [];
        });
      }

      if (creditsRes.statusCode == 200) {
        final creditsData = jsonDecode(creditsRes.body);
        setState(() {
          _allCredits =
              (creditsData['credits'] as List?)
                  ?.map((e) => Credit.fromJson(e))
                  .toList() ??
              [];
        });
      }

      if (paymentsRes.statusCode == 200) {
        final paymentsData = jsonDecode(paymentsRes.body);
        setState(() {
          _allPayments =
              (paymentsData['payments'] as List?)
                  ?.map((e) => Payment.fromJson(e))
                  .toList() ??
              [];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _approveMember(String userId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.approveMember(userId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member approved successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to approve member'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectMember(String userId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.rejectMember(userId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member rejected successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to reject member'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _approveSavings(String savingsId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.approveSavings(savingsId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings approved successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to approve savings'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectSavings(String savingsId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.rejectSavings(savingsId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings rejected successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to reject savings'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _approveCredit(String creditId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.approveCredit(creditId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit approved successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to approve credit'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectCredit(String creditId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.rejectCredit(creditId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit rejected successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to reject credit'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _approvePayment(String paymentId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.approvePayment(paymentId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment approved successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to approve payment'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectPayment(String paymentId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.rejectPayment(paymentId, auth.token!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment rejected successfully!')),
        );
        _fetchAll();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${errorData['error'] ?? 'Failed to reject payment'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showMemberDetails(User member) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    List<Savings> memberSavings = [];
    List<Credit> memberCredits = [];
    List<Payment> memberPayments = [];

    try {
      final sRes = await ApiService.getSavings(member.id, auth.token!);
      if (sRes.statusCode == 200) {
        final sData = jsonDecode(sRes.body);
        memberSavings =
            (sData['savings'] as List?)
                ?.map((e) => Savings.fromJson(e))
                .toList() ??
            [];
      }

      final cRes = await ApiService.getCredits(member.id, auth.token!);
      if (cRes.statusCode == 200) {
        final cData = jsonDecode(cRes.body);
        memberCredits =
            (cData['credits'] as List?)
                ?.map((e) => Credit.fromJson(e))
                .toList() ??
            [];
      }

      final pRes = await ApiService.getPayments(member.id, auth.token!);
      if (pRes.statusCode == 200) {
        final pData = jsonDecode(pRes.body);
        memberPayments =
            (pData['payments'] as List?)
                ?.map((e) => Payment.fromJson(e))
                .toList() ??
            [];
      }
    } catch (e) {
      // Handle error silently
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${member.name} Details'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${member.email}'),
                    Text('Status: ${member.status}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Savings:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...memberSavings.map(
                      (s) => ListTile(
                        dense: true,
                                                    title: Text('${s.amount.toStringAsFixed(2)} Birr'),
                        subtitle: Text(
                          'Date: ${s.date.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                s.status == 'approved'
                                    ? Colors.green
                                    : s.status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Credits:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...memberCredits.map(
                      (c) => ListTile(
                        dense: true,
                                                    title: Text('${c.amount.toStringAsFixed(2)} Birr'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${c.date.toLocal().toString().split(' ')[0]}',
                            ),
                            if (c.status == 'approved')
                              Text(
                                'Remaining: ${c.remainingDebt.toStringAsFixed(2)} Birr',
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                c.status == 'approved'
                                    ? Colors.green
                                    : c.status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payments:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...memberPayments.map(
                      (p) => ListTile(
                        dense: true,
                                                    title: Text('${p.amount.toStringAsFixed(2)} Birr'),
                        subtitle: Text(
                          'Date: ${p.date.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                p.status == 'approved'
                                    ? Colors.green
                                    : p.status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_stats != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Cooperative Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Capital'),
                            Text(
                              '${_stats!.totalCapital.toStringAsFixed(2)} Birr',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Members'),
                            Text(
                              '${_stats!.totalMembers}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Savings'),
                            Text(
                              '${_stats!.totalSavings.toStringAsFixed(2)} Birr',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Credits'),
                            Text(
                              '${_stats!.totalCredits.toStringAsFixed(2)} Birr',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Meeting Day'),
                  Text(
                    _stats!.meetingDay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMembersScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'All Members',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_allMembers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No members found'),
            ),
          )
        else
          ..._allMembers.map(
            (member) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      member.status == 'approved'
                          ? Colors.green
                          : member.status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(member.name),
                subtitle: Text(member.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            member.status == 'approved'
                                ? Colors.green
                                : member.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        member.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (member.status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveMember(member.id),
                        tooltip: 'Approve Member',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectMember(member.id),
                        tooltip: 'Reject Member',
                      ),
                    ],
                  ],
                ),
                onTap: () => _showMemberDetails(member),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSavingsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'All Savings Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_allSavings.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No savings requests found'),
            ),
          )
        else
          ..._allSavings.map(
            (savings) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.savings,
                  color:
                      savings.status == 'approved'
                          ? Colors.green
                          : savings.status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
                                            title: Text('${savings.amount.toStringAsFixed(2)} Birr'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member: ${savings.userName ?? 'Unknown'}'),
                    Text(
                      'Date: ${savings.date.toLocal().toString().split(' ')[0]}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            savings.status == 'approved'
                                ? Colors.green
                                : savings.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        savings.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (savings.status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveSavings(savings.id),
                        tooltip: 'Approve Savings',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectSavings(savings.id),
                        tooltip: 'Reject Savings',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCreditsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'All Credit Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_allCredits.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No credit requests found'),
            ),
          )
        else
          ..._allCredits.map(
            (credit) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.credit_card,
                  color:
                      credit.status == 'approved'
                          ? Colors.green
                          : credit.status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
                                            title: Text('${credit.amount.toStringAsFixed(2)} Birr'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member: ${credit.userName ?? 'Unknown'}'),
                    Text(
                      'Date: ${credit.date.toLocal().toString().split(' ')[0]}',
                    ),
                    if (credit.status == 'approved')
                      Text(
                                                      'Remaining: ${credit.remainingDebt.toStringAsFixed(2)} Birr',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            credit.status == 'approved'
                                ? Colors.green
                                : credit.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        credit.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (credit.status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveCredit(credit.id),
                        tooltip: 'Approve Credit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectCredit(credit.id),
                        tooltip: 'Reject Credit',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'All Payment Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_allPayments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No payment requests found'),
            ),
          )
        else
          ..._allPayments.map(
            (payment) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.payment,
                  color:
                      payment.status == 'approved'
                          ? Colors.green
                          : payment.status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
                                            title: Text('${payment.amount.toStringAsFixed(2)} Birr'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member: ${payment.userName ?? 'Unknown'}'),
                    Text(
                      'Date: ${payment.date.toLocal().toString().split(' ')[0]}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            payment.status == 'approved'
                                ? Colors.green
                                : payment.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (payment.status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approvePayment(payment.id),
                        tooltip: 'Approve Payment',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectPayment(payment.id),
                        tooltip: 'Reject Payment',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildStatsScreen(),
      _buildMembersScreen(),
      _buildSavingsScreen(),
      _buildCreditsScreen(),
      _buildPaymentsScreen(),
    ];

    final titles = ['Stats', 'Members', 'Savings', 'Credits', 'Payments'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Credits',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
        ],
      ),
    );
  }
}
