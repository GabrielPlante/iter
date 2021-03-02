import 'package:flutter/material.dart';
import 'package:iter/views/components/LogoDisplayer.dart';

import 'package:iter/views/mobileMainPage.dart';

class MobileLoginPage extends StatefulWidget {
  static String userId = "Franck";
  @override
  MobileLoginPageState createState() => MobileLoginPageState();
}

class MobileLoginPageState extends State<MobileLoginPage> {
  static int status = 0; //0 == No choose, 1 == Admin, 2 == Patient

  void click(int newStatus, BuildContext context) {
    status = newStatus;
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MobileMainPage()));
  }

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
          Text("Identifiez-vous", style: TextStyle(fontSize: 40)),
          SizedBox(),
          LogoDisplayer(),
          SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () => click(1, context),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Admin", style: TextStyle(fontSize: 25)))),
              FlatButton(
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () => click(2, context),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                      child: Text("Patient", style: TextStyle(fontSize: 25))))
            ],
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
