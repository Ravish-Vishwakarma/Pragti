import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pragti/Widgets/style.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon? ticon;
  final VoidCallback? ticonfunc;
  const MyAppbar({super.key, required this.title, this.ticon, this.ticonfunc});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      backgroundColor: MyColors.forestgreen,
      title: Center(
        child: Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            textStyle: TextStyle(color: Colors.white, fontSize: 35),
          ),
        ),
      ),
      actions:
          ticon != null
              ? [
                IconButton(
                  onPressed: ticonfunc,
                  icon: ticon!,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
