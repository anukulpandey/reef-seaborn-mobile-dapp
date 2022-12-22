import 'package:flutter/material.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/components/page_layout.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    SplashApp(
      key: UniqueKey(),
      displayOnInit: () {
        return const BottomNav();
      },
      
    ),
  );
}
