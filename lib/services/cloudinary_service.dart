import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String cloudName = 'dl4tj90ou';
  static const String apiKey =
      '533525272652749'; // Replace with your Cloudinary API key
  static const String apiSecret =
      '9LJqlPquoCWT5aEC-QpretAXzLM'; // Replace with your Cloudinary API secret
  static const String uploadPreset =
      'CHATGPT'; // Replace with your upload preset

  final http.Client _client = http.Client();

  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri);

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add upload preset (for unsigned uploads)
      request.fields['upload_preset'] = uploadPreset;

      // Add transformation parameters for optimization
      request.fields['transformation'] =
          'c_limit,w_1000,h_1000,q_auto:good,f_auto';

      // Add folder organization
      request.fields['folder'] = 'chatgpt_clone/images';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        return data['secure_url'] as String?;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw CloudinaryException(
            'Failed to upload image: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw CloudinaryException('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final uploadTasks = imageFiles.map((file) => uploadImage(file));
    final results = await Future.wait(uploadTasks);

    return results.where((url) => url != null).cast<String>().toList();
  }

  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);

      final response = await _client.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 'ok';
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  String _generateSignature(String publicId, int timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(params);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  String? extractPublicIdFromUrl(String url) {
    final regex = RegExp(r'/v\d+/(.+)\.(jpg|jpeg|png|gif|webp)$');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  void dispose() {
    _client.close();
  }
}

class CloudinaryException implements Exception {
  final String message;

  const CloudinaryException(this.message);

  @override
  String toString() => 'CloudinaryException: $message';
}
