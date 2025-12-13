import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pragti/Pages/settings/generalsetting.dart';
import 'package:pragti/Widgets/style.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  int _selectedpage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyAppbar(title: "SETTINGS"),
      backgroundColor: MyColors.forestgreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // final pageWidth = constraints.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(1),
            ),
            child: Container(
              color: MyColors.hazybeige,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    CupertinoSlidingSegmentedControl(
                      groupValue: _selectedpage,
                      children: <int, Widget>{
                        0: slidertext("General"),
                        1: slidertext("Pages"),
                        2: slidertext("User"),
                        3: slidertext("AI"),
                        4: slidertext("Testing"),
                      },
                      onValueChanged: (int? value) {
                        if (value != null) {
                          setState(() => _selectedpage = value);
                        }
                      },
                    ),
                    _selectedpage == 0
                        ? GeneralSetting()
                        : Text("Selected $_selectedpage"),
                    // Card(
                    //   child: SizedBox(
                    //     height: 300,
                    //     width: pageWidth,
                    //     child: Column(
                    //       children: [
                    //         Text(
                    //           "THEME",
                    //           style: GoogleFonts.jetBrainsMono(
                    //             textStyle: TextStyle(
                    //               color: Colors.black,
                    //               fontSize: 20,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Divider(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  slidertext(text) {
    return Text(text, style: GoogleFonts.jetBrainsMono());
  }
}
