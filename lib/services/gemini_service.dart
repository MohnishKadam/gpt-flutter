import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../controllers/model_controller.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // API key must be supplied during build time using: --dart-define="GEMINI_API_KEY=YOUR_KEY"
  // TEMPORARY: Remove this hardcoded key before committing to version control!
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: 'AIzaSyAgLuq75kJZQiXwOyUc7-sBD9hHYDPfwHo');

  final http.Client _client = http.Client();

  // Get the current model from the controller
  AIModel get currentModel {
    try {
      final modelController = Get.find<ModelController>();
      return modelController.selectedModel;
    } catch (e) {
      print('⚠️ ModelController not found, using default model');
      return AIModel.gemini15Flash;
    }
  }

  // Rate limiting: Track the last request time to avoid hitting 60 requests/minute limit
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval =
      Duration(milliseconds: 2000); // 2 seconds between requests for safety

  // Track request count for better rate limiting
  static int _requestCount = 0;
  static DateTime? _resetTime;

  /// Generate AI response using the currently selected model
  Future<String> generateResponse(
      String prompt, List<Message> conversationHistory) async {
    try {
      final messages = [
        ...conversationHistory,
        Message(content: prompt, role: MessageRole.user),
      ];

      final response =
          await chatCompletion(messages: messages, model: currentModel);
      return response;
    } catch (e) {
      print('❌ Error generating response: $e');
      rethrow;
    }
  }

  /// Enhanced rate limiter to ensure we don't exceed Gemini's free tier limit
  /// This adds a 2 second delay between requests and tracks request count
  Future<void> _rateLimitDelay() async {
    final now = DateTime.now();

    // Reset counter every minute
    if (_resetTime == null ||
        now.difference(_resetTime!) > const Duration(minutes: 1)) {
      _requestCount = 0;
      _resetTime = now;
    }

    // Check if we're approaching the limit (50 requests per minute to be safe)
    if (_requestCount >= 50) {
      final waitTime = Duration(minutes: 1) - now.difference(_resetTime!);
      if (waitTime.isNegative == false) {
        print(
            '⚠️ Rate limit approaching, waiting ${waitTime.inSeconds} seconds...');
        await Future.delayed(waitTime);
        _requestCount = 0;
        _resetTime = now;
      }
    }

    // Add delay between requests
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = now.difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final delayNeeded = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(delayNeeded);
      }
    }

    _lastRequestTime = now;
    _requestCount++;
  }

  Future<Stream<String>> chatCompletionStream({
    required List<Message> messages,
    required AIModel model,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw const GeminiException(
          'API key is not configured. Please set GEMINI_API_KEY.');
    }

    // Apply rate limiting before making the API request
    await _rateLimitDelay();

    final controller = StreamController<String>();

    try {
      final request = http.Request(
          'POST',
          Uri.parse(
              '$_baseUrl/models/${model.apiName}:streamGenerateContent?key=$_apiKey'));

      request.headers.addAll({
        'Content-Type': 'application/json',
      });

      final body = {
        'contents': await _convertMessagesToGeminiFormat(messages),
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
          'candidateCount': 1,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      request.body = json.encode(body);

      print('Sending streaming request to: ${request.url}');
      print('Using model: ${model.apiName}');
      print('📤 Request body: ${request.body}');

      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw const GeminiException('Request timed out after 30 seconds');
        },
      );

      if (streamedResponse.statusCode == 200) {
        print('Streaming API Response received successfully');
        // Collect the full response first, then parse
        String fullResponse = '';
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          fullResponse += chunk;
        }

        print('Full streaming response received: $fullResponse');

        // Gemini sends complete JSON objects, parse the entire response
        try {
          final decodedData = json.decode(fullResponse);
          print('✅ Successfully parsed full streaming response');
          print('Decoded data type: ${decodedData.runtimeType}');
          print('Full decoded data: $decodedData');

          // Handle both single object and list responses
          List<Map<String, dynamic>> responsesToProcess = [];

          if (decodedData is Map<String, dynamic>) {
            // Single object response
            print('📄 Processing single object response');
            responsesToProcess.add(decodedData);
          } else if (decodedData is List) {
            // List response - iterate through all objects
            print(
                '📋 Processing list response with ${decodedData.length} items');
            for (final item in decodedData) {
              if (item is Map<String, dynamic>) {
                responsesToProcess.add(item);
              } else {
                print(
                    '⚠️ Skipping non-object item in list: ${item.runtimeType}');
              }
            }
          } else {
            throw GeminiException(
                'Unexpected response format: ${decodedData.runtimeType}');
          }

          // Process each response object
          bool hasValidContent = false;
          for (int i = 0; i < responsesToProcess.length; i++) {
            final jsonData = responsesToProcess[i];
            print(
                '🔍 Processing response object ${i + 1}/${responsesToProcess.length}');
            print('JSON keys: ${jsonData.keys}');

            final candidatesData = jsonData['candidates'];
            print('Candidates data type: ${candidatesData.runtimeType}');
            print('Candidates data: $candidatesData');

            if (candidatesData is List && candidatesData.isNotEmpty) {
              final firstCandidate = candidatesData[0];
              print('First candidate: $firstCandidate');

              if (firstCandidate is Map<String, dynamic>) {
                final content = firstCandidate['content'];
                print('Content: $content');

                if (content is Map<String, dynamic>) {
                  final parts = content['parts'];
                  print('Parts: $parts');

                  if (parts is List && parts.isNotEmpty) {
                    final firstPart = parts[0];
                    if (firstPart is Map<String, dynamic>) {
                      final text = firstPart['text'];
                      print('Extracted text: $text');

                      if (text is String && text.isNotEmpty) {
                        controller.add(text);
                        print('✅ Streaming content added: "$text"');
                        hasValidContent = true;
                      }
                    }
                  }
                }
              }
            } else {
              print(
                  '❌ Candidates is not a List or is empty in object ${i + 1}. Type: ${candidatesData.runtimeType}');
            }
          }

          if (!hasValidContent) {
            print('⚠️ No valid content found in any response objects');
          }

          // Close the stream after processing all responses
          controller.close();
        } catch (e) {
          print('❌ Error parsing full streaming response: $e');
          print('Response that failed to parse: $fullResponse');
          controller.addError(
              GeminiException('Failed to parse streaming response: $e'));
        }
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        print('Streaming API Error: ${streamedResponse.statusCode}');
        print('Error Body: $errorBody');
        throw GeminiException(
            'API request failed with status ${streamedResponse.statusCode}: $errorBody');
      }
    } catch (e) {
      print('Streaming Exception: $e');
      controller.addError(e);
    }

    return controller.stream;
  }

  Future<String> chatCompletion({
    required List<Message> messages,
    required AIModel model,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw const GeminiException(
          'API key is not configured. Please set GEMINI_API_KEY.');
    }

    // Apply rate limiting before making the API request
    await _rateLimitDelay();

    const int maxRetries = 3;
    int retryCount = 0;
    int waitTime = 2; // Start with 2 seconds

    while (retryCount <= maxRetries) {
      try {
        print(
            'Sending request to: $_baseUrl/models/${model.apiName}:generateContent');
        print('Using model: ${model.apiName}');

        final requestBody = {
          'contents': await _convertMessagesToGeminiFormat(messages),
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxTokens,
            'candidateCount': 1,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        };

        print('📤 Regular request body: ${json.encode(requestBody)}');

        final response = await _client
            .post(
          Uri.parse(
              '$_baseUrl/models/${model.apiName}:generateContent?key=$_apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw const GeminiException('Request timed out after 30 seconds');
          },
        );

        if (response.statusCode == 200) {
          print('API Response received successfully');
          final data = json.decode(response.body);
          print('Full API Response: ${response.body}');

          // Parse the response according to the correct Gemini API format (same as streaming)
          if (data is Map<String, dynamic>) {
            final candidatesData = data['candidates'];
            print('Candidates data type: ${candidatesData.runtimeType}');
            print('Candidates data: $candidatesData');

            if (candidatesData is List && candidatesData.isNotEmpty) {
              final firstCandidate = candidatesData[0];
              print('First candidate: $firstCandidate');

              if (firstCandidate is Map<String, dynamic>) {
                final content = firstCandidate['content'];
                print('Content: $content');

                if (content is Map<String, dynamic>) {
                  final parts = content['parts'];
                  print('Parts: $parts');

                  if (parts is List && parts.isNotEmpty) {
                    final firstPart = parts[0];
                    if (firstPart is Map<String, dynamic>) {
                      final text = firstPart['text'];
                      print('Extracted text: $text');

                      if (text is String) {
                        print('✅ Regular content extracted: "$text"');
                        return text;
                      }
                    }
                  }
                }
              }
            } else {
              print(
                  '❌ Candidates is not a List or is empty. Type: ${candidatesData.runtimeType}');
            }
          }

          print('No valid content found in response');
          return '';
        } else if (response.statusCode == 429) {
          // Rate limit exceeded - implement exponential backoff
          if (retryCount < maxRetries) {
            print(
                '⚠️ Rate limit exceeded. Retrying in $waitTime seconds... (Attempt ${retryCount + 1}/$maxRetries)');
            await Future.delayed(Duration(seconds: waitTime));
            retryCount++;
            waitTime *= 2; // Double the wait time for next retry (2s, 4s, 8s)
            continue;
          } else {
            print('❌ Rate limit exceeded after $maxRetries retries');
            throw const GeminiException(
                'Rate limit exceeded. Please wait a few minutes before trying again. The free tier allows 60 requests per minute.');
          }
        } else {
          print('Gemini API Error: ${response.statusCode}');
          print('Response Body: ${response.body}');
          throw GeminiException(
              'API request failed with status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        if (e is GeminiException) {
          rethrow; // Re-throw GeminiException as-is
        }
        throw GeminiException('Failed to get chat completion: $e');
      }
    }

    // This should never be reached, but added for completeness
    throw const GeminiException(
        'Unexpected error in chatCompletion retry loop');
  }

  /// Get current rate limit status
  String getRateLimitStatus() {
    if (_resetTime == null) {
      return 'No requests made yet';
    }

    final now = DateTime.now();
    final timeSinceReset = now.difference(_resetTime!);
    final requestsInCurrentMinute = _requestCount;

    if (timeSinceReset > const Duration(minutes: 1)) {
      return 'Rate limit reset (0/60 requests this minute)';
    }

    return 'Rate limit: $requestsInCurrentMinute/60 requests this minute';
  }

  /// Reset rate limit counters (useful for testing)
  void resetRateLimit() {
    _requestCount = 0;
    _resetTime = null;
    _lastRequestTime = null;
    print('✅ Rate limit counters reset');
  }

  Future<List<Map<String, dynamic>>> _convertMessagesToGeminiFormat(
      List<Message> messages) async {
    List<Map<String, dynamic>> geminiMessages = [];

    for (final message in messages) {
      if (message.role == MessageRole.system) {
        // Gemini doesn't have system role, skip system messages
        continue;
      }

      List<Map<String, dynamic>> parts = [];

      // Add text content
      if (message.content.isNotEmpty) {
        parts.add({
          'text': message.content,
        });
      }

      // Add image content if present and model supports vision
      if (message.imageUrls != null && message.imageUrls!.isNotEmpty) {
        for (String imageUrl in message.imageUrls!) {
          final base64Data = await _getBase64FromUrl(imageUrl);
          parts.add({
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': base64Data,
            }
          });
        }
      }

      if (parts.isNotEmpty) {
        // Map internal MessageRole to Gemini API role format
        String geminiRole;
        if (message.role == MessageRole.user) {
          geminiRole = 'user';
        } else if (message.role == MessageRole.assistant) {
          geminiRole = 'model';
        } else {
          // Skip unsupported roles
          continue;
        }

        geminiMessages.add({
          'role': geminiRole,
          'parts': parts,
        });
      }
    }

    print('🔍 Converted messages for Gemini API:');
    for (int i = 0; i < geminiMessages.length; i++) {
      print('  Message ${i + 1}: ${geminiMessages[i]}');
    }

    return geminiMessages;
  }

  Future<String> _getBase64FromUrl(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert the image bytes to base64
        final bytes = response.bodyBytes;
        return base64Encode(bytes);
      } else {
        throw GeminiException(
            'Failed to fetch image from URL: ${response.statusCode}');
      }
    } catch (e) {
      throw GeminiException('Error fetching image from URL: $e');
    }
  }

  Future<bool> validateApiKey() async {
    // Validate API key
    if (_apiKey.isEmpty) {
      print('API key validation failed: API key is empty');
      return false;
    }

    // Apply rate limiting before making the API validation request
    await _rateLimitDelay();

    try {
      print('Validating API key with gemini-1.5-flash model...');
      // Test with a simple request like the curl example
      final response = await _client
          .post(
        Uri.parse(
            '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello'}
              ]
            }
          ]
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const GeminiException('API key validation timed out');
        },
      );

      print('Validation Response Status: ${response.statusCode}');
      print('Validation Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Validation Error: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class GeminiException implements Exception {
  final String message;

  const GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}
