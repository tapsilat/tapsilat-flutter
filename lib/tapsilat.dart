import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tapsilat plugin entry point.
class Tapsilat {
  Tapsilat._();

  static final Tapsilat instance = Tapsilat._();

  static const MethodChannel _channel = MethodChannel('tapsilat');

  /// Returns a human readable platform version, when supported by the host
  /// platform. Throws [PlatformException] for unsupported platforms.
  Future<String?> getPlatformVersion() async {
    final supportedPlatforms = {
      TargetPlatform.windows,
      TargetPlatform.linux,
    };

    if (kIsWeb || !supportedPlatforms.contains(defaultTargetPlatform)) {
      throw PlatformException(
        code: 'unimplemented',
        message:
            'getPlatformVersion() has not been implemented on this platform.',
      );
    }

    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
