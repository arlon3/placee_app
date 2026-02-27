import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pin.dart';

/// 上品で温かみのあるカップル向けマップ日記アプリのテーマ
///
/// デザインコンセプト:
/// - 上品で温かみがある
/// - 少しだけときめく
/// - 写真が主役
/// - 二人の時間を積み重ねるUI
///
/// ターゲット: 20代後半〜30代カップル
class UIUtils {
  // ============================================
  // カラーパレット - くすみ系・温かみのあるトーン
  // ============================================

  /// メインカラー: くすみテラコッタ
  static const Color primaryColor = Color(0xFFBF8B7E);

  /// サブカラー: ソフトテラコッタ
  static const Color secondaryColor = Color(0xFFD4A59A);

  /// アクセントカラー: ダスティブルー
  static const Color accentColor = Color(0xFF8B9FAF);

  /// セージグリーン: 優しい緑
  static const Color sageColor = Color(0xFFA8B5A0);

  /// 背景色: ウォームホワイト/アイボリー
  static const Color backgroundColor = Color(0xFFFAF7F3);

  /// カード背景色
  static const Color cardColor = Color(0xFFFFFFFF);

  /// テキストカラー: ウォームグレー
  static const Color textColor = Color(0xFF4A4645);

  /// サブテキストカラー: ライトウォームグレー
  static const Color subtextColor = Color(0xFF9B8E8A);

  /// 区切り線: 淡いグレー
  static const Color dividerColor = Color(0xFFE8E3E0);

  // ============================================
  // 投稿タイプ別の色（ピンの形を決定）
  // ============================================

  /// 行った（visited）: くすみテラコッタ
  static const Color visitedColor = Color(0xFFBF8B7E);

  /// 行きたい（wantToGo）: ダスティブルー
  static const Color wantToGoColor = Color(0xFF8B9FAF);

  /// 日記用: くすみローズ
  static const Color diaryColor = Color(0xFFD4A59A);

  // ============================================
  // カテゴリ別の色（ピンの色を決定）- 低彩度トーン
  // ============================================

  /// ご飯: くすみテラコッタ
  static const Color foodColor = Color(0xFFBF8B7E);

  /// 遊び: くすみイエロー
  static const Color entertainmentColor = Color(0xFFD4B88A);

  /// 観光: セージグリーン
  static const Color sightseeingColor = Color(0xFFA8B5A0);

  /// 景色: ダスティブルー
  static const Color sceneryColor = Color(0xFF8B9FAF);

  /// お店: くすみラベンダー
  static const Color shopColor = Color(0xFFB5A8B8);

  /// その他: ニュートラルグレー
  static const Color otherColor = Color(0xFFA39C99);

  // ============================================
  // Light Theme
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: secondaryColor,
        secondary: accentColor,
        secondaryContainer: sageColor,
        surface: cardColor,
        background: backgroundColor,
        error: Color(0xFFB85454),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),

      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.notoSansJp(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.notoSansJp(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineLarge: GoogleFonts.notoSansJp(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.notoSansJp(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineSmall: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleMedium: GoogleFonts.notoSansJp(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.notoSansJp(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: subtextColor,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        labelMedium: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: subtextColor,
        ),
        labelSmall: GoogleFonts.notoSansJp(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: subtextColor,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB85454)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB85454), width: 1.5),
        ),
        labelStyle: GoogleFonts.notoSansJp(
          color: subtextColor,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.notoSansJp(
          color: subtextColor,
          fontSize: 14,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        selectedItemColor: primaryColor,
        unselectedItemColor: subtextColor,
        selectedLabelStyle: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // ============================================
  // Dark Theme
  // ============================================

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF1E1B1A);
    const darkSurface = Color(0xFF2A2624);
    const darkPrimary = Color(0xFFD4A59A);
    const darkAccent = Color(0xFFA4B5C5);
    const darkText = Color(0xFFE8E3E0);
    const darkSubtext = Color(0xFF9B8E8A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: Color(0xFF4A3F3B),
        secondary: darkAccent,
        secondaryContainer: Color(0xFF3A4149),
        surface: darkSurface,
        background: darkBackground,
        error: Color(0xFFCF6679),
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onSurface: darkText,
        onBackground: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkBackground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.notoSansJp(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkText,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkText,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkSubtext,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkSubtext,
        selectedLabelStyle: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // ============================================
  // 共通ウィジェット - 控えめな装飾
  // ============================================

  /// カード作成（薄い影、控えめな角丸）
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      color: color ?? cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// セクション作成
  static Widget buildSection({
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansJp(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }

  /// SnackBar表示
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansJp(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFB85454) : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 確認ダイアログ
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
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.notoSansJp(
            fontSize: 14,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ============================================
  // カテゴリヘルパー
  // ============================================

  /// カテゴリに応じた色を取得（PostCategoryから）
  static Color getCategoryColorFromEnum(PostCategory category) {
    switch (category) {
      case PostCategory.food:
        return foodColor;
      case PostCategory.entertainment:
        return entertainmentColor;
      case PostCategory.sightseeing:
        return sightseeingColor;
      case PostCategory.scenery:
        return sceneryColor;
      case PostCategory.shop:
        return shopColor;
      case PostCategory.other:
        return otherColor;
    }
  }

  /// カテゴリの表示名を取得（PostCategoryから）
  static String getCategoryLabelFromEnum(PostCategory category) {
    switch (category) {
      case PostCategory.food:
        return 'ご飯';
      case PostCategory.entertainment:
        return '遊び';
      case PostCategory.sightseeing:
        return '観光';
      case PostCategory.scenery:
        return '景色';
      case PostCategory.shop:
        return 'お店';
      case PostCategory.other:
        return 'その他';
    }
  }

  /// カテゴリに応じた色を取得
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

  /// カテゴリの表示名を取得
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

  // ============================================
  // アニメーション定義
  // ============================================

  /// 標準アニメーション時間
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// 高速アニメーション時間
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);

  /// 低速アニメーション時間
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// 標準カーブ
  static const Curve animationCurve = Curves.easeInOutCubic;

  /// イーズインカーブ
  static const Curve easeInCurve = Curves.easeIn;

  /// イーズアウトカーブ
  static const Curve easeOutCurve = Curves.easeOut;
}
