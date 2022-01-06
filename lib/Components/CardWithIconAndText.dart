import 'package:electionzz/constants.dart';
import 'package:flutter/material.dart';

class CardWithIconAndText extends StatelessWidget {

  CardWithIconAndText({this.selected,@required this.icon,@required this.text});

  final String selected;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300],
            spreadRadius: 0.05,
            blurRadius: 50,
          )
        ],
        color: selected == text ? kMainColor : Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 60.0,
            color: selected == text ? Colors.white : kMainColor,
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
              text,
              style: TextStyle(
                  color: selected == text ? Colors.white : kMainColor,
                  fontWeight: FontWeight.bold,
                fontFamily: "Ballo",
                fontSize: 16.0
              )
          ),
          SizedBox(
              height: 5.0
          )
        ],
      ),
    );
  }
}
