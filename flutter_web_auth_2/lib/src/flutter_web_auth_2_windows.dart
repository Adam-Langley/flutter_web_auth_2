import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_protocol/url_protocol.dart';
import 'package:window_to_front/window_to_front.dart';

/// Implements the plugin interface for Windows.
class FlutterWebAuth2WindowsPlugin extends FlutterWebAuth2Platform {
  StreamSubscription<String>? _linkSubscription;
  late AppLinks _appLinks;

  /// Registers the Windows implementation.
  static void registerWith() {
    FlutterWebAuth2Platform.instance = FlutterWebAuth2WindowsPlugin();
  }

  void _registerWindowsProtocol(String callbackUrlScheme) {
    // Register our protocol only on Windows platform
    if (!kIsWeb) {
      registerProtocolHandler(
        callbackUrlScheme,
      );
    }
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
    String? redirectOriginOverride,
    List contextArgs = const [],
  }) async {
    // Validate callback url
    final callbackUri = Uri.parse(callbackUrlScheme);
    final resultCompleter = Completer<String>();

    // Register our protocol only on Windows platform
    _registerWindowsProtocol(callbackUri.toString());

    // Handle link when app is in warm state (front or background)
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.stringLinkStream.listen((uri) async {
      await WindowToFront.activate();
      resultCompleter.complete(uri);
    });

    await launchUrl(Uri.parse(url));

    return resultCompleter.future;
  }

  @override
  Future clearAllDanglingCalls() async {
    await _linkSubscription?.cancel();
  }
}
