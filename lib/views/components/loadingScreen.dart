import 'package:flutter/material.dart';
import 'package:iter/views/components/LogoDisplayer.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/city_wallpaper.jpg"),
              fit: BoxFit.cover
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(),
          LogoDisplayer(),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(),
          Center(
            child: Text("Logo designed by Starline"),
          )
        ],
      ),
    );
  }
}
