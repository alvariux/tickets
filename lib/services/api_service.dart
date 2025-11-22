import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tickets/config/app_config.dart';
import 'package:tickets/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Future<http.Response> uploadImage(File imageFile) async {
    final uriStr = await AppConfig.getApiUrl();
    final uri = Uri.parse(uriStr);

    final request = http.MultipartRequest('POST', uri);

    final apiKey = await _storage.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $apiKey';
    }

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');

    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: imageFile.path.split(Platform.pathSeparator).last,
      contentType: MediaType(parts[0], parts[1]),
    );

    request.files.add(multipartFile);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return response;
  }
}
