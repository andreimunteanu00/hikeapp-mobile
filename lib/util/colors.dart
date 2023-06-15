import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE6E7E8),
  100: Color(0xFFBFC4C7),
  200: Color(0xFF959CA1),
  300: Color(0xFF6B747B),
  400: Color(0xFF4B575F),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF26333D),
  700: Color(0xFF202C34),
  800: Color(0xFF1A242C),
  900: Color(0xFF10171E),
});
const int _primaryPrimaryValue = 0xFF2B3943;

const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF61B0FF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF007DFA),
  700: Color(0xFF0070E0),
});
const int _primaryAccentValue = 0xFF2E96FF;

const MaterialColor background = MaterialColor(_backgroundPrimaryValue, <int, Color>{
  50: Color(0xFFECF1EE),
  100: Color(0xFFCFDCD4),
  200: Color(0xFFB0C4B7),
  300: Color(0xFF90AC9A),
  400: Color(0xFF789B84),
  500: Color(_backgroundPrimaryValue),
  600: Color(0xFF588166),
  700: Color(0xFF4E765B),
  800: Color(0xFF446C51),
  900: Color(0xFF33593F),
});
const int _backgroundPrimaryValue = 0xFF60896E;

const MaterialColor backgroundAccent = MaterialColor(_backgroundAccentValue, <int, Color>{
  100: Color(0xFFA9FFC3),
  200: Color(_backgroundAccentValue),
  400: Color(0xFF43FF7B),
  700: Color(0xFF2AFF69),
});
const int _backgroundAccentValue = 0xFF76FF9F;

const MaterialColor accent = MaterialColor(_accentPrimaryValue, <int, Color>{
  50: Color(0xFFF6F9F4),
  100: Color(0xFFEAF0E3),
  200: Color(0xFFDCE7D1),
  300: Color(0xFFCDDDBE),
  400: Color(0xFFC3D5B0),
  500: Color(_accentPrimaryValue),
  600: Color(0xFFB1C99A),
  700: Color(0xFFA8C290),
  800: Color(0xFFA0BC86),
  900: Color(0xFF91B075),
});
const int _accentPrimaryValue = 0xFFB8CEA2;

const MaterialColor accentAccent = MaterialColor(_accentAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_accentAccentValue),
  400: Color(0xFFE3FFCA),
  700: Color(0xFFD5FFB1),
});
const int _accentAccentValue = 0xFFFEFFFD;