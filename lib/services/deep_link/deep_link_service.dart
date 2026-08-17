import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';

/// Deep link service - handles multiai:// URLs and universal links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;
  DeepLinkService._();

  /// Parse a deep link URI and return the corresponding action
  DeepLinkAction? parseLink(Uri uri) {
    // Handle multiai:// scheme
    if (uri.scheme == 'multiai') {
      return _parseCustomScheme(uri);
    }

    // Handle universal links (https://multaihub.app/...)
    if (uri.scheme == 'https' && uri.host == 'multaihub.app') {
      return _parseUniversalLink(uri);
    }

    return null;
  }

  /// Parse multiai:// scheme links
  /// Supported paths:
  ///   multiai://provider/{name}     - Open a specific provider
  ///   multiai://ask?prompt={text}   - Ask All mode with prompt
  ///   multiai://compare?a={name1}&b={name2} - Compare two providers
  ///   multiai://favorites           - Open favorites
  DeepLinkAction? _parseCustomScheme(Uri uri) {
    final pathSegments = uri.pathSegments;
    final queryParams = uri.queryParameters;

    if (pathSegments.isEmpty) {
      return const DeepLinkAction(type: DeepLinkType.openHome);
    }

    switch (pathSegments.first) {
      case 'provider':
        if (pathSegments.length >= 2) {
          return DeepLinkAction(
            type: DeepLinkType.openProvider,
            providerName: pathSegments[1],
          );
        }
        break;

      case 'ask':
        return DeepLinkAction(
          type: DeepLinkType.askAll,
          prompt: queryParams['prompt'] ?? '',
          providerNames: queryParams['providers']?.split(','),
        );

      case 'compare':
        return DeepLinkAction(
          type: DeepLinkType.compare,
          providerNames: [
            if (queryParams['a'] != null) queryParams['a']!,
            if (queryParams['b'] != null) queryParams['b']!,
          ],
        );

      case 'favorites':
        return const DeepLinkAction(type: DeepLinkType.openFavorites);

      case 'notes':
        return const DeepLinkAction(type: DeepLinkType.openNotes);

      case 'settings':
        return const DeepLinkAction(type: DeepLinkType.openSettings);
    }

    return null;
  }

  /// Parse universal links (https://multaihub.app/...)
  DeepLinkAction? _parseUniversalLink(Uri uri) {
    // Map web routes to app actions
    final path = uri.path;
    if (path.startsWith('/provider/')) {
      final name = path.substring('/provider/'.length);
      return DeepLinkAction(type: DeepLinkType.openProvider, providerName: name);
    }
    if (path == '/ask') {
      return DeepLinkAction(
        type: DeepLinkType.askAll,
        prompt: uri.queryParameters['prompt'] ?? '',
      );
    }
    return const DeepLinkAction(type: DeepLinkType.openHome);
  }

  /// Generate a shareable deep link for a provider
  String generateProviderLink(AiProvider provider) {
    return 'multiai://provider/${Uri.encodeComponent(provider.name)}';
  }

  /// Generate a shareable "Ask All" link
  String generateAskAllLink(String prompt, {List<String>? providers}) {
    final params = <String, String>{'prompt': prompt};
    if (providers != null && providers.isNotEmpty) {
      params['providers'] = providers.join(',');
    }
    return 'multiai://ask?${Uri(queryParameters: params).query}';
  }

  /// Generate a comparison link
  String generateCompareLink(String providerA, String providerB) {
    return 'multiai://compare?a=${Uri.encodeComponent(providerA)}&b=${Uri.encodeComponent(providerB)}';
  }
}

/// Deep link action types
enum DeepLinkType {
  openHome,
  openProvider,
  openFavorites,
  openNotes,
  openSettings,
  askAll,
  compare,
}

/// Deep link action model
class DeepLinkAction {
  final DeepLinkType type;
  final String? providerName;
  final List<String>? providerNames;
  final String? prompt;

  const DeepLinkAction({
    required this.type,
    this.providerName,
    this.providerNames,
    this.prompt,
  });

  @override
  String toString() => 'DeepLinkAction(type: $type, provider: $providerName, prompt: $prompt)';
}
