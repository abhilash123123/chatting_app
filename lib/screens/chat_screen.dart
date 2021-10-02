import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //there might be an error with FirebaseFirestore, it was given jus firestore in the tutorial
  final _firestore = FirebaseFirestore.instance;
  final _auth=FirebaseAuth.instance;
  late User loggedInUser;
  late String messageText;
  final messagetextcontrolller =TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }

  void messagestream() async{
    await for (var snapshot in _firestore.collection('messages').snapshots()){
      for(var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagestream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Cloud Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
              {
                if (!snapshot.hasData){
                  return const Center(
                    child:  CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  final messages = snapshot.data!.docs.reversed;
                  List<MessageBubble> messageBubbles = [];
                  for( var message in messages){
                    final messagetext = message.data() as Map;
                    final messagetext1 = messagetext['text'];
                    final messagesender = message.data() as Map;
                    final messagesender1 = messagesender['sender'];

                    final currentuser = loggedInUser.email;


                    final messageBubble = MessageBubble(sender: messagesender1, text: messagetext1, ismyself: currentuser ==messagesender1,);

                    messageBubbles.add(messageBubble);


                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageBubbles,
                    ),
                  );


              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: messagetextcontrolller,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },

                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      messagetextcontrolller.clear();
                      //Implement send functionality.
                      print(loggedInUser.email);
                      print(messageText);
                      try {
                        await _firestore.collection('messages').add({
                          'text': messageText.toString(),
                          'sender': loggedInUser.email.toString(),
                        });
                      }
                      catch (e){
                        print (e);
                      }

                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.sender,required this.text, required this.ismyself});

  final String sender;
  final String text;
  final bool ismyself;
  // if(sender = loggedInUser.email.toString())



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(

        crossAxisAlignment: ismyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children:  [
          Text(
              sender,
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
            borderRadius: ismyself ? BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)) : BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: ismyself ? Colors.lightBlueAccent : Colors.teal,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                  text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
