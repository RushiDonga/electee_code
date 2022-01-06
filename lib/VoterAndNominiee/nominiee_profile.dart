import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Components/name_plus_number.dart';
import 'voters.dart';
import 'members.dart';
import 'nominiee.dart';
import '../voted.dart';
import 'package:electionzz/constants.dart';
import 'package:electionzz/group_chat.dart';
import '../Components/CircularIndicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';
import 'package:toast/toast.dart';

class NominieeProfile extends StatefulWidget {
  @override
  _NominieeProfileState createState() => _NominieeProfileState();

  NominieeProfile({this.name, this.code, this.userId, this.history});

  final String name;
  final String code;
  final String userId;
  final bool history;
}

class _NominieeProfileState extends State<NominieeProfile> {

  String name = "";
  String code = "";
  String userID = "";
  String electionName = "";
  String status = "";

  String statusTextOne = "";
  String statusTextTwo = "";

  int totalMembers = 0;
  int totalVoters = 0;
  int totalNominie = 0;
  int totalVoted = 0;

  double votedPercent = 0.0;
  int votedPercentText = 0;

  Color statusYesBtnColor = Colors.white;

  // Checking the Winner
  String winnerName = "I'm null";
  String winnerSetting = "ALL MEMBERS";

  DatabaseReference getElectionName;
  bool hasInternet = true;

  // When the back Button is Pressed
  Future<bool> _onBackPressed() {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "ARE YOU SURE..!",
      desc: "Wanna Leave the Election ?",
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context, true),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context, false),
        )
      ],
    ).show();
  }

  // CheckInternet Connection
  checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      setState(() {
        hasInternet = false;
        Toast.show("No INTERNET", context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      });
    }else{
      setState(() {
        hasInternet = true;
        Toast.show("You are up to date", context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      });
    }
  }

  // Alert Dialogue
  void showDialogue(String title, String description, String text){
    Alert(
        context: context,
        type: AlertType.success ,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
        ]
    ).show();
  }

  int getVotedCount(){
    DatabaseReference voted = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Voted");
    voted.onChildAdded.listen((event) {
      setState(() {
        totalVoted++;

        // Updating the Percent Indicator
        votedPercent = (((totalVoted*100)/(totalVoters))/100).toDouble();
        votedPercentText = (votedPercent*100).toInt();
      });
    });
    return totalVoted;
  }

  int getTotalMembers(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Members");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
        print(event.snapshot.key);
        totalMembers++;
      });
    });
    return totalMembers;
  }

  int getTotalVoters(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Voter");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
        totalVoters++;
      });
    });
    return totalVoters;
  }

  int getTotalNominiee(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Nominiee");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
        print(event.snapshot.key);
        totalNominie++;
      });
    });
    return totalNominie;
  }

  void checkElectionStatus(){
    DatabaseReference getStatus = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Status");
    getStatus.onValue.listen((event) {
      setState(() {
        status = event.snapshot.value;
        if(status == "false"){
          statusTextOne = "✨ STATUS: Election has not yet Started !";
          statusTextTwo = "✋ Please Wait..!";
          statusYesBtnColor = Colors.grey;
        }else if(status == "true"){
          statusTextOne = "✨ STATUS: Election has Started..!";
          statusTextTwo = "🏁 Wanna Vote..!";
          statusYesBtnColor = Colors.grey;
        }else if(status == "done"){
          statusTextOne = "✨ STATUS: The Election is Over";
          statusTextTwo = "👑 Check Winner !";
          statusYesBtnColor = Colors.white;
        }
      });
    });
  }

  void checkWinnerSetting(){
    DatabaseReference getWinnerSetting = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("WinnerSetting");
    getWinnerSetting.once().then((DataSnapshot snapshot){
      setState(() {
        winnerSetting = snapshot.value;

        if(winnerSetting == "NOMINIEE" || winnerSetting == "ALL MEMBERS"){
          // To get the Winner Name
          DatabaseReference getWinnerName = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Winner");

          // Check if the Election is Tie or Not
          DatabaseReference checkForTie = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("WinnerStatus");
          checkForTie.once().then((DataSnapshot snapshot){
            if(snapshot.value == "Tie"){
              getWinnerName.once().then((DataSnapshot snapshot){
                showDialogue("Hey $name", "There's a tie between \n" + snapshot.value, "OKAY ;)");
              });
            }else if(snapshot.value == "NotAtie"){
              getWinnerName.once().then((DataSnapshot snapshot){
                showDialogue("Hey $name", snapshot.value + " has WON the Election", "COOL ;)");
              });
            }
          });
        }else{
          showDialogue("Hey $name", "According to the Head's Privacy settings, you are not allowed to view the Winner..!", "OKAY :(");
        }
      });
    });
  }

  @override
  void initState(){
    super.initState();

    code = widget.code;
    name = widget.name;
    userID = widget.userId;

    totalMembers = getTotalMembers();
    totalVoters = getTotalVoters();
    totalNominie = getTotalNominiee();
    totalVoted = getVotedCount();

    // Get the name of the Election
    getElectionName = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("ElectionName");
    getElectionName.once().then((DataSnapshot snapshot){
      electionName = snapshot.value;

      // Register in History
      DatabaseReference history = FirebaseDatabase.instance.reference().child("History").child(userID).child("NominieeHistory");
      history.child(electionName).set(code);
    });

    checkElectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      body: hasInternet == false
          ? Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Image(
                image: AssetImage("assets/noInternet.jpg"),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100.0),
              child: FlatButton(
                onPressed: () {
                  checkInternet();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "RELOAD",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                color: kMainColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
              ),
            ),
          ],
        ),
      )
      : SingleChildScrollView(
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ColorFiltered(
                    child:Image.asset(
                      "assets/nominiee_bg.jpg",
                    ),
                    colorFilter: ColorFilter.mode(Colors.blueGrey[400], BlendMode.color),

                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              if(widget.history == true){
                                Toast.show("You no longer have access to Chats..!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(
                                  code: code,
                                  name: name,
                                  electionName: electionName,
                                )));
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                              child: Icon(
                                Icons.near_me,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              checkInternet();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(top: 70.0),
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 60.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 85.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        "$name",
                                        textAlign: TextAlign.center,
                                        style: kUserName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "$electionName",
                                        textAlign: TextAlign.center,
                                        style: kElectionName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: (){
                                              if(totalVoted != 0){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => TotalVoters(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No Voter have Joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                              }
                                            },
                                            child: NamePlusNumber(
                                              name: "VOTER",
                                              number: "$totalVoters",
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: (){
                                              if(totalNominie != 0){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => TotalNominiee(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No Nominiee have Joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                              }
                                            },
                                            child: NamePlusNumber(
                                              name: "NOMINIEE",
                                              number: "$totalNominie",
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: (){
                                              if(totalMembers != 0){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => TotalMembers(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No one has Joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                              }
                                            },
                                            child: NamePlusNumber(
                                              name: "TOTAL",
                                              number: "$totalMembers",
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: 25.0
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Image(
                                image: AssetImage("assets/profile1.png"),
                                height: 130.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: kWinnerStatusColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                        child: Text(
                          statusTextOne,
                          textAlign: TextAlign.right,
                          style: kStatusTextOne
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                        child: Text(
                          statusTextTwo ,
                          textAlign: TextAlign.right,
                          style: kStatusTextTwo
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                            child: RaisedButton(
                              color: Color(0xFF09224A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: statusYesBtnColor, width: 1.0),
                              ),
                              onPressed: (){
                                if(status == "done"){
                                  showDialogue("Hey $name", "You can now check the Winner in the Winner Section at the Bottom", "OKAY :)");
                                }
                              },
                              child: Text(
                                "Yess..!",
                                style: TextStyle(
                                  color: statusYesBtnColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: kPeopleWhoVotedColor
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                          "People who Voted..!",
                          style: kPeopleWhoVotedText
                      ),
                      Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                  "$totalVoted",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40.0,
                                  )
                              ),
                              RaisedButton(
                                color: Color(0xFF1DBF9D),
                                onPressed: (){
                                  if(totalVoted != 0){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TotalVoted(
                                      code: code,
                                    )));
                                  }else{
                                    Toast.show("No one has Voted yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                  }
                                },
                                child: Text(
                                  "View",
                                  style: kViewBtnText
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.white, width: 1.0),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 80.0,
                          ),
                          CircularVotedIndicator(votedPercent: votedPercent, votedPercentText: votedPercentText),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: kMainColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                        child: Text(
                          "👑 Winner",
                          style: kWinnerText
                        )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                      child: Text(
                          "Winner will be displayed after the Election is Over",
                          style: kWinnerTextTwo
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                      child: ButtonTheme(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: RaisedButton(
                                color: kMainColor,
                                onPressed: (){
                                  if(status == "false"){
                                    showDialogue("Hey $name", "Election is not yet Over..!", "OKAY");
                                  }else if(status == "true"){
                                    showDialogue("Hey $name", "Election has just Started..!Wait for it to get over..!", "OKAY");
                                  }else if(status == "done"){
                                      checkWinnerSetting();
                                  }
                                },
                                child: Text(
                                  "View",
                                  style: kViewBtnText
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.white, width: 1.0),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                width: 10.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
