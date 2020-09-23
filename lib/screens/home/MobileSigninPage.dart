import 'package:chipchop_seller/screens/home/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_seller/db/models/user.dart';
import 'package:chipchop_seller/screens/home/update_app.dart';
import 'package:chipchop_seller/screens/home/PhoneAuthVerify.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/auth/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chipchop_seller/app_localizations.dart';

class MobileSignInPage extends StatefulWidget {
  @override
  _MobileSignInPageState createState() => _MobileSignInPageState();
}

class _MobileSignInPageState extends State<MobileSignInPage> {
  String number, _smsVerificationCode;
  int countryCode = 91;
  bool _passwordVisible = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passKeyController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.sellerLightGrey,
      body: SingleChildScrollView(
        child: _getBody(),
      ),
    );
  }

  Widget _getBody() => SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: _getColumnBody(),
        ),
      );

  Widget _getColumnBody() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: ClipRRect(
              child: Image.asset(
                "images/icons/logo.png",
                height: 80,
                width: 80,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Card(
              child: Row(
                children: <Widget>[
                  Text(
                    " +91",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: CustomColors.sellerGreen,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: _phoneNumberController,
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      key: Key('EnterPhone-TextFormField'),
                      decoration: InputDecoration(
                        fillColor: CustomColors.sellerWhite,
                        filled: true,
                        suffixIcon: Icon(
                          Icons.phone_android,
                          color: CustomColors.sellerFadedButtonGreen,
                          size: 35.0,
                        ),
                        hintText: AppLocalizations.of(context)
                            .translate('enter_phone_number'),
                        border: InputBorder.none,
                        errorMaxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Card(
              child: TextFormField(
                controller: _nameController,
                autofocus: false,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('name'),
                  fillColor: CustomColors.sellerWhite,
                  filled: true,
                  suffixIcon: Icon(
                    Icons.sentiment_satisfied,
                    color: CustomColors.sellerFadedButtonGreen,
                    size: 35.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Card(
              child: TextFormField(
                controller: _passKeyController,
                obscureText: _passwordVisible,
                keyboardType: TextInputType.number,
                maxLength: 4,
                maxLengthEnforced: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate('four_digit_secret'),
                  fillColor: CustomColors.sellerWhite,
                  filled: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: CustomColors.sellerFadedButtonGreen,
                      size: 35.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 5),
              Icon(Icons.info, color: CustomColors.sellerAlertRed, size: 20.0),
              SizedBox(width: 10.0),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('we_will_send'),
                      style: TextStyle(
                          color: CustomColors.sellerGreen,
                          fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('one_time_password'),
                      style: TextStyle(
                          color: CustomColors.sellerAlertRed,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('to_mobile_no'),
                      style: TextStyle(
                          color: CustomColors.sellerGreen,
                          fontWeight: FontWeight.w400)),
                ])),
              ),
              SizedBox(width: 5),
            ],
          ),
          SizedBox(height: 10),
          RaisedButton(
            elevation: 16.0,
            onPressed: startPhoneAuth,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                AppLocalizations.of(context).translate('get_otp'),
                style: TextStyle(
                  color: CustomColors.sellerLightGrey,
                  fontSize: 18.0,
                ),
              ),
            ),
            color: CustomColors.sellerBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Padding(padding: EdgeInsets.all(25.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: Text(
                  AppLocalizations.of(context).translate('already_account'),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Georgia',
                    color: CustomColors.sellerPositiveGreen,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).translate('login'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  startPhoneAuth() async {
    if (_phoneNumberController.text.length != 10) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('invalid_number'), 2));
      return;
    } else if (_nameController.text.length <= 2) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('enter_your_name'), 2));
      return;
    } else if (_passKeyController.text.length != 4) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('secret_key_validation'), 2));
      return;
    } else {
      CustomDialogs.actionWaiting(context);
      this.number = _phoneNumberController.text;

      var data = await User().getByID(countryCode.toString() + number);
      if (data != null) {
        Analytics.reportError({
          "type": 'sign_up_error',
          "user_id": countryCode.toString() + number,
          'name': _nameController.text,
          'error': "Found an existing user for this mobile number"
        }, 'sign_up');
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
            "Found an existing user for this mobile number", 2));
      } else {
        await _verifyPhoneNumber();
      }
    }
  }

  _verifyPhoneNumber() async {
    String phoneNumber = "+" + countryCode.toString() + number;
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
        .then((AuthResult authResult) async {
      dynamic result = await _authController.registerWithMobileNumber(
          int.parse(number),
          countryCode,
          _passKeyController.text,
          _nameController.text,
          "",
          authResult.user.uid);
      if (!result['is_success']) {
        Navigator.pop(context);
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
      } else {
        final SharedPreferences prefs = await _prefs;
        prefs.setString("mobile_number", countryCode.toString() + number);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UpdateApp(
              child: HomeScreen(),
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }).catchError((error) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
      _scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar("${error.toString()}", 2));
    });
  }

  _smsCodeSent(String verificationId, List<int> code) {
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.successSnackBar(
        AppLocalizations.of(context).translate('otp_send'), 1));

    _smsVerificationCode = verificationId;
    Navigator.pop(context);
    CustomDialogs.actionWaiting(context);
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    Navigator.pop(context);
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
        "Verification Failed:" + authException.message.toString(), 2));
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _smsVerificationCode = verificationId;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PhoneAuthVerify(
            true,
            number,
            countryCode,
            _passKeyController.text,
            _nameController.text,
            _smsVerificationCode),
      ),
    );
  }
}
