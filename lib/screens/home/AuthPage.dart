import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/user.dart';
import 'package:chipchop_seller/screens/Home/HomeScreen.dart';
import 'package:chipchop_seller/screens/Home/LoginPage.dart';
import 'package:chipchop_seller/screens/Home/MobileSigninPage.dart';
import 'package:chipchop_seller/screens/Home/update_app.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_seller/services/utils/hash_generator.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.sellerLightGrey,
      body: Center(
        child: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: _prefs.then(
              (SharedPreferences prefs) {
                return (prefs.getString('mobile_number') ?? '');
              },
            ),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != '') {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: User().getByID(snapshot.data),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.done) {
                        if (userSnapshot.data == null) {
                          return LoginPage(false, _scaffoldKey);
                        } else {
                          User _user = User.fromJson(userSnapshot.data);
                          return SecretKeyAuth(_user, _scaffoldKey);
                        }
                      } else if (userSnapshot.hasError) {
                        return LoginPage(false, _scaffoldKey);
                      } else if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.30,
                              ),
                              ClipRRect(
                                child: Image.asset(
                                  "images/icons/logo.png",
                                  height: 80,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child:
                                    shadowGradientText("ChipChop Seller", 16.0),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              Text(
                                "Serving From",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: CustomColors.sellerGrey,
                                  fontSize: 12,
                                  fontFamily: "Georgia",
                                ),
                              ),
                              shadowGradientText("Fourcup Inc.", 20.0),
                            ],
                          ),
                        );
                      } else {
                        return LoginPage(false, _scaffoldKey);
                      }
                    },
                  );
                } else {
                  return LoginPage(false, _scaffoldKey);
                }
              } else if (snapshot.hasError) {
                return LoginPage(false, _scaffoldKey);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncWaiting(),
                  ),
                );
              } else {
                return LoginPage(false, _scaffoldKey);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget shadowGradientText(String text, double size) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          CustomColors.sellerButtonGreen,
          CustomColors.sellerPurple,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: CustomColors.sellerWhite,
          fontSize: size,
          fontFamily: "Georgia",
        ),
      ),
    );
  }
}

class SecretKeyAuth extends StatefulWidget {
  SecretKeyAuth(this._user, this._scaffoldKey);

  final User _user;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  _SecretKeyAuthState createState() => _SecretKeyAuthState();
}

class _SecretKeyAuthState extends State<SecretKeyAuth> {
  TextEditingController _pController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();

    if (widget._user.preferences.isfingerAuthEnabled) biometric();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            CustomColors.sellerButtonGreen,
            CustomColors.sellerBlack,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          Flexible(
            child: widget._user.getProfilePicPath() == ""
                ? Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: CustomColors.sellerButtonGreen,
                          style: BorderStyle.solid,
                          width: 2.0),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 45.0,
                      color: CustomColors.sellerLightGrey,
                    ),
                  )
                : CircleAvatar(
                    radius: 45.0,
                    backgroundImage:
                        NetworkImage(widget._user.getProfilePicPath()),
                    backgroundColor: Colors.transparent,
                  ),
          ),
          Text(
            widget._user.firstName,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: CustomColors.sellerLightGrey,
            ),
          ),
          Text(
            widget._user.mobileNumber.toString(),
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: CustomColors.sellerLightGrey,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Card(
              child: TextFormField(
                textAlign: TextAlign.center,
                obscureText: true,
                autofocus: false,
                controller: _pController,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context).translate('secret_key'),
                  fillColor: CustomColors.sellerWhite,
                  filled: true,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              (widget._user.preferences.isfingerAuthEnabled)
                  ? FlatButton(
                      onPressed: () async {
                        await biometric();
                      },
                      child: Text(
                        "Fingerprint",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: CustomColors.sellerGrey,
                          fontSize: 11.0,
                        ),
                      ),
                    )
                  : Container(),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginPage(true, widget._scaffoldKey),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate('forget_key'),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: CustomColors.sellerOrange,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(20.0)),
          InkWell(
            onTap: () {
              _submit(widget._user);
            },
            child: Container(
              width: 150.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: CustomColors.sellerButtonGreen,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate('login'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Georgia',
                    color: CustomColors.sellerWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('no_account'),
                  style: TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Georgia',
                    color: CustomColors.sellerOrange,
                  ),
                ),
                FlatButton(
                  splashColor: CustomColors.sellerWhite,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => MobileSignInPage(),
                        settings: RouteSettings(name: '/signup'),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('sign_up'),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.sellerButtonGreen,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  biometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics;
        availableBiometrics = await auth.getAvailableBiometrics();

        if (availableBiometrics.isNotEmpty) {
          bool authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Touch your finger on the sensor to login',
              useErrorDialogs: true,
              sensitiveTransaction: true,
              stickyAuth: true);
          if (authenticated) {
            await login(widget._user);
          } else {
            widget._scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                  2),
            );
            return;
          }
        } else {
          widget._scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar(
                "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                2),
          );
          return;
        }
      }
    } catch (e) {
      widget._scaffoldKey.currentState.showSnackBar(
        CustomSnackBar.errorSnackBar(
            "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
            2),
      );
    }
  }

  login(User _user) async {
    CustomDialogs.actionWaiting(
        context, AppLocalizations.of(context).translate('logging_in'));

    var result = await _authController.signInWithMobileNumber(_user);

    if (!result['is_success']) {
      Navigator.pop(context);
      widget._scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('unable_to_login'), 2));
      widget._scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => UpdateApp(
            child: HomeScreen(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _submit(User _user) async {
    if (_pController.text.length == 0) {
      widget._scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('your_secret_key'), 2));
      return;
    } else {
      String hashKey = HashGenerator.hmacGenerator(
          _pController.text, _user.countryCode + _user.mobileNumber.toString());
      if (hashKey != _user.password) {
        widget._scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar(
                AppLocalizations.of(context).translate('wrong_secret_key'), 2));
        return;
      } else {
        await login(_user);
      }
    }
  }
}
