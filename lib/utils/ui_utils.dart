import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIUtils {
  // カラーパレット - つやっとしたポップで可愛いデザイン
  static const Color primaryColor = Color(0xFFFF6B9D); // ビビッドピンク
  static const Color secondaryColor = Color(0xFFFFC2E2); // 淡いピンク
  static const Color accentColor = Color(0xFFFFE5B4); // クリーム色
  static const Color backgroundColor = Color(0xFFFFFBF5); // アイボリーホワイト
  static const Color cardColor = Color(0xFFFFFFFF); // 純白
  static const Color textColor = Color(0xFF2D2D2D);
  static const Color subtextColor = Color(0xFF9E9E9E);

  // 投稿タイプ別の色（ピンの形を決定）
  static const Color visitedColor = Color(0xFFFF6B9D); // ビビッドピンク（行った）
  static const Color wantToGoColor = Color(0xFF74D7FF); // スカイブルー（行きたい）
  static const Color diaryColor = Color(0xFFFF6B9D); // ピンク（日記用）

  // カテゴリ別の色（ピンの色を決定）- より鮮やかでポップに
  static const Color foodColor = Color(0xFFFF8A5C); // コーラルオレンジ（ご飯）
  static const Color entertainmentColor = Color(0xFFFFD93D); // サンイエロー（遊び）
  static const Color sightseeingColor = Color(0xFF6BCB77); // フレッシュグリーン（観光）
  static const Color sceneryColor = Color(0xFF6AAEFF); // スカイブルー（景色）
  static const Color shopColor = Color(0xFFBB8FCE); // ラベンダーパープル（お店）
  static const Color otherColor = Color(0xFFAAB7B8); // ライトグレー（その他）

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
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              cardColor.withOpacity(0.95),
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
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

  // カテゴリに応じた色を取得
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'food':
        return foodColor;
      case 'entertainment':
        return entertainmentColor;
      case 'sightseeing':
        return sightseeingColor;
      case 'scenery':
        return sceneryColor;
      case 'shop':
        return shopColor;
      default:
        return otherColor;
    }
  }

  // カテゴリの表示名を取得
  static String getCategoryLabel(String category) {
    switch (category) {
      case 'food':
        return 'ご飯';
      case 'entertainment':
        return '遊び';
      case 'sightseeing':
        return '観光';
      case 'scenery':
        return '景色';
      case 'shop':
        return 'お店';
      case 'other':
        return 'その他';
      default:
        return category;
    }
  }
}
