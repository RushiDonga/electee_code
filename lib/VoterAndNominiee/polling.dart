import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants.dart';

class Polling extends StatefulWidget {
  @override
  _PollingState createState() => _PollingState();

  Polling({this.code, this.userName});

  final String code;
  final String userName;
}

class _PollingState extends State<Polling> {

  String code;
  String userName;

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
                  GestureDetector(
                    onTap: () async {
                      // checking if the User has been Removed
                      DatabaseReference checkIfRemoved = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Removed").child(userName);
                      DataSnapshot check = await checkIfRemoved.once();
                      if(check.value == null){

                        // User has Not Been Removed
                        // Registering user as Voted
                        DatabaseReference checkIfVotedExists = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Voted").child(userName);
                        DataSnapshot snapshot = await checkIfVotedExists.once();
                        if(snapshot.value == null){
                          Alert(
                              context: context,
                              type: AlertType.success,
                              title: "Are You Sure..?",
                              desc: "Wanna give your vote to $name",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Yess",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    checkIfVotedExists.set("Voted");

                                    // Registering the user in Calculation
                                    DatabaseReference calculation = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Calculations");
                                    calculation.child(name).child(userName).set("Vote");

                                    Navigator.pop(context);
                                  },
                                  width: 120,
                                ),
                                DialogButton(
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  width: 120,
                                )
                              ]
                          ).show();
                        }else{
                          Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Hey $userName",
                              desc: "It seems like your Vote has Already been Registered",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Okay",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ]
                          ).show();
                        }
                      }else{
                        Alert(
                          context: context,
                          type: AlertType.error,
                          title: "Hey $userName",
                          desc: "It seems like you have been removed by the Head, so you can't Vote..! Try Consulting your Head",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "OKAY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            )
                          ]
                        ).show();
                      }
                    },
                    child: Icon(
                      Icons.thumb_up,
                      color: kMainColor,
                      size: 27.0,
                    ),
                  )
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
      });
      keepRecordOfLoop ++;
      if(keepRecordOfLoop == 1){
        _member.sort();
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

    databaseReference = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Nominiee");
    _restoreData();

    userName = widget.userName;
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
                      "Polling Area",
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
                            fontSize: 25.0,
                          fontFamily: kFontFamily,
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