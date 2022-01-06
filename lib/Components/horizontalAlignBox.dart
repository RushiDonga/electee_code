import 'package:flutter/material.dart';
import 'package:electionzz/constants.dart';

class HorizontalAlignBox extends StatelessWidget {
  HorizontalAlignBox({this.imageLoc, this.text});

  final String imageLoc;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0, bottom: 20.0),
            child: Image(
              image: AssetImage(imageLoc),
            ),
          ),
          Text(
            text,
            style: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              fontFamily: kFontFamily,
            ),
          ),
          SizedBox(
            height: 30.0,
          )
        ],
      ),
    );
  }
}