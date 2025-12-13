import 'package:flutter/material.dart';
import 'package:pragti/Widgets/style.dart';

class Basicapage extends StatefulWidget {
  const Basicapage({super.key});

  @override
  State<Basicapage> createState() => _BasicapageState();
}

class _BasicapageState extends State<Basicapage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "CLOCK"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: const Color.fromARGB(255, 63, 77, 67),
          child: Center(child: Column(children: [Text("asasad")])),
        ),
      ),
    );
  }
}
