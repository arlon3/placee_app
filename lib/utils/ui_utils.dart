import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIUtils {
  // カラーパレット - ピンク＆白の清潔感あるデザイン
  static const Color primaryColor = Color(0xFFFF69B4); // ホットピンク
  static const Color secondaryColor = Color(0xFFFFB6D9); // ライトピンク
  static const Color accentColor = Color(0xFFFF1493); // ディープピンク
  static const Color backgroundColor = Color(0xFFFFFFFF); // 純白
  static const Color cardColor = Color(0xFFFFFAFC); // ごく薄いピンク
  static const Color textColor = Color(0xFF333333);
  static const Color subtextColor = Color(0xFF999999);

  // ピンカテゴリ色
  static const Color visitedColor = Color(0xFFFF69B4); // ホットピンク
  static const Color wantToGoColor = Color(0xFF87CEEB); // スカイブルー
  static const Color diaryColor = Color(0xFFFFB6D9); // ライトピンク

  // テーマデータ
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.mPlusRounded1c(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.mPlusRounded1c(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.mPlusRounded1c(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: GoogleFonts.mPlusRounded1c(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.notoSansJp(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: 14,
          color: textColor,
        ),
        labelSmall: GoogleFonts.notoSansJp(
          fontSize: 12,
          color: subtextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.notoSansJp(
          color: textColor,
        ),
        hintStyle: GoogleFonts.notoSansJp(
          color: subtextColor,
        ),
      ),
    );
  }

  // 共通ウィジェット
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  static Widget buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        child,
      ],
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansJp(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'キャンセル',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.mPlusRounded1c(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.notoSansJp(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: GoogleFonts.notoSansJp(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: GoogleFonts.notoSansJp(),
            ),
          ),
        ],
      ),
    );
  }
}
