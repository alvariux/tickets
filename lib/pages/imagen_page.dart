import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tickets/services/api_service.dart';
import 'package:tickets/services/storage_service.dart';
import 'package:tickets/config/app_config.dart';

class ImagenPage extends StatefulWidget {
  const ImagenPage({super.key});

  @override
  State<ImagenPage> createState() => _ImagenPageState();
}

class _ImagenPageState extends State<ImagenPage> {
  File? _imageFile;
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    File? cropped = await _cropImage(File(picked.path));
    if (!mounted) return;
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recortar',
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<void> _upload() async {
    if (_imageFile == null) return;
    setState(() => _uploading = true);
    try {
      final response = await ApiService().uploadImage(_imageFile!);
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen subida correctamente')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir: ${response.statusCode}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _setApiKey() async {
    final controller = TextEditingController();
    final stored = await StorageService().getApiKey();
    if (stored != null) controller.text = stored;

    final res = await showDialog<bool>( // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'API Key'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Guardar')),
        ],
      ),
    );
    if (!mounted) return;
    if (res == true) {
      await StorageService().setApiKey(controller.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key guardada de forma segura')));
    }
  }

  Future<void> _setApiUrlOverride() async {
    final controller = TextEditingController();
    final stored = await StorageService().getApiUrlOverride();
    if (stored != null) controller.text = stored;

    final res = await showDialog<bool>( // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Endpoint URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'URL del endpoint'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Guardar')),
        ],
      ),
    );
    if (!mounted) return;
    if (res == true) {
      await StorageService().setApiUrlOverride(controller.text.trim());
      final url = await AppConfig.getApiUrl();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Endpoint actualizado: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_imageFile != null)
            Image.file(_imageFile!, height: 300, fit: BoxFit.contain)
          else
            Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: Text('Ninguna imagen seleccionada')),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.crop_rotate),
                label: const Text('Recortar/Rotar'),
                onPressed: _imageFile == null ? null : () async {
                  final cropped = await _cropImage(_imageFile!);
                  if (!mounted) return;
                  if (cropped != null) setState(() => _imageFile = cropped);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: _uploading ? const Text('Subiendo...') : const Text('Subir imagen'),
                  onPressed: (_imageFile == null || _uploading) ? null : _upload,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _setApiKey,
                  child: const Text('Configurar API Key (seguro)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _setApiUrlOverride,
                  child: const Text('Cambiar endpoint'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: AppConfig.getApiUrl(),
            builder: (context, snapshot) {
              final url = snapshot.data ?? 'Cargando...';
              return Text('Endpoint actual: $url', style: const TextStyle(fontSize: 12));
            },
          ),
        ],
      ),
    );
  }
}

