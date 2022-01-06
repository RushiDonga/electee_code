import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'constants.dart';

final fireStore = Firestore.instance;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();

  ChatPage({this.code, this.name, this.electionName});

  final String code;
  final String name;
  final String electionName;
}

class _ChatPageState extends State<ChatPage> {

  String code;
  String name;
  String electionName = "";
  String messageEntered = "";

  final messageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    code = widget.code;
    name = widget.name;
    electionName = widget.electionName;
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
              child: Center(
                child: Text(
                  electionName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontFamily: "Dark",
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 9,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)
                    )
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MessagesStream(
                      code: code,
                      name: name,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 56.5,
                            child: TextField(
                              controller: messageTextController,
                              onChanged: (value){
                                messageEntered = value;
                              },
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                              ),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.message,
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
                                  hintText: "Enter Message here",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17.0,
                                  )
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: ClipOval(
                            child: Material(
                              color: kMainColor, // button color
                              child: InkWell(
                                child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    )
                                ),
                                onTap: () {
                                  if(messageEntered == ""){
                                    Toast.show("Can't send empty message", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                  }else{
                                    int totalMessages;
                                    fireStore.collection(code).getDocuments().then((messageNumber){

                                      totalMessages = messageNumber.documents.length + 1;
                                      fireStore.collection(code).document(
                                          DateTime.now().toString()
                                      ).setData({
                                        "Message": messageEntered,
                                        "Sender": name,
                                      });
                                      messageTextController.clear();
                                      print(totalMessages.toString() + " 000");
                                      setState(() {
                                        messageEntered =  "";
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    )
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

class MessagesStream extends StatelessWidget {

  MessagesStream({@required this.code, @required this.name});
  final String code;
  final String name;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection(code).snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages){
            final messageText = message.data["Message"];
            final messageSender = message.data["Sender"];

            final currentUser = name;

            final messageBubble = MessageBubble(
              sender: messageSender,
              message: messageText,
              isMe: messageSender == name,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        }else{
          return Center(
            child: Text(""),
          );
        }
      },
    );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({this.message, this.sender, this.isMe});

  final String message;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "@ " + sender,
            style: TextStyle(
              color: Colors.black54,
              fontFamily: kFontFamily,
              fontSize: 13.0
            ),
          ),
          Material(
            color: isMe == true ? kMainColor.withOpacity(0.85) : Colors.grey[300] ,
            borderRadius: BorderRadius.circular(5.0),
            elevation: 2.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Text(
                "$message",
                style: TextStyle(
                  color: isMe == true ? Colors.white : Colors.black,
                  fontSize: 16.0,
                  fontFamily: kFontFamily
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

