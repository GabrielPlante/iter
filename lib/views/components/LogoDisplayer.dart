import 'package:flutter/material.dart';
import 'package:iter/main.dart';

class LogoDisplayer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    bool isWeb = MyApp.isWebDevice;

    return Column(
      children: [
        Container(
            width: isWeb ? 300 : 200,
            height: isWeb ? 300 : 200,
            child: Image.asset("assets/images/977.png")),
        Center(
          child: Text("Iter", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: isWeb ? 50 : 30, letterSpacing: 2)),
        ),
        Center(
          child: Text("Quiz Collaboratif", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: isWeb ? 25 : 15)),
        )
      ],
    );
  }
}
