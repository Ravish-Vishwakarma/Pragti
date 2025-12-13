import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralSetting extends StatefulWidget {
  const GeneralSetting({super.key});

  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Column(
          children: [
            Text(
              "THEME",
              style: GoogleFonts.jetBrainsMono(
                textStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
