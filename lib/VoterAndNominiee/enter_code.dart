import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants.dart';
import 'voter_profile.dart';
import 'nominiee_profile.dart';
import 'package:connectivity/connectivity.dart';
import 'package:electionzz/history.dart';

const testDevice = "com.scupe.electionzz";

class EnterCode extends StatefulWidget {

  EnterCode({this.userName, this.selection, this.userID});

  final String userName;
  final String selection;
  final String userID;

  @override
  _EnterCodeState createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  String userName;
  String selected;
  String userID;
  String enteredCode = "";
  String errorMessage = "";
  bool isLoading = false;

  // Firebase Variables
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

//  // Interstitial Ads
//  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//    testDevices: testDevice != null ? <String>[testDevice] : null,
//    nonPersonalizedAds: true,
//    keywords: <String>["Book", "Adventure"],
//  );
//
//  InterstitialAd _interstitialAd;
//
//  InterstitialAd createInterstitialAd(){
//    return InterstitialAd(
//        adUnitId: "ca-app-pub-6853461752658431~1924923864",
//        targetingInfo: targetingInfo,
//        listener: (MobileAdEvent event){
//          print("Interstitial $event");
//        }
//    );
//  }

  // CheckInternet Connection
  checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      setState(() {
        enteredCode = "";
        isLoading = false;
        errorMessage =  "Check INTERNET Connection";
      });
    }
  }

  @override
  void dispose() {
//    _interstitialAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkInternet();

//    FirebaseAdMob.instance.initialize(
//        appId: InterstitialAd.testAdUnitId
//    );

    userName = widget.userName;
    selected = widget.selection;
    userID = widget.userID;
    print(userID);
  }

  _checkForNameInDatabase() async {
    DatabaseReference checkForUserName = FirebaseDatabase.instance.reference().child("AllUsers").child(enteredCode).child("Members").child(userName);
    DataSnapshot snapshot = await checkForUserName.once();

    if(snapshot.value == null){

      _databaseReference.child("AllUsers").child(enteredCode).child("Members").child(userName).set("Member");

      if(selected == "VOTER"){

        _databaseReference.child("AllUsers").child(enteredCode).child("Voter").child(userName).set("Voter");

        // Go to Voters Profile
        Navigator.push(context, MaterialPageRoute(builder: (context) => VoterNdNominieeProfile(
          code: enteredCode,
          name: userName,
          userID: userID,
        )));
        setState(() {
          isLoading = false;
        });
      }else if(selected == "NOMINIEE"){

        _databaseReference.child("AllUsers").child(enteredCode).child("Nominiee").child(userName).set("Nominiee");

        // Go to Nominiee's Profile
        Navigator.push(context, MaterialPageRoute(builder: (context) => NominieeProfile(
          code: enteredCode,
          name: userName,
          userId: userID,
        )));
        setState(() {
          isLoading = false;
        });
      }
    }else{
      setState(() {
        enteredCode = "";
        isLoading = false;
        errorMessage = "User Name already Exists..!\n Try a new one..!";
      });
    }
  }

  void checkElectionStatus(){
    DatabaseReference electionStatus = FirebaseDatabase.instance.reference().child("AllUsers").child(enteredCode).child("Status");
    electionStatus.once().then((DataSnapshot snapshot){
      if(snapshot.value == "true" || snapshot.value == "done"){
        setState(() {
          enteredCode = "";
          isLoading = false;
          errorMessage = "Oops...! You're Late\nElection has been Started..!";
        });
      }else{
        checkForTheCodeInDatabase();
      }
    });
  }

  void checkForTheCodeInDatabase(){

    void codeExists(DatabaseReference databaseReference) async {
      DataSnapshot dataSnapshot = await databaseReference.once();
      if(dataSnapshot.value == null){
        setState(() {
          enteredCode = "";
          isLoading = false;
          errorMessage = "Code doesn't Exists..!";
        });
      }else{
        _checkForNameInDatabase();
      }
    }
    codeExists(FirebaseDatabase.instance.reference().child("AllUsers").child(enteredCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kMainColor,
        body:isLoading
            ? Container(
          color: Colors.white,
          child: SpinKitFadingCircle(color: kMainColor,),
        )
            : SafeArea(
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
                        "Join the Room",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: "Dark",
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => History(
                          userID: userID,
                          headName: userName,
                        )));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)
                      )
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                              "Hey $userName, \n Ask the One who is Conducting \n the Election for the Code,\n then enter it here",
                              textAlign: TextAlign.center,
                              style: kGenerateNdEnterText
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          height: 56.5,
                          child: TextField(
                            textAlign: TextAlign.center,
                            onChanged: (value){
                              setState(() {
                                enteredCode = value;
                              });
                            },
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                            ),
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15.0)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15.0)
                                ),
                                hintText: "Enter Code",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 17.0,
                                )
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 7.0),
                          child: FlatButton(
                            onPressed: (){
                              // createInterstitialAd()..load()..show();
                              setState(() {
                                if(enteredCode != ""){
                                  setState(() {
                                    checkInternet();
                                    checkElectionStatus();
                                    isLoading = true;
                                  });
                                }else{
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = "Enter Code..!";
                                  });
                                }
                              });
                            },
                            color: kMainColor,
                            child: Text(
                                "Join the Room",
                                style: kButtonTextStyle
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                              "$errorMessage",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kMainColor,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
