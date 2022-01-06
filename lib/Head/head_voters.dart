import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants.dart';

class HeadTotalVoters extends StatefulWidget {
  @override
  _HeadTotalVotersState createState() => _HeadTotalVotersState();

  HeadTotalVoters({this.code});

  final String code;
}

class _HeadTotalVotersState extends State<HeadTotalVoters> {

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
                        style: kDisplayNameText,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (){
                      Alert(
                          context: context,
                          type: AlertType.error,
                          title: "PLEASE NOTE",
                          desc: "For Security purpose the name will not be removed from the appearing list but will not be able to vote..!",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "COOL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              width: 120,
                            )
                          ]
                      ).show();
                      DatabaseReference removeChild = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Removed");
                      removeChild.child(name).set("Removed");
                    },
                    child: Icon(
                      Icons.delete_forever,
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

    databaseReference = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Voter");
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
                      "Voters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        _member.length.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Dark",
                            letterSpacing: 1.5,
                            fontSize: 23.0
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
