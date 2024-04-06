import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      // theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      //  darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder(
          //ye stream btayegi ki humare paas user ka data hai already ya nhi
          //mtlb ye ek notfier ki trh hai or bta dega ki state change hui hai ya ni.
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            //snapshot hoga agr toh direct chatscreen dikhayenge nhi toh
            //login ya signup screen jaayegi.
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
                //ye splash screen ke liye hai, agr glti se firebase kmla slow hai toh fir
                //splash screen dikha denge.
              }
              return const ChatScreen();
            }
            return const AuthScreen();
          }),
    );
  }
}
