import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                child: Column(
                  children: [
                    Text("Iter  arrive à l'aide !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.green),),
                    SizedBox(height: 15),
                    Container(
                      width: 80,
                        height: 80,
                        child: Image.asset("assets/images/help.png")
                    ),
                    SizedBox(height: 10),
                    Text('Une réponse va disparaître...', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    height:120,
                    width:120,
                    child: Image.asset("assets/images/city_wallpaper.jpg", fit: BoxFit.cover),
                  ),
                ),
            ),
          ],
        )
    );
  }
}
