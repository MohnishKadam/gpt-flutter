import 'package:get/get.dart';
import '../services/gemini_service.dart';
import '../models/message.dart';
import '../models/ai_model.dart';

class ApiTest {
  static final GeminiService _geminiService = Get.find<GeminiService>();

  /// Test the Gemini API connection
  static Future<void> testGeminiApi() async {
    print('🧪 Testing Gemini API connection...');

    try {
      // Test API key validation
      final isValid = await _geminiService.validateApiKey();
      print('🔑 API Key validation: ${isValid ? "✅ Valid" : "❌ Invalid"}');

      if (!isValid) {
        print('❌ API key is invalid. Please check your GEMINI_API_KEY.');
        return;
      }

      // Test a simple chat completion
      print('📤 Testing chat completion...');
      final response = await _geminiService.chatCompletion(
        messages: [
          Message(
            content: 'Hello, this is a test message.',
            role: MessageRole.user,
          ),
        ],
        model: AIModel.gemini15Flash,
      );

      print('✅ API test successful!');
      print('📝 Response: $response');
    } catch (e) {
      print('❌ API test failed: $e');

      if (e.toString().contains('Rate limit exceeded')) {
        print('💡 Rate limit hit. Try again in a few minutes.');
      } else if (e.toString().contains('API key')) {
        print('💡 Check your GEMINI_API_KEY environment variable.');
      } else if (e.toString().contains('timeout')) {
        print('💡 Network timeout. Check your internet connection.');
      }
    }
  }

  /// Get current API status
  static String getApiStatus() {
    final status = _geminiService.getRateLimitStatus();
    return 'API Status: $status';
  }

  /// Reset rate limit for testing
  static void resetRateLimit() {
    _geminiService.resetRateLimit();
    print('✅ Rate limit reset for testing');
  }
}
