import 'package:flutter/material.dart';

class AppColors {

  // ── Base Palette ─────────────────────────────────────
  static const Color black       = Color(0xFF000000);
  static const Color darkGrey    = Color(0xFF212121);
  static const Color darkForest  = Color(0xFF12372A);
  static const Color forest      = Color(0xFF40513B);
  static const Color green       = Color(0xFF306D29);
  static const Color sage        = Color(0xFF9DC08B);
  static const Color lightGrey   = Color(0xFFF5F5F5);
  static const Color cream       = Color(0xFFF6F7D7);
  static const Color softYellow  = Color(0xFFFFF9B0);
  static const Color amber       = Color(0xFFFFC94D);
  static const Color yellow      = Color(0xFFF4CE14);
  static const Color brightYellow = Color(0xFFF7FD04);
  static const Color salmon      = Color(0xFFF38181);
  static const Color lightRed    = Color(0xFFFF9999);
  static const Color red         = Color(0xFFDA0037);
  static const Color peach       = Color(0xFFE89F71);
  static const Color lightPeach  = Color(0xFFFFC6AC);
  static const Color pink        = Color(0xFFF875AA);

  // ── Dark Theme ───────────────────────────────────────
  static const Color darkBg0     = black;
  static const Color darkBg1     = darkGrey;
  static const Color darkBg2     = Color(0xFF2A2A2A);
  static const Color darkBg3     = Color(0xFF333333);

  static const Color darkText1   = lightGrey;
  static const Color darkText2   = sage;
  static const Color darkText3   = Color(0xFF888888);

  static const Color darkBorder  = Color(0x1AFFFFFF);
  static const Color darkBorder2 = Color(0x28FFFFFF);
  static const Color darkGlass   = Color(0x0AFFFFFF);
  static const Color darkGlass2  = Color(0x12FFFFFF);

  // ── Light Theme ──────────────────────────────────────
  static const Color lightBg0    = lightGrey;
  static const Color lightBg1    = Color(0xFFFFFFFF);
  static const Color lightBg2    = cream;
  static const Color lightBg3    = softYellow;

  static const Color lightText1  = darkGrey;
  static const Color lightText2  = forest;
  static const Color lightText3  = Color(0xFF666666);

  static const Color lightBorder  = Color(0x1A40513B);
  static const Color lightBorder2 = Color(0x2840513B);
  static const Color lightGlass1  = Color(0x0A000000);
  static const Color lightGlass2  = Color(0x0F000000);

  // ── Semantic (shared) ────────────────────────────────
  static const Color income    = green;
  static const Color expense   = red;
  static const Color transfer  = amber;

  static const Color success   = green;
  static const Color warning   = amber;
  static const Color error     = red;
  static const Color info      = sage;

  // ── Keep old aliases (so existing code doesn't break) ─
  static const Color bg0    = darkBg0;
  static const Color bg1    = darkBg1;
  static const Color bg2    = darkBg2;
  static const Color bg3    = darkBg3;
  static const Color white1 = darkText1;
  static const Color white2 = darkText2;
  static const Color border  = darkBorder;
  static const Color border2 = darkBorder2;
  static const Color glass   = darkGlass;
  static const Color glass2  = darkGlass2;
}
