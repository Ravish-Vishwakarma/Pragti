import 'package:flutter/material.dart';
import 'package:pragti/Pages/homepage.dart';
import 'package:pragti/Widgets/style.dart';

class PassAtuh extends StatelessWidget {
  const PassAtuh({super.key});

  @override
  Widget build(BuildContext context) {
    final swidth = MediaQuery.of(context).size.width;
    TextEditingController passwordfield = TextEditingController();
    double txtfield = swidth * 0.7;
    double profilewidth = 250;
    double passtitle = 15;
    double btnwidth = 130;

    if (swidth > 700) {
      btnwidth = 180;
      txtfield = 550;
      passtitle = 18;
      profilewidth = 220;
    }
    return Scaffold(
      backgroundColor: MyColors.almostwhite,
      // appBar: MyAppbar(title: 'P A S S W O R D'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: profilewidth, color: MyColors.forestgreen),
            Text(
              "Enter Your Password",
              style: TextStyle(fontFamily: 'Inter', fontSize: passtitle),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: txtfield,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      spreadRadius: 2,
                      blurRadius: 0.1,

                      offset: Offset(5.4, 6),
                    ),
                  ],
                ),
                child: Theme(
                  data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                      selectionColor: MyColors.tintgreen.withOpacity(0.5),
                    ),
                  ),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordfield,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color:
                              MyColors.smokedgreen, // Border color when focused
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // borderSide: BorderSide(
                        //   color:
                        //       MyColors
                        //           .smokedgreen, // Border color when not focused
                        //   width: 2,
                        // ),
                      ),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
              child: SizedBox(
                width: btnwidth,
                height: 38,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    if (passwordfield.text == '123') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          width: swidth * 0.95,
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Incorrect Password"),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 30.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.forestgreen, // Button color
                    foregroundColor: MyColors.creambeige, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Boxy shape
                      side: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ), // Border color & thickness
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    elevation: 5,
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(color: MyColors.almostwhite),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
