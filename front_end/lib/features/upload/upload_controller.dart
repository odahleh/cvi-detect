import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/cvi_result.dart';

/// Controller for handling image uploads and CVI detection
class UploadController extends StateNotifier<AsyncValue<CVIResult?>> {
  UploadController() : super(const AsyncValue.data(null));

  /// Upload an image to the server for CVI detection
  Future<void> uploadImage(File image) async {
    state = const AsyncValue.loading();
    
    try {
      // Get the file extension
      final fileExtension = image.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);
      
      // Create a multipart request
      final uri = Uri.http('10.0.2.2:8000', '/api/detect');
      final request = http.MultipartRequest('POST', uri);
      
      // Add the image file to the request
      final fileStream = http.ByteStream(image.openRead());
      final fileLength = await image.length();
      
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: 'image.$fileExtension',
        contentType: MediaType('image', mimeType),
      );
      
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Handle the response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = CVIResult.fromJson(jsonData);
        state = AsyncValue.data(result);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  /// Reset the state to clear any loaded result
  void reset() {
    state = const AsyncValue.data(null);
  }
  
  /// Get the MIME type from the file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'heic':
        return 'heic';
      default:
        return 'jpeg'; // Default to JPEG
    }
  }
}

/// Provider for the upload controller
final uploadControllerProvider = StateNotifierProvider<UploadController, AsyncValue<CVIResult?>>((ref) {
  return UploadController();
}); 