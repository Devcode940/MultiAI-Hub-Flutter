import 'package:flutter/material.dart';
import 'package:multiai_hub/app.dart';
import 'package:multiai_hub/services/deep_link/deep_link_service.dart';

/// Global key for navigation - used by deep links
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Callbacks for deep link navigation - set by app.dart
Function(int)? onNavigateToTab;
Function(String)? onAskAllWithPrompt;
Function(List<String>)? onCompareProviders;

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
Future<void> _handleDeepLinkAction(DeepLinkAction action) async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  switch (action.type) {
    case DeepLinkType.openHome:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(0);
      break;

    case DeepLinkType.openProvider:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(0);
      break;

    case DeepLinkType.openFavorites:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(0);
      break;

    case DeepLinkType.openNotes:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(5);
      break;

    case DeepLinkType.openSettings:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(7);
      break;

    case DeepLinkType.askAll:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(2);
      if (action.prompt != null && action.prompt!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          onAskAllWithPrompt?.call(action.prompt!);
        });
      }
      break;

    case DeepLinkType.compare:
      navigator.popUntil((route) => route.isFirst);
      onNavigateToTab?.call(6);
      if (action.providerNames != null && action.providerNames!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          onCompareProviders?.call(action.providerNames!);
        });
      }
      break;
  }
}
