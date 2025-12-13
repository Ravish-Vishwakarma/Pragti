import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpoilerText extends StatefulWidget {
  final String text;
  const SpoilerText(this.text, {super.key});

  @override
  State<SpoilerText> createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<SpoilerText> {
  bool isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return isRevealed
        ? Text(
          widget.text,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        )
        : Tooltip(
          message: "Show Text",
          child: InkWell(
            onTap: () {
              setState(() => isRevealed = true);
            },

            child: Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey,
              ),
            ),
          ),
        );
  }
}
