import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import '../domain/utils/alerts.dart';
import '../presentation/localization/localization_keys.dart';
import '../presentation/theme/color_manager.dart';

class MediaUtils with Alerts {
  static final MediaUtils _instance = MediaUtils._();

  MediaUtils._();

  factory MediaUtils() => _instance;

  Future<String?> cropImage(File imageFile) async {
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: LocalizationKeys.editImage.tr,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: ColorManager().primary,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x4,
          ],
        ),
        IOSUiSettings(
          title: LocalizationKeys.editImage.tr,
          doneButtonTitle: LocalizationKeys.save.tr,
          cancelButtonTitle: LocalizationKeys.cancel.tr,
          showCancelConfirmationDialog: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x4,
          ],
        ),
      ],
    );
    return croppedImg?.path;
  }
}
