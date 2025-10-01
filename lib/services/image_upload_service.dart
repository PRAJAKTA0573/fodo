import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:dartz/dartz.dart';

/// Image Upload Service - Handles image compression and Firebase Storage uploads
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Compress image before upload
  Future<Either<String, File>> compressImage(
    File imageFile, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final dir = imageFile.parent;
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed${path.extension(imageFile.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (result == null) {
        return const Left('Failed to compress image');
      }

      return Right(File(result.path));
    } catch (e) {
      return Left('Compression error: ${e.toString()}');
    }
  }

  /// Upload single image to Firebase Storage
  Future<Either<String, String>> uploadImage(
    File imageFile,
    String folder, {
    bool compress = true,
  }) async {
    try {
      File fileToUpload = imageFile;

      // Compress if needed
      if (compress) {
        final compressResult = await compressImage(imageFile);
        fileToUpload = compressResult.fold(
          (error) => imageFile, // Use original if compression fails
          (compressed) => compressed,
        );
      }

      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(fileToUpload.path)}';
      final storageRef = _storage.ref().child('$folder/$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(fileToUpload);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left('Upload failed: ${e.toString()}');
    }
  }

  /// Upload multiple images
  Future<Either<String, List<String>>> uploadMultipleImages(
    List<File> imageFiles,
    String folder, {
    bool compress = true,
  }) async {
    try {
      final urls = <String>[];

      for (final file in imageFiles) {
        final result = await uploadImage(file, folder, compress: compress);
        
        result.fold(
          (error) => throw Exception(error),
          (url) => urls.add(url),
        );
      }

      return Right(urls);
    } catch (e) {
      return Left('Multiple upload failed: ${e.toString()}');
    }
  }

  /// Upload food photos for donation
  Future<Either<String, List<Map<String, dynamic>>>> uploadFoodPhotos(
    List<File> imageFiles,
    String donationId,
  ) async {
    try {
      final photoInfoList = <Map<String, dynamic>>[];

      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];

        // Upload original
        final originalResult = await uploadImage(
          file,
          'donations/$donationId/photos',
          compress: false,
        );

        if (originalResult.isLeft()) {
          return Left('Failed to upload photo ${i + 1}');
        }

        // Upload compressed thumbnail
        final thumbnailResult = await uploadImage(
          file,
          'donations/$donationId/thumbnails',
          compress: true,
        );

        if (thumbnailResult.isLeft()) {
          return Left('Failed to upload thumbnail ${i + 1}');
        }

        final photoInfo = {
          'url': originalResult.getOrElse(() => ''),
          'thumbnailUrl': thumbnailResult.getOrElse(() => ''),
          'uploadedAt': DateTime.now().millisecondsSinceEpoch,
          'fileSize': await file.length(),
        };

        photoInfoList.add(photoInfo);
      }

      return Right(photoInfoList);
    } catch (e) {
      return Left('Photo upload failed: ${e.toString()}');
    }
  }

  /// Delete image from Firebase Storage
  Future<Either<String, void>> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return const Right(null);
    } catch (e) {
      return Left('Delete failed: ${e.toString()}');
    }
  }

  /// Delete multiple images
  Future<Either<String, void>> deleteMultipleImages(List<String> imageUrls) async {
    try {
      for (final url in imageUrls) {
        await deleteImage(url);
      }
      return const Right(null);
    } catch (e) {
      return Left('Multiple delete failed: ${e.toString()}');
    }
  }

  /// Get image file size
  Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Validate image file
  Either<String, bool> validateImage(File imageFile, {int maxSizeMB = 10}) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return const Left('Image file does not exist');
      }

      // Check file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      
      if (!validExtensions.contains(extension)) {
        return const Left('Invalid image format. Allowed: JPG, PNG, GIF, WEBP');
      }

      // Check file size
      final fileSizeInBytes = imageFile.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > maxSizeMB) {
        return Left('Image size exceeds $maxSizeMB MB limit');
      }

      return const Right(true);
    } catch (e) {
      return Left('Validation error: ${e.toString()}');
    }
  }

  /// Validate multiple images
  Either<String, bool> validateImages(
    List<File> imageFiles, {
    int maxSizeMB = 10,
    int maxCount = 5,
  }) {
    if (imageFiles.isEmpty) {
      return const Left('No images provided');
    }

    if (imageFiles.length > maxCount) {
      return Left('Maximum $maxCount images allowed');
    }

    for (var i = 0; i < imageFiles.length; i++) {
      final validation = validateImage(imageFiles[i], maxSizeMB: maxSizeMB);
      if (validation.isLeft()) {
        return Left('Image ${i + 1}: ${validation.fold((l) => l, (r) => "")}');
      }
    }

    return const Right(true);
  }
}
