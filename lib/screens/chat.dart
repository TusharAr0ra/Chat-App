import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/Widgets/chat_messages.dart';
import 'package:chat_app/Widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotifications() async {
    //fcm = firebase cloud messaging
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    // final token =
    await fcm.getToken();
    //you can send this token (via http or firestore SDK) to a backend

    fcm.subscribeToTopic('chat'); //to send notification to everyone.

    //notification bhejne ke liye firebase mei hi krna pdta hai, "functions" mei jaake.
    //pr uske liye paise lgte hai or credit card dalna pdta hai.
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TusharChat'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () {
                FirebaseAuth.instance.signOut();
                //for signing out
              },
              icon: const Icon(Icons.logout),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        body: const Column(children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ]));
  }
}
