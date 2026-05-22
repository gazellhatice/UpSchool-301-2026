import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kisisel_harcama_kocu_1/core/config/app_config.dart';
import 'package:kisisel_harcama_kocu_1/core/services/backend_url_resolver.dart';

class CoachApiException implements Exception {
  CoachApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CoachMessage {
  const CoachMessage({required this.role, required this.text});
  final String role;
  final String text;

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}

class FinancialContext {
  const FinancialContext({
    this.month,
    this.income,
    this.expense,
    this.balance,
    this.usagePercent,
    this.topCategories = const [],
    this.recentTransactions = const [],
  });

  final String? month;
  final double? income;
  final double? expense;
  final double? balance;
  final double? usagePercent;
  final List<CategoryContext> topCategories;
  final List<TransactionContext> recentTransactions;

  Map<String, dynamic> toJson() => {
        if (month != null) 'month': month,
        if (income != null) 'income': income,
        if (expense != null) 'expense': expense,
        if (balance != null) 'balance': balance,
        if (usagePercent != null) 'usagePercent': usagePercent,
        if (topCategories.isNotEmpty)
          'topCategories': topCategories.map((c) => c.toJson()).toList(),
        if (recentTransactions.isNotEmpty)
          'recentTransactions':
              recentTransactions.map((t) => t.toJson()).toList(),
      };
}

class CategoryContext {
  const CategoryContext({
    required this.name,
    required this.amount,
    required this.percent,
  });

  final String name;
  final double amount;
  final double percent;

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'percent': percent,
      };
}

class TransactionContext {
  const TransactionContext({
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
  });

  final String date;
  final double amount;
  final String type;
  final String category;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
        'type': type,
        'category': category,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class CoachApiService {
  CoachApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void dispose() => _client.close();

  Future<bool> ping(String baseUrl) async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkHealth() async {
    BackendUrlResolver.reset();
    final base = await BackendUrlResolver.resolve(ping);
    final ok = await ping(base);
    if (kDebugMode && ok) {
      debugPrint('Backend bağlantısı: $base');
    }
    return ok;
  }

  Future<String> _resolveBaseUrl() =>
      BackendUrlResolver.resolve(ping);

  Future<String?> _token(User user) async {
    try {
      return await user.getIdToken().timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }

  Future<String> sendChat({
    required User user,
    required List<CoachMessage> messages,
    FinancialContext? financialContext,
  }) async {
    final baseUrl = await _resolveBaseUrl();
    final token = await _token(user);
    final uri = Uri.parse('$baseUrl/api/v1/coach/chat');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'messages': messages.map((m) => m.toJson()).toList(),
              if (financialContext != null)
                'financialContext': financialContext.toJson(),
            }),
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw CoachApiException(
              'Sunucu yanıt vermedi. Backend: $baseUrl',
            ),
          );
    } on CoachApiException {
      rethrow;
    } catch (_) {
      BackendUrlResolver.reset();
      throw CoachApiException(
        'Backend\'e ulaşılamadı. Emülatörde önce şunu çalıştır:\n'
        'adb reverse tcp:3001 tcp:3001',
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['reply'] as String?)?.trim() ?? '';
    }

    try {
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = err['detail']?.toString() ?? '';
      var message =
          err['error']?.toString() ?? 'Sunucu hatası (${response.statusCode})';
      if (response.statusCode == 401) {
        message = 'Oturum süresi doldu. Uygulamadan çıkış yapıp tekrar giriş yap.';
      } else if (detail.contains('API key') ||
          detail.contains('API_KEY') ||
          detail.contains('OPENROUTER')) {
        message =
            'AI API anahtarı geçersiz veya eksik. backend/.env dosyasını kontrol et.';
      }
      throw CoachApiException(message);
    } on CoachApiException {
      rethrow;
    } catch (_) {
      throw CoachApiException('Bağlantı hatası (${response.statusCode})');
    }
  }

  Future<String> requestAnalysis({
    required User user,
    required FinancialContext financialContext,
  }) async {
    final baseUrl = await _resolveBaseUrl();
    final token = await _token(user);
    final uri = Uri.parse('$baseUrl/api/v1/coach/analyze');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'financialContext': financialContext.toJson()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['analysis'] as String?)?.trim() ?? '';
    }

    throw CoachApiException('Analiz alınamadı (${response.statusCode})');
  }
}
