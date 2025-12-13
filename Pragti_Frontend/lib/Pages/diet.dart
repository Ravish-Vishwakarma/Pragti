import 'package:flutter/material.dart';
import 'package:pragti/Widgets/style.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "DIET"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: const Color.fromARGB(255, 63, 77, 67),
          child: Center(child: Column(children: [Text("sample text")])),
        ),
      ),
    );
  }
}
