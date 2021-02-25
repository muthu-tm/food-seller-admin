import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chipchop_seller/db/models/user.dart' as u;
import 'package:chipchop_seller/screens/app/ContactAndSupportWidget.dart';
import 'package:chipchop_seller/screens/home/update_app.dart';
import 'package:chipchop_seller/screens/home/MobileSigninPage.dart';
import 'package:chipchop_seller/screens/home/PhoneAuthVerify.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/services/controllers/auth/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chipchop_seller/app_localizations.dart';

// ENTER MOBILE NUMBER TO SEND OTP to LOGIN SCREEN

class LoginPage extends StatefulWidget {
  LoginPage(this.isNewScaffold, this._scaffoldKey);

  final bool isNewScaffold;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _nController = TextEditingController();
  AuthController _authController = AuthController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  u.User _user;

  String number = "";
  int countryCode = 91;
  String _smsVerificationCode;
  int _forceResendingToken;

  @override
  void initState() {
    super.initState();

    if (widget.isNewScaffold) {
      _scaffoldKey = GlobalKey<ScaffoldState>();
    } else {
      _scaffoldKey = widget._scaffoldKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isNewScaffold
        ? Scaffold(
            key: _scaffoldKey,
            backgroundColor: CustomColors.lightGrey,
            bottomNavigationBar: Text(
              "Powered by Fourcup Inc.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            extendBody: true,
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffD8F2A7), Color(0xffA4D649)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _getBody(),
              ),
            ),
          )
        : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffD8F2A7), Color(0xffA4D649)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _getBody(),
            ),
          );
  }

  Widget _getBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              child: Image.asset(
                "images/icons/logo.png",
                height: 80,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "UNIQUES",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "OLED",
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Buy Food, Vegetables & Groceries",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "WELCOME BACK!",
                  style: TextStyle(
                    fontFamily: "OLED",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 10, bottom: 15.0, left: 20.0, right: 20.0),
                child: TextFormField(
                  textAlign: TextAlign.start,
                  controller: _nController,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  decoration: InputDecoration(
                    prefix: Text('+91'),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: CustomColors.grey,
                      size: 25.0,
                    ),
                    hintText:
                        AppLocalizations.of(context).translate('mobile_number'),
                    hintStyle: TextStyle(fontSize: 16.0, color: Colors.black26),
                    fillColor: CustomColors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 5),
                  Icon(
                    Icons.info,
                    color: CustomColors.alertRed,
                    size: 20.0,
                  ),
                  SizedBox(width: 5.0),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)
                                .translate('we_will_send'),
                            style: TextStyle(
                                color: CustomColors.blue,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)
                                .translate('one_time_password'),
                            style: TextStyle(
                                color: CustomColors.alertRed,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)
                                .translate('to_mobile_no'),
                            style: TextStyle(
                                color: CustomColors.blue,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5.0)),
              SizedBox(
                height: 40,
                width: 125,
                child: RaisedButton(
                  color: CustomColors.alertRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  onPressed: () {
                    _submit();
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('get_otp'),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: CustomColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate('no_account'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: CustomColors.alertRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FlatButton(
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
                        fontWeight: FontWeight.bold,
                        color: CustomColors.blue,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
              FlatButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    routeSettings: RouteSettings(name: "/home/help"),
                    builder: (context) {
                      return Center(
                        child: contactAndSupportDialog(context),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.info,
                  color: CustomColors.blue,
                ),
                label: Text(
                  AppLocalizations.of(context).translate('help_support'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.blue,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (_nController.text.length != 10) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('enter_valid_phone'), 2));
      return;
    } else {
      CustomDialogs.showLoadingDialog(context, _keyLoader);

      number = _nController.text;
      try {
        Map<String, dynamic> _uJSON =
            await u.User().getByID(countryCode.toString() + number);
        if (_uJSON == null) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('invalid_user_signup'),
              2));
          return;
        } else {
          this._user = u.User.fromJson(_uJSON);
          _verifyPhoneNumber();
        }
      } on PlatformException catch (err) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Error while Login: " + err.message, 2),
        );
      } on Exception catch (err) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('login_error') +
                  err.toString(),
              2),
        );
      }
    }
  }

  _verifyPhoneNumber() async {
    String phoneNumber = '+' + countryCode.toString() + number;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }

  _verificationComplete(
      AuthCredential authCredential, BuildContext context) async {
    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((UserCredential authResult) async {
      final SharedPreferences prefs = await _prefs;
      prefs.setString("mobile_number", countryCode.toString() + number);

      var result = await _authController.signInWithMobileNumber(_user);

      if (!result['is_success']) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
            AppLocalizations.of(context).translate('unable_to_login'), 2));
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UpdateApp(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }).catchError((error) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
    });
  }

  _smsCodeSent(String verificationId, [code]) {
    _scaffoldKey.currentState
        .showSnackBar(CustomSnackBar.successSnackBar("OTP sent", 1));

    _smsVerificationCode = verificationId;
    _forceResendingToken = code;

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    CustomDialogs.showLoadingDialog(context, _keyLoader);
  }

  _verificationFailed(dynamic authException, BuildContext context) {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
        AppLocalizations.of(context).translate('verification_failed') +
            authException.message.toString(),
        2));
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _smsVerificationCode = verificationId;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PhoneAuthVerify(
            false,
            _user.mobileNumber.toString(),
            _user.countryCode,
            _user.password,
            _user.firstName,
            _user.lastName,
            _smsVerificationCode, _forceResendingToken),
      ),
    );
  }
}
