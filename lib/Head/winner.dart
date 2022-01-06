import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants.dart';

const testDevice = "com.scupe.electionzz";

class Winner extends StatefulWidget {
  @override
  _WinnerState createState() => _WinnerState();

  Winner({@required this.code});

  final String code;
}

class _WinnerState extends State<Winner> {

  String code;

  List<Card> memberName = [];
  List<Card> winners = [];
  String winnerName = "";
  DatabaseReference updateWinnerInDatabase;

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
//      adUnitId: "ca-app-pub-6853461752658431~1924923864",
//      targetingInfo: targetingInfo,
//      listener: (MobileAdEvent event){
//        print("Interstitial $event");
//      }
//    );
//  }

  // HIGHEST VOTE SECTION
  void addWinnerCard(String name, int votes){
    setState(() {
      winners.add(
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
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.touch_app,
                        color: kMainColor,
                        size: 22.0,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        votes.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
      );
    });
  }

  // OTHER NOMINIEE SECTION
  void addData(String name, int votes){
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
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.touch_app,
                        color: kMainColor,
                        size: 22.0,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        votes.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 21.0,
                          fontFamily: kFontFamily
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
      );
    });
  }

  // Checking the Winner
  void checkWinner(){
    int voteCounter;
    int highestVote = 0;

    List nominieeName = [];
    List totalVotes = [];
    List getPositionForTie = [];

    DatabaseReference checkWinner = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Calculations");
    checkWinner.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> data = snapshot.value;
      data.forEach((key, value) {
        nominieeName.add(key);  // storing the Nominiee Name

        // Counting the Votes of the Nominiee which is "key" here
        DatabaseReference countVotes = FirebaseDatabase.instance.reference().child("AllUsers").child(code).child("Calculations").child(key);
        countVotes.once().then((DataSnapshot votes){
          Map<dynamic, dynamic> count = votes.value;
          voteCounter = 0;
          count.forEach((key, value) {
            voteCounter++;
          });
          totalVotes.add(voteCounter);
          addData(key, voteCounter);

          // Get the Highest Vote
          for(int i=0; i< totalVotes.length; i++){
            if(totalVotes[i] > highestVote){
              setState(() {
                highestVote = totalVotes[i];
              });
            }
          }

          // Check for the Tie
          int checkForTie = 0;
          for(int i=0; i<totalVotes.length; i++){
            if(totalVotes[i] == highestVote){
              checkForTie++;
            }
          }
          if(checkForTie > 1){
            // The Election is Tie
            getPositionForTie = [];
            winners = [];
            winnerName = "";
            for(int i=0; i<totalVotes.length; i++){
              if(totalVotes[i] == highestVote){
                getPositionForTie.add(i);
                addWinnerCard(nominieeName[i], totalVotes[i]);
                winnerName += nominieeName[i] + " ";
                // Updating in database
                updateWinnerInDatabase = FirebaseDatabase.instance.reference().child("AllUsers").child(code);
                updateWinnerInDatabase.child("Winner").set(winnerName);
                updateWinnerInDatabase.child("WinnerStatus").set("Tie");
              }
            }
          }else{
            // If the Election is not Tie
            int getWinnerName = totalVotes.indexOf(highestVote);
            winners = [];
            addWinnerCard(nominieeName[getWinnerName], totalVotes[getWinnerName]);
            // Updating in Database
            winnerName = nominieeName[getWinnerName];
            updateWinnerInDatabase = FirebaseDatabase.instance.reference().child("AllUsers").child(code);
            updateWinnerInDatabase.child("Winner").set(winnerName);
            updateWinnerInDatabase.child("WinnerStatus").set("NotAtie");
          }
        });
      });
    });
  }

  @override
  void dispose() {
//    _interstitialAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

//    FirebaseAdMob.instance.initialize(
//        appId: InterstitialAd.testAdUnitId
//    );
//    createInterstitialAd()..load()..show();

    code = widget.code;
    checkWinner();
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
                      "Winner",
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
                      child: GestureDetector(
                        onTap: (){
//                          createInterstitialAd()..load()..show();
                        },
                        child: Icon(
                          Icons.wb_incandescent,
                          color: Colors.white,
                          size: 33.0,
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
                child: Column(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                "HIGHEST VOTES",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kMainColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  fontFamily: kFontFamily,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: winners,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                "OTHERS NOMINIEE'S",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kMainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  fontFamily: kFontFamily,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: memberName,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
