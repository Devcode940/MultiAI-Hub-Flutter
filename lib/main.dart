import 'package:flutter/material.dart';
import 'package:multiai_hub/app.dart';
import 'package:multiai_hub/services/deep_link/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize deep link handling
  _initDeepLinks();

  runApp(const MultiAIHubApp());
}

/// Initialize deep link listener
void _initDeepLinks() {
  // In production, use app_links or uni_links:
  // final _appLinks = AppLinks();
  // _appLinks.uriLinkStream.listen((uri) {
  //   final action = DeepLinkService.instance.parseLink(uri);
  //   if (action != null) {
  //     _handleDeepLinkAction(action);
  //   }
  // });
}

/// Handle a deep link action by navigating to the appropriate screen
void _handleDeepLinkAction(DeepLinkAction action) {
  // This would use a global navigator key to navigate
  switch (action.type) {
    case DeepLinkType.openHome:
      // Navigate to home
      break;
    case DeepLinkType.openProvider:
      // Navigate to provider WebView
      break;
    case DeepLinkType.openFavorites:
      // Navigate to home with favorites filter
      break;
    case DeepLinkType.openNotes:
      // Navigate to notes
      break;
    case DeepLinkType.openSettings:
      // Navigate to settings
      break;
    case DeepLinkType.askAll:
      // Navigate to Ask All screen with pre-filled prompt
      break;
    case DeepLinkType.compare:
      // Navigate to comparison with specified providers
      break;
  }
}
