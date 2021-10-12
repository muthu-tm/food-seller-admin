import 'package:chipchop_seller/screens/Home/AuthPage.dart';
import 'package:chipchop_seller/screens/home/LoginPage.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('mobile_number') ?? "";
  String userName = prefs.getString('user_name') ?? "";
  String userImage = prefs.getString('user_profile_pic') ?? "";
  runApp(MyApp(userID, userName, userImage));
}

class MyApp extends StatefulWidget {
  MyApp(this.userID, this.userName, this.userImage);

  final String userImage;
  final String userName;
  final String userID;

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Analytics.setupAnalytics(analytics, observer);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: seller_app_name,
      theme: ThemeData(
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      navigatorObservers: <NavigatorObserver>[observer],
      home: (widget.userID != "")
          ? AuthPage()
          : LoginPage(true, null),
    );
  }
}
