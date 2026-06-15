import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle roomCode = GoogleFonts.jetBrainsMono(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final TextStyle username = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static final TextStyle message = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle placeholder = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle meta = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle systemMessage = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
