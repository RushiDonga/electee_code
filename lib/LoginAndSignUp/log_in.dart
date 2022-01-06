import 'package:flutter/material.dart';
import 'package:electionzz/constants.dart';
import 'package:electionzz/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  String emailID = "";
  String errorMessage = "";
  bool isLoading = false;

  final _auth = FirebaseAuth.instance;

  AnimationController imageController;
  AnimationController textController;

  // CheckInternet Connection
  checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      setState(() {
        isLoading = false;
        errorMessage =  "Check INTERNET Connection";
      });
    }
  }

  registerUser() {

    _auth.createUserWithEmailAndPassword(email: emailID.trim(), password: "fromSCUPE").then((value){
      if(value != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    }).catchError((onError){
      setState(() {

        if(onError.code == "ERROR_EMAIL_ALREADY_IN_USE"){
          _auth.signInWithEmailAndPassword(email: emailID.trim(), password: 'fromSCUPE').then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          });
        }else if(onError == "ERROR_INVALID_EMAIL"){
          errorMessage = "Invalid E-mail";
        }else{
          print(onError.code);
          errorMessage = "Error registering an E-mail!";
        }
        isLoading = false;
      });
    });
  }

  Future<bool> _onBackPressed(){
    return Future.value(false);
  }

  Future<bool> _onLoadingBackPressed(){
    setState(() {
      isLoading = false;
    });
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();

    // image Animation
    imageController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      upperBound: 200,
    );
    imageController.forward();

    imageController.addListener(() {
      setState(() {});
    });

    // for Text
    textController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
      upperBound: 40,
      lowerBound: 30,
    );
    textController.reverse();

    textController.addListener(() {
      setState(() {});
    });

    setState(() {
      isLoading = false;
    });
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? WillPopScope(
        onWillPop: _onLoadingBackPressed,
          child: SpinKitFadingCircle(color: kMainColor,)
      )
          : WillPopScope(
        onWillPop: _onBackPressed,
            child: SafeArea(
        child: Align(
            alignment: Alignment.center,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "User Registration",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: textController.value,
                          fontFamily: "Dark",
                          color: kMainColor,
                        letterSpacing: 2.0
                      ),
                    ),
                    Container(
                      height: imageController.value,
                      child: Image(
                        image: AssetImage("assets/image3.jpg"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      height: 56.5,
                      child: TextField(
                        onChanged: (value){
                          setState(() {
                            emailID = value;
                          });
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail,
                              color: kColor1,
                            ),
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
                            hintText: "E-mail",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 17.0,
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 100.0),
                      child: FlatButton(
                        onPressed: () {
                          if(emailID == ""){
                            setState(() {
                              errorMessage = "E-mail ?";
                            });
                          }else{
                            setState(() {
                              checkInternet();
                              isLoading = true;
                              registerUser();
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "REGISTER",
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
                    Text(
                      "$errorMessage",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kMainColor,
                        fontSize: 15.0
                      ),
                    )
                  ],
                ),
              ),
            ),
        ),
      ),
          )
    );
  }
}




