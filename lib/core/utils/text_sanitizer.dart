import 'dart:convert';

/// Utility class for sanitizing text to prevent UTF-16 encoding issues
class TextSanitizer {
  /// Sanitizes text to ensure it's valid UTF-16
  /// Removes or replaces invalid characters that could cause ArgumentError
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    try {
      // First, try to encode and decode to catch any encoding issues
      final bytes = utf8.encode(text);
      final decoded = utf8.decode(bytes, allowMalformed: true);

      // Remove only the most problematic characters, preserve emojis
      String sanitized = decoded
          .replaceAll('\x00', '') // Remove null characters
          .replaceAll('\uFFFD', ''); // Remove replacement characters

      // Remove only invalid surrogate pairs, not all surrogate pairs
      sanitized = _removeInvalidSurrogatePairs(sanitized);

      // Additional check for any remaining problematic characters
      // Note: We don't call _removeInvalidUtf16Characters here anymore
      // because it removes all surrogate pairs including valid emojis

      return sanitized.trim();
    } catch (e) {
      // If encoding/decoding fails, return a safe fallback
      return _createSafeFallback(text);
    }
  }

  /// Checks if a code unit is valid UTF-16
  static bool _isValidUtf16CodeUnit(int codeUnit) {
    // Valid UTF-16 code units are in the range 0x0000 to 0xFFFF
    // except for surrogate pairs (0xD800-0xDFFF)
    return codeUnit >= 0x0000 &&
        codeUnit <= 0xFFFF &&
        !(codeUnit >= 0xD800 && codeUnit <= 0xDFFF);
  }

  /// Removes only invalid surrogate pairs, preserves valid emojis
  static String _removeInvalidSurrogatePairs(String text) {
    final List<int> result = [];

    for (int i = 0; i < text.length; i++) {
      final int codeUnit = text.codeUnitAt(i);

      // Check if it's a high surrogate (start of surrogate pair)
      if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
        // Check if next character is a low surrogate
        if (i + 1 < text.length) {
          final int nextCodeUnit = text.codeUnitAt(i + 1);
          if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
            // Valid surrogate pair - keep both characters
            result.add(codeUnit);
            result.add(nextCodeUnit);
            i++; // Skip next character since we already processed it
            continue;
          }
        }
        // Invalid high surrogate - remove it
        continue;
      }

      // Check if it's a low surrogate without a high surrogate
      if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) {
        // Invalid low surrogate - remove it
        continue;
      }

      // Valid character - keep it
      result.add(codeUnit);
    }

    return String.fromCharCodes(result);
  }

  /// Creates a safe fallback text when sanitization fails
  static String _createSafeFallback(String originalText) {
    // Try to extract any readable ASCII characters
    final asciiChars = originalText.codeUnits
        .where((codeUnit) => codeUnit >= 32 && codeUnit <= 126)
        .map((codeUnit) => String.fromCharCode(codeUnit))
        .join();

    return asciiChars.isNotEmpty ? asciiChars : 'Invalid text';
  }

  /// Sanitizes text for display in Text widgets
  /// This is a more aggressive sanitization for UI display
  static String sanitizeForDisplay(String? text) {
    final sanitized = sanitizeText(text);

    if (sanitized.isEmpty) {
      return '';
    }

    // Additional checks for display-specific issues
    return sanitized
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll('\t', ' ') // Replace tabs with spaces
        .replaceAll('\r', '') // Remove carriage returns
        .replaceAll('\n', ' ') // Replace newlines with spaces
        .trim();
  }

  /// Sanitizes text for user input
  /// This is a lighter sanitization for user input fields
  static String sanitizeForInput(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    try {
      // Remove only the most problematic characters
      String sanitized = text
          .replaceAll('\x00', '') // Remove null characters
          .replaceAll('\uFFFD', ''); // Remove replacement characters

      // Check if the result is valid UTF-16
      final bytes = utf8.encode(sanitized);
      utf8.decode(bytes, allowMalformed: true);

      return sanitized;
    } catch (e) {
      return _createSafeFallback(text);
    }
  }

  /// Validates if text is safe for display
  static bool isValidForDisplay(String? text) {
    if (text == null || text.isEmpty) {
      return true;
    }

    try {
      final bytes = utf8.encode(text);
      utf8.decode(bytes, allowMalformed: true);

      // Check for problematic characters
      for (int i = 0; i < text.length; i++) {
        final int codeUnit = text.codeUnitAt(i);
        if (!_isValidUtf16CodeUnit(codeUnit)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Truncates text safely to a maximum length
  static String truncateText(String? text, int maxLength) {
    final sanitized = sanitizeText(text);

    if (sanitized.length <= maxLength) {
      return sanitized;
    }

    // Truncate and add ellipsis
    return '${sanitized.substring(0, maxLength - 3)}...';
  }
}
