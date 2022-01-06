import 'package:electionzz/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Components/name_plus_number.dart';
import 'head_Removed.dart';
import 'head_members.dart';
import 'head_nominiee.dart';
import 'head_voters.dart';
import 'winner.dart';
import 'package:electionzz/group_chat.dart';
import '../Components/horizontalAlignBox.dart';
import '../Components/IconBorderAndText.dart';
import 'package:electionzz/voted.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../Components/CircularIndicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:toast/toast.dart';

class HeadProfile extends StatefulWidget {
  @override
  _HeadProfileState createState() => _HeadProfileState();

  HeadProfile({this.electionName, this.code});

  final String electionName;
  final String code;
}

class _HeadProfileState extends State<HeadProfile> {

  static String headName = "";
  static String electionName = "";
  static String code = "";
  String newElection = "";

  String localStatus = "false";
  String winnerSetting = "ALL MEMBERS";

  String electionStatusTextOne = "";
  String electionStatusTextTwo = "";

  int totalMembers = 0;
  int totalVoters = 0;
  int totalNominie = 0;
  int totalVoted = 0;
  int totalRemoved = 0;

  double votedPercent = 0.0;
  int votedPercentText = 0;

  Color statusYesBtnColor = Colors.white;
  Color statusNoBtnColor = Colors.white;

  DatabaseReference updateWinnerSetting = FirebaseDatabase.instance.reference().child("AllUsers");
  
  bool hasInternet = true;

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

  _showBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 285.0,
            margin: EdgeInsets.symmetric(horizontal: 3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.settings,
                          color: kMainColor,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                            color: kMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: kMainColor.withOpacity(0.5),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Select the one to whom you wanna show the final result of the Election",
                      textAlign: TextAlign.center,
                      style: kHeadSetting
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            winnerSetting = "VOTERS";
                            updateWinnerSetting.child(code).child("WinnerSetting").set(winnerSetting);
                            Navigator.pop(context);
                          });
                        },
                        child: IconBorderAndText(
                          icon: Icons.touch_app,
                          text: "VOTERS",
                          selected: winnerSetting,
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            winnerSetting = "NOMINIEE";
                            updateWinnerSetting.child(code).child("WinnerSetting").set(winnerSetting);
                            Navigator.pop(context);
                          });
                        },
                        child: IconBorderAndText(
                          icon: Icons.perm_identity,
                          text: "NOMINIEE",
                          selected: winnerSetting,
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            winnerSetting = "ALL MEMBERS";
                            updateWinnerSetting.child(code).child("WinnerSetting").set(winnerSetting);
                            Navigator.pop(context);
                          });
                        },
                        child: IconBorderAndText(
                          icon: Icons.star,
                          text: "ALL MEMBERS",
                          selected: winnerSetting,
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            winnerSetting = "ONLY ME";
                            updateWinnerSetting.child(code).child("WinnerSetting").set(winnerSetting);
                            Navigator.pop(context);
                          });
                        },
                        child: IconBorderAndText(
                          icon: Icons.block,
                          text: "ONLY ME",
                          selected: winnerSetting,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "NOTE: Only the name of the Winner will be displayed to the one whom you choose to show the Result",
                      textAlign: TextAlign.center,
                      style: kHeadSetting,
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  // Checking the Election Status
  _checkElectionStatus(){
    setState(() {
      if(localStatus == "false"){
        electionStatusTextOne = "✨ STATUS: Election has not yet Started..!";
        electionStatusTextTwo = "🏁 Start Election...?";
        statusNoBtnColor = Colors.white;
        statusNoBtnColor = Colors.white;
      }else if(localStatus == "true"){
        electionStatusTextOne = "✨ STATUS: Election has been Started";
        electionStatusTextTwo = "🏁 Stop Election...?";
        statusNoBtnColor = Colors.white;
        statusNoBtnColor = Colors.white;
      }else if(localStatus == "done"){
        electionStatusTextOne = "✨STATUS: Woohoo...! Election is Over..!";
        electionStatusTextTwo = "🏁 Check Winner..!";
        statusNoBtnColor = Colors.white;
        statusNoBtnColor = Colors.grey;
      }
    });
  }

  // Alert Dialogue With Two Buttons
  void showDialogueTwoBtns(String title, String description, String status){
    Alert(
        context: context,
        type: AlertType.success ,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            child: Text(
              "No..!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
          DialogButton(
            child: Text(
              "Yeah..!",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: (){
              DatabaseReference electionStatus = FirebaseDatabase.instance.reference().child("AllUsers").child(code);
              electionStatus.child("Status").set(status);
              localStatus = status;
              _checkElectionStatus();
              Navigator.pop(context);
            },
            gradient: LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ]
    ).show();
  }

  // Alert Dialog with Single Button
  void showDialogueSingleBtns(String title, String description,){
    Alert(
        context: context,
        type: AlertType.success ,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            child: Text(
              "OKAY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: (){
              _checkElectionStatus();
              Navigator.pop(context);
            },
          )
        ]
    ).show();
  }

  // Get the Data from Firebase Database

  int getTotalRemoved(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Removed");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
        totalRemoved++;
      });
    });
    return totalRemoved;
  }

  int getTotalMembers(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Members");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
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

  int getTotlaNominiee(){
    DatabaseReference databaseReference =  FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Nominiee");
    databaseReference.onChildAdded.listen((Event event){
      setState(() {
        totalNominie++;
      });
    });
    return totalNominie;
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

  void initState(){
    super.initState();
    
    checkInternet();

    electionName = widget.electionName;
    code = widget.code;

    totalMembers = getTotalMembers();
    totalVoters = getTotalVoters();
    totalNominie = getTotlaNominiee();
    totalVoted = getVotedCount();
    totalRemoved = getTotalRemoved();
    
    // get the head Name
    DatabaseReference getHeadName = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Head");
    getHeadName.once().then((DataSnapshot snapshot){
      headName = snapshot.value;
    });
    
    // Get the last Updated Status
    DatabaseReference getStatus = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Status");
    getStatus.once().then((DataSnapshot snapshot){
      localStatus = snapshot.value;
      _checkElectionStatus();
    });
    
    // Get the Last Updated Winner Privacy Setting
    DatabaseReference getWinnerSetting = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("WinnerSetting");
    getWinnerSetting.once().then((DataSnapshot snapshot){
      winnerSetting = snapshot.value;
    });
  }

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
                      "assets/head_bg.jpg",
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(
                                code: code,
                                name: headName,
                                electionName: electionName,
                              )));
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
                                        headName,
                                        textAlign: TextAlign.center,
                                        style: kUserName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        electionName,
                                        textAlign: TextAlign.center,
                                        style: kElectionName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 25.0,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: (){
                                              if(totalVoters != 0){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => HeadTotalVoters(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No one has joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => HeadTotalNominiee(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No one has joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => HeadTotalMembers(
                                                  code: code,
                                                )));
                                              }else{
                                                Toast.show("No one has joined yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                                image: AssetImage("assets/profile2.png"),
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

              GestureDetector(
                onTap: (){
                  final data = ClipboardData(text: code);
                  Clipboard.setData(data);
                  Toast.show("📎 Copied to ClipBoard", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: HorizontalAlignBox(
                          imageLoc: "assets/code.png",
                          text: code,
                        )
                      ),

                      SizedBox(
                        width: 10.0,
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            if(totalRemoved != 0){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Removed(
                                code: code,
                              )));
                            }else{
                              Toast.show("You haven't Removed anyone", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                            }
                          },
                          child: HorizontalAlignBox(
                            imageLoc: "assets/remove.png",
                            text: "REMOVED",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        electionStatusTextOne,
                        textAlign: TextAlign.right,
                        style: kStatusTextOne
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        electionStatusTextTwo,
                        textAlign: TextAlign.right,
                        style: kStatusTextTwo
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          color: Color(0xFF09224A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: statusYesBtnColor, width: 1.0),
                          ),
                          onPressed: (){
                            setState(() {
                              if(localStatus == "false"){
                                showDialogueTwoBtns("Are you sure..?", "Wanna start the Election...?", "true");  // the third text is the value to be updated when the button is pressed
                              }else if(localStatus == "true"){
                                showDialogueTwoBtns("Are you sure..?", "Wanna stop the Election...?", "done");  // the third text is the value to be updated when the button is pressed
                              }else if(localStatus == "done"){
                                showDialogueSingleBtns("Hey $headName", "You can now see the Winner in the Winner Section at the Bottom");
                              }
                            });
                          },
                          child: Text(
                            "Yess..!",
                            style: TextStyle(
                              color: statusYesBtnColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily,
                              fontSize: 15.0
                            ),
                          ),
                        ),
                        RaisedButton(
                          color: Color(0xFF09224A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: statusNoBtnColor, width: 1.0),
                          ),
                          onPressed: (){
                            setState(() {
                              if(localStatus == "false"){
                                showDialogueSingleBtns("Hey $headName", "You can start the Election when all the Members have joined..!");
                              }else if(localStatus == "true"){
                                showDialogueSingleBtns("Hey $headName", "Stop the Election when all the members have Voted");
                              }else if(localStatus == "done"){
                                // Button is DeActivated
                              }
                            });
                          },
                          child: Text(
                            "No..!",
                            style: TextStyle(
                              color: statusNoBtnColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily,
                              fontSize: 15.0
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
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
                                  style: kVotedNumber
                              ),
                              RaisedButton(
                                color: Color(0xFF1DBF9D),
                                onPressed: (){
                                  if(totalVoted != 0){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TotalVoted(
                                      code: code,
                                    )));
                                  }else{
                                    Toast.show("No one has voted yet", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            "👑 Winner",
                            style: kWinnerText
                          )
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              _showBottomSheet(context);
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 25.0,
                              )
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Winner will be displayed after the Election is Over",
                        style: kWinnerTextTwo
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: <Widget>[
                          RaisedButton(
                            color: kMainColor,
                            onPressed: (){
                              if(localStatus == "false"){
                                showDialogueSingleBtns("Hey $headName", "Election has not yet started, wait for it to get Over!");
                              }else if(localStatus == "true"){
                                showDialogueSingleBtns("Hey $headName", "Election has just Started..!Wait for it to get over..!");
                              }else if(localStatus == "done"){
                                setState(() {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Winner(
                                    code: code,
                                  )));
                                });
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
                          SizedBox(
                            width: 100.0,
                          )
                        ],
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