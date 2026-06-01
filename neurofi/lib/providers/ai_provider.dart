import 'package:flutter/material.dart';
import '../models/ai_insight_model.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  List<AiInsightModel> _insights = [];
  List<BudgetPredictionModel> _predictions = [];
  List<Map<String, String>> _chatHistory = [];
  bool _isLoadingInsights = false;
  bool _isSendingMessage = false;
  String? _errorMessage;
  String? _aiCategoryResult;
  bool _isCategorizeing = false;

  List<AiInsightModel> get insights => _insights;
  List<BudgetPredictionModel> get predictions => _predictions;
  List<Map<String, String>> get chatHistory => _chatHistory;
  bool get isLoadingInsights => _isLoadingInsights;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  String? get aiCategoryResult => _aiCategoryResult;
  bool get isCategorizing => _isCategorizeing;

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadInsights() async {
    _isLoadingInsights = true;
    _setError(null);
    notifyListeners();
    try {
      _insights = await _aiService.getInsights();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }

  Future<void> loadBudgetPredictions() async {
    _isLoadingInsights = true;
    notifyListeners();
    try {
      _predictions = await _aiService.getBudgetPredictions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }

  Future<String?> categorize({
    required String description,
    double amount = 0,
    String? merchantName,
  }) async {
    _isCategorizeing = true;
    _aiCategoryResult = null;
    notifyListeners();
    try {
      final result = await _aiService.categorize(
        description:  description,
        amount:       amount,
        merchantName: merchantName,
      );
      _aiCategoryResult = result['category'];
      notifyListeners();
      return _aiCategoryResult;
    } catch (_) {
      return null;
    } finally {
      _isCategorizeing = false;
      notifyListeners();
    }
  }

  void clearAiCategory() {
    _aiCategoryResult = null;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    final userMsg = {'role': 'user', 'content': message};
    _chatHistory.add(userMsg);
    _isSendingMessage = true;
    _setError(null);
    notifyListeners();
    try {
      final reply = await _aiService.chat(
        message: message,
        history: _chatHistory
            .where((m) => m['role'] != null && m['content'] != null)
            .map((m) => {'role': m['role']!, 'content': m['content']!})
            .toList(),
      );
      _chatHistory.add({'role': 'assistant', 'content': reply});
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _chatHistory.add({
        'role':    'assistant',
        'content': 'Sorry, something went wrong. Please try again.',
      });
      notifyListeners();
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatHistory.clear();
    notifyListeners();
  }
}
