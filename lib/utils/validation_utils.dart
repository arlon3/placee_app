import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ValidationUtils {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'タイトルを入力してください';
    }
    if (value.length > 100) {
      return 'タイトルは100文字以内で入力してください';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 1000) {
      return '説明は1000文字以内で入力してください';
    }
    return null;
  }

  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'コメントを入力してください';
    }
    if (value.length > 500) {
      return 'コメントは500文字以内で入力してください';
    }
    return null;
  }

  // URL検出と自動リンク化
  static final RegExp _urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  static bool containsUrl(String text) {
    return _urlRegex.hasMatch(text);
  }

  static List<String> extractUrls(String text) {
    return _urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  static TextSpan buildLinkifiedText(
    String text, {
    TextStyle? style,
    TextStyle? linkStyle,
  }) {
    final spans = <InlineSpan>[];
    final matches = _urlRegex.allMatches(text);
    
    int currentPosition = 0;
    
    for (final match in matches) {
      // URLの前のテキスト
      if (match.start > currentPosition) {
        spans.add(TextSpan(
          text: text.substring(currentPosition, match.start),
          style: style,
        ));
      }
      
      // URL部分
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: linkStyle ?? 
            (style?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ) ?? 
            const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            )),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _launchUrl(url),
      ));
      
      currentPosition = match.end;
    }
    
    // 残りのテキスト
    if (currentPosition < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPosition),
        style: style,
      ));
    }
    
    return TextSpan(children: spans);
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
