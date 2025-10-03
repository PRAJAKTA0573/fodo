import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';

/// Image Picker Page - Select photos from camera or gallery
class ImagePickerPage extends StatefulWidget {
  final int maxImages;

  const ImagePickerPage({
    super.key,
    this.maxImages = 5,
  });

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _pickFromCamera() async {
    // Check camera permission
    final status = await Permission.camera.request();
    
    if (!status.isGranted) {
      if (mounted) {
        _showError('Camera permission denied');
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      final img_picker.XFile? image = await _picker.pickImage(
        source: img_picker.ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Failed to capture photo: ${e.toString()}');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    // Check photo permission
    final status = await Permission.photos.request();
    
    if (!status.isGranted) {
      // Try storage permission for Android
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        if (mounted) {
          _showError('Gallery permission denied');
        }
        return;
      }
    }

    try {
      setState(() => _isLoading = true);

      final int remainingSlots = widget.maxImages - _selectedImages.length;

      if (remainingSlots == 1) {
        // Pick single image
        final img_picker.XFile? image = await _picker.pickImage(
          source: img_picker.ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImages.add(File(image.path));
          });
        }
      } else {
        // Pick multiple images
        final List<img_picker.XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (images.isNotEmpty) {
          // Take only the allowed number of images
          final imagesToAdd = images.take(remainingSlots).toList();
          
          setState(() {
            _selectedImages.addAll(
              imagesToAdd.map((xfile) => File(xfile.path)).toList(),
            );
          });

          if (images.length > remainingSlots) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Only ${remainingSlots} images added. Maximum ${widget.maxImages} allowed.',
                  ),
                ),
              );
            }
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Failed to pick images: ${e.toString()}');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _done() {
    if (_selectedImages.isEmpty) {
      _showError('Please select at least one photo');
      return;
    }
    Navigator.pop(context, _selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = _selectedImages.length < widget.maxImages;

    if (!AppConstants.imagesEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Photos'),
        ),
        body: Center(
          child: Text(
            'Photo selection is disabled',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Photos (${_selectedImages.length}/${widget.maxImages})'),
        actions: [
          if (_selectedImages.isNotEmpty)
            TextButton(
              onPressed: _done,
              child: const Text('Done'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selected Images Grid
                if (_selectedImages.isNotEmpty)
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return _buildImageTile(_selectedImages[index], index);
                      },
                    ),
                  ),

                // Empty State
                if (_selectedImages.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No photos selected',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add photos using the buttons below',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!canAddMore)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[900]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Maximum ${widget.maxImages} photos allowed',
                                  style: TextStyle(color: Colors.orange[900]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: canAddMore ? _pickFromCamera : null,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: canAddMore ? _pickFromGallery : null,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageTile(File image, int index) {
    return GestureDetector(
      onTap: () => _showImagePreview(image, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Image number
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(File image, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Photo ${index + 1}'),
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Navigator.pop(context);
                    _removeImage(index);
                  },
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
