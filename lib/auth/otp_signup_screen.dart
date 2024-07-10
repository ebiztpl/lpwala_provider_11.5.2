import 'dart:convert';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../components/back_widgets.dart';
import '../components/base_scaffold_body.dart';
import '../handyman/handyman_dashboard_screen.dart';
import '../main.dart';
import '../models/signup_with_otp.dart';
import '../models/user_data.dart';
import '../networks/rest_apis.dart';
import '../provider/provider_dashboard_screen.dart';
import '../utils/common.dart';

class OTPSignupScreen extends StatefulWidget {
  final String ? otp;
  final String ? mobileNumber;
  final String ? userType;

  const OTPSignupScreen({Key? key, required this.otp, required this.mobileNumber, this.userType}) : super(key: key);

  @override
  State<OTPSignupScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPSignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();

  Country selectedCountry = defaultCountry();

  String otpCode = '';
  String verificationId = '';

  bool isCodeSent = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  /*Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      showPhoneCode: true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }*/

  /*Future<void> submitOtp() async {
    log(widget.otp);
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.validate().length >= OTP_TEXT_FIELD_LENGTH) {
        hideKeyboard(context);
        appStore.setLoading(true);

        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
          UserCredential credentials = await FirebaseAuth.instance.signInWithCredential(credential);

          Map<String, dynamic> request = {
            'username': numberController.text.trim(),
            'password': numberController.text.trim(),
            'login_type': LOGIN_TYPE_OTP,
            "uid": credentials.user!.uid.validate(),
          };

          try {
            await loginUser(request, isSocialLogin: true).then((loginResponse) async {
              if (loginResponse.isUserExist.validate(value: true)) {
                await saveUserData(loginResponse.userData!);
                await appStore.setLoginType(LOGIN_TYPE_OTP);
                DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
              } else {
                appStore.setLoading(false);
                finish(context);

                SignUpScreen(
                  isOTPLogin: true,
                  phoneNumber: numberController.text.trim(),
                  countryCode: selectedCountry.countryCode,
                  uid: credentials.user!.uid.validate(),
                  tokenForOTPCredentials: credential.token,
                ).launch(context);
              }
            }).catchError((e) {
              finish(context);
              toast(e.toString());
              appStore.setLoading(false);
            });
          } catch (e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          }
        } on FirebaseAuthException catch (e) {
          appStore.setLoading(false);
          if (e.code.toString() == 'invalid-verification-code') {
            toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
          } else {
            toast(e.message.toString(), print: true);
          }
        } on Exception catch (e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        }
      } else {
        toast(language.pleaseEnterValidOTP);
      }
    } else {
      toast(language.pleaseEnterValidOTP);
    }
  }

  Future<void> submitOtpNewMeth() async {
    log(otpCode);

    hideKeyboard(context);
    appStore.setLoading(true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
      //UserCredential credentials = await FirebaseAuth.instance.signInWithCredential(credential);

      Map<String, dynamic> request = {
        'mobile': widget.mobileNumber,
        'otp': widget.otp,
      };

      try {
        await loginUserssss(request, isSocialLogin: true).then((LoginOtpResponse) async {
          if (LoginOtpResponse.isUserExist.validate(value: true)) {
            await saveUsersData(LoginOtpResponse.userData!);
            await appStore.setLoginType(LOGIN_TYPE_OTP);
            DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
          } else {
            appStore.setLoading(false);
            finish(context);
          }
        }).catchError((e) {
          finish(context);
          toast(e.toString());
          appStore.setLoading(false);
        });
      } catch (e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      }


    }  on Exception catch (e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    }
  }*/

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'user_type': widget.userType,
      'mobile': widget.mobileNumber,
      'otp': widget.otp,
    };

    appStore.setLoading(true);
    try {
      SignupWithOtpResponse user = await SignUpOtpUser(request);

      if(user.status == true){
        appStore.setLoading(false);
        toast(user.data);
        push(SignInScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      }else{
        appStore.setLoading(false);
        return toast(user.data);
      }
     /* if (user.status != 1) {
        appStore.setLoading(false);
        return toast(languages.pleaseContactYourAdmin);
      }*/

      //OTPLoginNewScreen(otp: registerResponse.userData!.otp!.toString(), mobileNumber: buildMobileNumber(),).launch(context);

      //await setValue(USER_PASSWORD, passwordCont.text);
      //await setValue(IS_REMEMBERED, isRemember);
      //await saveUserData(user);

      //authService.verifyFirebaseUser();

      //redirectWidget(res: user);
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void redirectWidget({required UserData res}) async {
    appStore.setLoading(false);
    TextInput.finishAutofillContext();

    if (res.status.validate() == 1) {
      await appStore.setToken(res.apiToken.validate());
      appStore.setTester(res.email == DEFAULT_PROVIDER_EMAIL || res.email == DEFAULT_HANDYMAN_EMAIL);

      if (res.userType.validate().trim() == USER_TYPE_PROVIDER) {
        ProviderDashboardScreen(index: 0).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else if (res.userType.validate().trim() == USER_TYPE_HANDYMAN) {
        HandymanDashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        toast(languages.cantLogin, print: true);
      }
    } else {
      toast(languages.lblWaitForAcceptReq);
    }
  }

  // endregion

  Widget _buildMainWidget() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          32.height,
          OTPTextField(
            pinLength: 6,
            textStyle: primaryTextStyle(),
            decoration: inputDecoration(context).copyWith(
              counter: Offstage(),
            ),
            onChanged: (s) {
              otpCode = s;
              log(otpCode);
            },
            onCompleted: (pin) {
              otpCode = pin;
             // submitOtp();
            },
          ).fit(),
          30.height,
          AppButton(
            onTap: () {
              if(widget.otp == otpCode){
                _handleLoginUsers();
                //submitOtpNewMeth();
                //print("Gogogoog=="+widget.otp.toString());
              }else{
                toast('OTP is Invalid');
                //print("notpossible");
              }

              //submitOtp();
            },
            text: languages.confirm,
            color: primaryColor,
            textColor: Colors.white,
            width: context.width(),
          ),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: context.scaffoldBackgroundColor,
        leading: Navigator.of(context).canPop() ? BackWidgets(iconColor: context.iconColor) : null,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: Body(
        child: Container(
          padding: EdgeInsets.all(16),
          child: _buildMainWidget(),
        ),
      ),
    );
  }
}
