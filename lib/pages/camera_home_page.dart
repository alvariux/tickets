import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tickets/services/camara_service.dart';
import 'package:tickets/services/api_service.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraHomePage extends StatefulWidget {
  const CameraHomePage({super.key});

  @override
  State<CameraHomePage> createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  String? _imagePath;
  bool _uploading = false;
  final CamaraService _camara = CamaraService();

  Future<void> _takePhoto() async {
    try {
      final path = await _camara.takePhoto();
      if (!mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se tomó ninguna foto')));
        return;
      }
      final cropped = await _cropImage(File(path));
      if (!mounted) return;
      setState(() => _imagePath = cropped?.path ?? path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al tomar foto: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final path = await _camara.selectPhoto();
      if (!mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se seleccionó ninguna imagen')));
        return;
      }
      final cropped = await _cropImage(File(path));
      if (!mounted) return;
      setState(() => _imagePath = cropped?.path ?? path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e')));
    }
  }

  Future<void> _uploadImage() async {
    if (_imagePath == null) return;
    final file = File(_imagePath!);
    if (!await file.exists()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo de imagen no existe')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final response = await ApiService().uploadImage(file);
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen enviada correctamente')));
      } else {
        // Mostrar body para diagnóstico si hay fallo
        final body = response.body;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: ${response.statusCode}')));
        debugPrint('Upload failed: status=${response.statusCode} body=$body');
      }
    } catch (e, st) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar imagen: $e')));
      debugPrint('Error uploading image: $e');
      debugPrint('$st');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recortar',
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al recortar imagen: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara / Galería')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _imagePath == null
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(child: Text('No hay imagen seleccionada')),
                      )
                    : Image.file(File(_imagePath!), fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar foto'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
                ElevatedButton.icon(
                  onPressed: (_imagePath == null || _uploading) ? null : _uploadImage,
                  icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
                  label: const Text('Enviar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
