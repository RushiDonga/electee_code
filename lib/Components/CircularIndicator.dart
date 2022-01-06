import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularVotedIndicator extends StatelessWidget {

  CircularVotedIndicator({this.votedPercentText, this.votedPercent});

  final double votedPercent;
  final int votedPercentText;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 90.0,
      lineWidth: 10.0,
      percent: votedPercent,
      center: Text(
          "$votedPercentText %",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23.0
          )
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.white,
      backgroundColor: Colors.white.withOpacity(0.5),
    );
  }
}