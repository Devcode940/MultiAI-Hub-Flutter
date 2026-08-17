import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security service - URL encryption, SSL pinning, session isolation
class SecurityService {
  static final SecurityService _instance = SecurityService._();
  static SecurityService get instance => _instance;
  SecurityService._();

  // Simple XOR-based encryption key (in production, use flutter_secure_storage)
  static const _encryptionKey = 'MultiAI_Hub_2024_SecretKey!';

  /// Encrypt a string (URL or sensitive data) for storage at rest
  String encrypt(String plaintext) {
    final keyBytes = utf8.encode(_encryptionKey);
    final plainBytes = utf8.encode(plaintext);
    final encrypted = <int>[];

    for (int i = 0; i < plainBytes.length; i++) {
      encrypted.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(Uint8List.fromList(encrypted));
  }

  /// Decrypt a string
  String decrypt(String ciphertext) {
    try {
      final keyBytes = utf8.encode(_encryptionKey);
      final encrypted = base64Decode(ciphertext);
      final decrypted = <int>[];

      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      debugPrint('SecurityService: Decryption failed: $e');
      return '';
    }
  }

  /// Encrypt and store a URL in SharedPreferences
  Future<void> storeEncryptedUrl(String key, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = encrypt(url);
    await prefs.setString('enc_$key', encrypted);
  }

  /// Retrieve and decrypt a URL from SharedPreferences
  Future<String> retrieveEncryptedUrl(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString('enc_$key') ?? '';
    if (encrypted.isEmpty) return '';
    return decrypt(encrypted);
  }

  /// SSL certificate pinning configuration for known AI providers
  static const Map<String, List<String>> _pinnedCertificates = {
    'chat.openai.com': [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Replace with real hash
    ],
    'claude.ai': [],
    'gemini.google.com': [],
    'www.perplexity.ai': [],
  };

  /// Check if a domain has certificate pinning configured
  bool hasPinnedCertificate(String domain) {
    return _pinnedCertificates.containsKey(domain);
  }

  /// Validate a domain against pinned certificates
  /// In production, this would use SecurityContext.withTrustedCertificates()
  bool validateCertificate(String domain) {
    final pinned = _pinnedCertificates[domain];
    if (pinned == null || pinned.isEmpty) return true; // No pinning = allow
    // In production: compare actual cert hash against pinned hashes
    return true;
  }

  /// Session isolation - generate unique session identifier per provider
  String generateSessionId(String providerUrl) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final domain = Uri.parse(providerUrl).host;
    return 'session_${domain}_$timestamp';
  }

  /// Content Security Policy headers for WebView
  static const String cspHeader =
      "default-src 'self' https:; "
      "script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; "
      "style-src 'self' 'unsafe-inline' https:; "
      "img-src 'self' https: data: blob:; "
      "connect-src 'self' https: wss:; "
      "frame-ancestors 'none'; "
      "form-action 'self' https:; "
      "base-uri 'self';";

  /// Validate URL against all security rules
  SecurityValidationResult validateUrl(String url) {
    // Check for empty URL
    if (url.trim().isEmpty) {
      return SecurityValidationResult(isValid: false, reason: 'URL is empty');
    }

    // Check max length
    if (url.length > 2048) {
      return SecurityValidationResult(isValid: false, reason: 'URL exceeds 2048 characters');
    }

    // Block dangerous schemes
    final dangerousSchemes = ['javascript:', 'file:', 'content:', 'data:', 'intent:', 'blob:'];
    for (final scheme in dangerousSchemes) {
      if (url.startsWith(scheme)) {
        return SecurityValidationResult(isValid: false, reason: 'Dangerous scheme blocked: $scheme');
      }
    }

    // Enforce HTTPS
    if (url.startsWith('http://')) {
      return SecurityValidationResult(
        isValid: false,
        reason: 'HTTP is not allowed; use HTTPS',
        suggestedFix: url.replaceFirst('http://', 'https://'),
      );
    }

    // Add HTTPS if no scheme
    if (!url.startsWith('https://')) {
      return SecurityValidationResult(
        isValid: true,
        suggestedFix: 'https://$url',
      );
    }

    // Validate URL format
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        return SecurityValidationResult(isValid: false, reason: 'Invalid URL: no host');
      }
    } catch (e) {
      return SecurityValidationResult(isValid: false, reason: 'Invalid URL format');
    }

    return const SecurityValidationResult(isValid: true);
  }
}

/// Security validation result
class SecurityValidationResult {
  final bool isValid;
  final String? reason;
  final String? suggestedFix;

  const SecurityValidationResult({
    required this.isValid,
    this.reason,
    this.suggestedFix,
  });
}
