import 'package:flutter/material.dart';
import 'package:electionzz/constants.dart';

class IconBorderAndText extends StatelessWidget {
  IconBorderAndText({@required this.text, @required this.icon, @required this.selected});

  final String text;
  final IconData icon;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: selected == text ? kMainColor : Colors.grey),
              ),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  icon,
                  color: selected == text ? kMainColor : Colors.grey,
                  size: 40.0,
                ),
              ),
            ),
            SizedBox(
              height: 3.0,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: selected == text ? kMainColor : Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                fontFamily: "Ballo",
              ),
            )
          ],
        )
      ],
    );
  }
}