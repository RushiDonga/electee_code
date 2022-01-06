import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:electionzz/Head/head_profile.dart';
import 'package:electionzz/VoterAndNominiee/voter_profile.dart';
import 'package:electionzz/VoterAndNominiee/nominiee_profile.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();

  History({this.userID, this.headName});
  final String userID;
  final String headName;
}

class _HistoryState extends State<History> {

  String userID;
  String userName = "";

  List<Container> headHistory = [];
  List<Container> voterHistory = [];
  List<Container> nominieeHistory = [];

  // Head Section
  void addData(String name, String code, List<Container> history, String who){
    setState(() {
      history.add(
          Container(
            child: GestureDetector(
              onTap: (){
                // Goto Head Profile
                if(who == "Election Conducted"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HeadProfile(
                    electionName: name,
                    code: code,
                  )));
                }else if(who == "VoterHistory"){
                  // Goto Voters Profile
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VoterNdNominieeProfile(
                    code: code,
                    userID: userID,
                    name: userName,
                    history: true,
                  )));
                }else if(who == "NominieeHistory"){
                  // Goto Nominiee Profile
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NominieeProfile(
                    name: userName,
                    code: code,
                    userId: userID,
                    history: true,
                  )));
                }
              },
              child: Card(
                elevation: 2,
                child: GestureDetector(
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
                ),
              ),
            ),
          )
      );
    });
  }

  getData(String who, List<Container> getHistory){
    DatabaseReference history = FirebaseDatabase.instance.reference().child("History").child(userID).child(who);
    history.once().then((DataSnapshot snapshot){
      final Map<dynamic, dynamic> value = snapshot.value;
      if(value != null){
        value.forEach((key, value) {
          getHistory.sort();
          addData(key, value, getHistory, who);
        });
      }else{
        print("----------------");
      }
    });
    print(voterHistory);
  }

  @override
  void initState() {
    super.initState();

    userID = widget.userID;
    userName = widget.headName;
    getData("Election Conducted", headHistory);
    getData("VoterHistory", voterHistory);
    getData("NominieeHistory", nominieeHistory);
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
                      "History",
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
                      child: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 27.0,
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
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            "ELECTION CONDUCTED",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kMainColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily,
                              fontSize: 15.0
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: headHistory,
                        ),
                        voterHistory == []
                            ? SizedBox()
                            : Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            "VOTER'S HISTORY",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kMainColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: kFontFamily,
                                fontSize: 15.0
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: voterHistory,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            "NOMINIEE'S HISTORY",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kMainColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: kFontFamily,
                                fontSize: 15.0
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: nominieeHistory,
                        ),
                      ],
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
