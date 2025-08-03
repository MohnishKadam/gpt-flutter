import 'package:get/get.dart';
import '../services/gemini_service.dart';

class RateLimitHelper {
  static final GeminiService _geminiService = Get.find<GeminiService>();

  /// Get current rate limit status
  static String getCurrentStatus() {
    return _geminiService.getRateLimitStatus();
  }

  /// Check if we're approaching rate limit
  static bool isApproachingLimit() {
    final status = getCurrentStatus();
    if (status.contains('Rate limit:')) {
      final parts = status.split(':');
      if (parts.length > 1) {
        final currentRequests =
            int.tryParse(parts[1].split('/')[0].trim()) ?? 0;
        return currentRequests >= 45; // Warning at 45 requests
      }
    }
    return false;
  }

  /// Get user-friendly rate limit message
  static String getUserMessage() {
    final status = getCurrentStatus();

    if (status.contains('No requests made yet')) {
      return 'Ready to chat!';
    } else if (status.contains('Rate limit reset')) {
      return 'Rate limit reset - you can make new requests';
    } else if (isApproachingLimit()) {
      return '⚠️ Approaching rate limit. Consider waiting a moment.';
    } else {
      return 'Rate limit status: $status';
    }
  }

  /// Reset rate limit (for testing)
  static void resetRateLimit() {
    _geminiService.resetRateLimit();
  }

  /// Get tips for managing rate limits
  static List<String> getRateLimitTips() {
    return [
      'The free Gemini API allows 60 requests per minute',
      'Wait 1-2 minutes between requests to avoid hitting limits',
      'Consider upgrading to a paid plan for higher limits',
      'Use the app sparingly to stay within free tier limits',
      'Check the status indicator to see your current usage',
    ];
  }
}
