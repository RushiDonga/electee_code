import 'package:flutter/material.dart';
import 'package:electionzz/constants.dart';

class NamePlusNumber extends StatelessWidget {

  NamePlusNumber({this.name, this.number});

  final String name;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Text(
              name,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                fontFamily: kFontFamily,
              ),
            ),
            Text(
              number,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 40.0
              ),
            )
          ],
        )
    );
  }
}
