import 'package:electionzz/constants.dart';
import 'package:flutter/material.dart';
import 'head_profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
import 'package:electionzz/history.dart';

const chars = "ABCDEFGHIJKLMNOPWVRSTUVWXYZ0123456789";

const testDevice = "com.scupe.electionzz";

class GenerateCode extends StatefulWidget {

  GenerateCode({this.userName, this.userID});
  final String userName;
  final String userID;

  @override
  _GenerateCodeState createState() => _GenerateCodeState();
}

class _GenerateCodeState extends State<GenerateCode> {

  static String userName;
  static String userID;
  static String code = "";
  static String electionName = "";
  String errorMessage;
  bool isLoading = false;

  // Interstitial Ads
//  static const MobileAdTargetingInfo mobileAdTargetingInfo = MobileAdTargetingInfo(
//    testDevices: testDevice != null ? <String>[testDevice] : null,
//    nonPersonalizedAds: true,
//    keywords: ["book", "Adventure"],
//  );
//
//  InterstitialAd _interstitialAd;
//
//  InterstitialAd createInterstitialAds(){
//    return InterstitialAd(
//      adUnitId: "ca-app-pub-6853461752658431~1924923864",
//      targetingInfo: mobileAdTargetingInfo,
//      listener: (MobileAdEvent event){
//        print("Interstitial $event");
//      }
//    );
//  }

  // CheckInternet Connection
  checkInternet() async {
    print("hey");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      setState(() {
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

    // Ads
//    FirebaseAdMob.instance.initialize(
//        appId: InterstitialAd.testAdUnitId
//    );

    userName = widget.userName;
    userID = widget.userID;

    checkInternet();
    code = "";
    errorMessage = "";

    code = generateRandomCode(6);
  }

  checkForTheCodeIfExists() async{
    DatabaseReference checkCode = FirebaseDatabase.instance.reference().child("AllUsers").child(code);
    DataSnapshot snapshot = await checkCode.once();

    if(snapshot.value == null){
      registerDetails();
    }else{
      generateRandomCode(6);
      checkForTheCodeIfExists();
    }
  }

  String generateRandomCode(length){
    Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for(var i=0; i < length; i++){
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

  void registerDetails(){
    DatabaseReference _databaseReference = FirebaseDatabase.instance.reference(); // Insert Code and Head
    _databaseReference.child("AllUsers").child(code).child("Code").set(code);
    _databaseReference.child("AllUsers").child(code).child("Head").set(userName);
    _databaseReference.child("AllUsers").child(code).child("ElectionName").set(electionName);
    _databaseReference.child("AllUsers").child(code).child("Status").set("false");
    _databaseReference.child("AllUsers").child(code).child("WinnerSetting").set("ALL MEMBERS");

    // put Data into History
    DatabaseReference addHistory = FirebaseDatabase.instance.reference().child("History").child(userID);
    addHistory.child("Election Conducted").child(electionName).set(code);

    // Showing Ads
//    createInterstitialAds()..load()..show();

    // Go to Head profile
    Navigator.push(context, MaterialPageRoute(builder: (context) => HeadProfile(
      electionName: electionName,
      code: code,
    )));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: isLoading
      ? Container(
          color: Colors.white,
          child: SpinKitFadingCircle(color: kMainColor)
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
                      "Create a Room",
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
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.stretch ,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "Hey, $userName \n Give the code below to the one \n who gonna participate in the Election",
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
                              electionName = value;
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
                              hintText: "Election Name",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 17.0,
                              )
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 5.0,
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        height: 56.5,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                          code,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Ballo",
                            color: kMainColor,
                            fontSize: 21.0,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 7.0),
                        child: FlatButton(
                          onPressed: (){
                            if(electionName != ""){
                              final validChar = RegExp('^[a-zA-Z0-9 ]');
                              if(validChar.hasMatch(electionName)){
                                setState(() {
                                  checkInternet();
                                  isLoading = true;
                                  checkForTheCodeIfExists();
                                  registerDetails();
                                  isLoading = false;
                                });
                              }else{
                                errorMessage = "Invalid Election Name";
                              }
                            }else{
                              setState(() {
                                errorMessage = "Give Election a Tag...!";
                              });
                            }
                          },
                          color: kMainColor,
                          child: Text(
                            "Continue",
                            style: kButtonTextStyle
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kMainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
