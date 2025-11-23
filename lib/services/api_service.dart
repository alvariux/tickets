import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:tickets/config/app_config.dart';
import 'package:tickets/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  /// Sube una imagen al endpoint configurado en AppConfig.getApiUrl().
  /// Devuelve el http.Response para permitir al llamador inspeccionar el código.
  Future<http.Response> uploadImage(File imageFile) async {
    final uriStr = await AppConfig.getApiUrl();
    final uri = Uri.parse(uriStr);

    final request = http.MultipartRequest('POST', uri);

    // Información de diagnóstico en logs: URI destino y si hay API key disponible
    debugPrint('ApiService: upload to $uri');

    // Preferencia: si el usuario guardó una API key en storage úsala,
    // si no, intenta leer `API_KEY` desde el archivo .env cargado con flutter_dotenv.
    String? storedKey;
    try {
      storedKey = await _storage.getApiKey();
    } catch (e, st) {
      debugPrint('StorageService.getApiKey failed: $e');
      debugPrint('$st');
      storedKey = null;
    }
    String? envKey;
    try {
      envKey = dotenv.env['API_KEY'];
    } catch (e) {
      // dotenv not initialized — ignore and fallback to storedKey or default
      envKey = null;
    }
    final String? apiKey = storedKey ?? envKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      final source = storedKey != null ? 'Storage' : 'dotenv';
      debugPrint('ApiService: using API key from $source');
      request.headers['Authorization'] = 'Bearer $apiKey';
    }

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');

    http.ByteStream fileStream;
    int length;
    try {
      fileStream = http.ByteStream(imageFile.openRead());
      length = await imageFile.length();
    } catch (e, st) {
      // Mejor detalle en caso de fallo al abrir/leer el archivo
      throw Exception('Failed to read image file: $e\n$st');
    }

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: imageFile.path.split(Platform.pathSeparator).last,
      contentType: MediaType(parts[0], parts[1]),
    );

    request.files.add(multipartFile);

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return response;
    } catch (e, st) {
      // Propaga con más contexto para ayudar al diagnóstico
      throw Exception('Failed to send multipart request: $e\n$st');
    }
  }
}
