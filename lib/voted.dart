import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'constants.dart';

class TotalVoted extends StatefulWidget {
  @override
  _TotalVotedState createState() => _TotalVotedState();

  TotalVoted({this.code});

  final String code;
}

class _TotalVotedState extends State<TotalVoted> {

  String code;

  int keepRecordOfLoop;
  DatabaseReference databaseReference;
  List _member = [];

  List<Card> memberName = [];

  void addData(String name){
    setState(() {
      memberName.add(
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.account_box,
                        color: kMainColor,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        name,
                        style: kDisplayNameText
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      );
    });
  }

  _getData(){
    keepRecordOfLoop = 0;
    memberName.removeRange(0, _member.length);
    databaseReference.once().then((DataSnapshot snapShot){
      final Map<dynamic, dynamic> values = snapShot.value;
      _member.removeRange(0, _member.length);
      values.forEach((key, value) {
        _member.add(key);
        _member.sort();
      });
      keepRecordOfLoop ++;
      if(keepRecordOfLoop == 1){
        for(int i=0; i<_member.length; i++){
          addData(_member[i]);
        }
      }
    });
  }

  _restoreData(){
    databaseReference.onChildAdded.listen((Event event){
      _getData();
    });
  }

  @override
  void initState() {
    super.initState();
    code = widget.code;

    databaseReference = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Voted");
    _restoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Text(
                      "Has Voted",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontFamily: "Dark",
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        _member.length.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          fontFamily: kFontFamily
                        ),
                      )
                  )
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                height: 500,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: memberName
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
