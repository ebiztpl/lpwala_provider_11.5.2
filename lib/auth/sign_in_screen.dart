import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/component/user_demo_mode_screen.dart';
import 'package:handyman_provider_flutter/auth/forgot_password_dialog.dart';
import 'package:handyman_provider_flutter/auth/otp_loginnew_screen.dart';
import 'package:handyman_provider_flutter/auth/sign_up_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/login_with_otp_response.dart';
import '../models/user_type_response.dart';
import '../networks/rest_apis.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Text Field Controller
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();

  //add by me
  List<UserTypeData> userTypeList = [UserTypeData(name: languages.selectUserType, id: -1)];
  UserTypeData? selectedUserTypeData;
  //add by me

  /// FocusNodes
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode userTypeFocus = FocusNode();

  bool isRemember = getBoolAsync(IS_REMEMBERED);
  String? selectedUserTypeValue;
  String _groupValue = 'provider';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (await isIqonicProduct) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
      setState(() {});
    }
  }

  //region Widgets
  Widget _buildTopWidget() {
    return Column(
      children: [
        32.height,
        Text(languages.lblLoginTitle, style: boldTextStyle(size: 18)).center(),
        16.height,
        Text(
          languages.lblLoginSubtitle,
          style: secondaryTextStyle(size: 14),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 32).center(),
        64.height,
      ],
    );
  }

  Widget _buildForgotRememberWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                2.width,
                SelectedItemWidget(isSelected: isRemember).onTap(() async {
                  await setValue(IS_REMEMBERED, isRemember);
                  isRemember = !isRemember;
                  setState(() {});
                }),
                TextButton(
                  onPressed: () async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  },
                  child: Text(languages.rememberMe, style: secondaryTextStyle()),
                ),
              ],
            ),
            TextButton(
              child: Text(
                languages.forgotPassword,
                style: boldTextStyle(color: primaryColor, fontStyle: FontStyle.italic),
                textAlign: TextAlign.right,
              ),
              onPressed: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
            ).flexible()
          ],
        ),
        32.height,
      ],
    );
  }

  Widget _buildButtonWidget() {
    return Column(
      children: [
        AppButton(
          text: languages.signIn,
          height: 40,
          color: primaryColor,
          textStyle: boldTextStyle(color: white),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            //OTPLoginNewScreen(otp: registerResponse.userData!.otp!.toString(), mobileNumber: buildMobileNumber(),).launch(context);
            _handleLogin();
          },
        ),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(languages.doNotHaveAccount, style: secondaryTextStyle()),
            TextButton(
              onPressed: () {
                SignUpScreen().launch(context);
              },
              child: Text(
                languages.signUp,
                style: boldTextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  /*Widget _myRadioButton({required String title, required int value,Function? onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }*/

  //endregion

  //region Methods
  void _handleLogin() {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleLoginWithOtpUsers();
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'user_type': emailCont.text.trim(),
      'contact_number': passwordCont.text.trim(),
    };

    appStore.setLoading(true);
    try {
      UserData user = await loginUser(request);

      if (user.status != 1) {
        appStore.setLoading(false);
        return toast(languages.pleaseContactYourAdmin);
      }

      //OTPLoginNewScreen(otp: registerResponse.userData!.otp!.toString(), mobileNumber: buildMobileNumber(),).launch(context);

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await saveUserData(user);

      authService.verifyFirebaseUser();

      redirectWidget(res: user);
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void _handleLoginWithOtpUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'user_type': _groupValue,
      'contact_number': mobileCont.text.trim(),
    };

    appStore.setLoading(true);
    try {
      LoginWithOtpResponse user = await loginWithOtpUser(request);

      /*if (user.status != 1) {
        appStore.setLoading(false);
        return toast(languages.pleaseContactYourAdmin);
      }*/

      OTPLoginNewScreen(otp: user.otp, mobileNumber: user.contactNumber.toString(), userType: user.userType,).launch(context);

      /*await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await saveUserData(user);

      authService.verifyFirebaseUser();

      redirectWidget(res: user);*/
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

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        elevation: 0,
        showBack: false,
        color: context.scaffoldBackgroundColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: getStatusBrightness(val: appStore.isDarkMode), statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopWidget(),
                    AutofillGroup(
                      onDisposeAction: AutofillContextAction.commit,
                      child: Column(
                        children: [
                          /*AppTextField(
                            textFieldType: TextFieldType.EMAIL_ENHANCED,
                            controller: emailCont,
                            focus: emailFocus,
                            nextFocus: passwordFocus,
                            errorThisFieldRequired: languages.hintRequired,
                            decoration: inputDecoration(context, hint: languages.hintEmailAddressTxt),
                            suffix: ic_message.iconImage(size: 10).paddingAll(14),
                            autoFillHints: [AutofillHints.email],
                          ),
                          16.height,
                          AppTextField(
                            textFieldType: TextFieldType.PASSWORD,
                            controller: passwordCont,
                            focus: passwordFocus,
                            errorThisFieldRequired: languages.hintRequired,
                            suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
                            suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
                            errorMinimumPasswordLength: "${languages.errorPasswordLength} $passwordLengthGlobal",
                            decoration: inputDecoration(context, hint: languages.hintPassword),
                            autoFillHints: [AutofillHints.password],
                            onFieldSubmitted: (s) {
                              _handleLogin();
                            },
                          ),
                          8.height,*/
                          AppTextField(
                            textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                            controller: mobileCont,
                            focus: mobileFocus,
                            buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) {
                            },
                            errorThisFieldRequired: languages.requiredText,
                            nextFocus: passwordFocus,
                            decoration: inputDecorations(context, labelText: "${languages.hintContactNumberTxt}").copyWith(
                              //prefixText: '+${selectedCountrys.phoneCode} ',
                              ///hintText: '${languages.lblExample}: ${selectedCountry.example}',
                              hintStyle: secondaryTextStyle(),
                            ),
                            maxLength: 10,
                            suffix: ic_calling.iconImage(size: 10).paddingAll(14),
                          ),
                          //16.height,
                          /*DropdownButtonFormField<String>(
                            items: [
                              DropdownMenuItem(
                                child: Text(languages.provider, style: primaryTextStyle()),
                                value: USER_TYPE_PROVIDER,
                              ),
                              DropdownMenuItem(
                                child: Text(languages.handyman, style: primaryTextStyle()),
                                value: USER_TYPE_HANDYMAN,
                              ),
                            ],
                            focusNode: userTypeFocus,
                            dropdownColor: context.cardColor,
                            decoration: inputDecoration(context, hint: languages.userRole),
                            value: selectedUserTypeValue,
                            validator: (value) {
                              if (value == null) return errorThisFieldRequired;
                              return null;
                            },
                            onChanged: (c) {
                              hideKeyboard(context);
                              selectedUserTypeValue = c.validate();

                              userTypeList.clear();
                              selectedUserTypeData = null;
                              getUserType(type: selectedUserTypeValue!).then((value) {
                                userTypeList = value.userTypeData.validate();
                                setState(() {});
                              }).catchError((e) {
                                userTypeList = [UserTypeData(name: languages.selectUserType, id: -1)];
                                log(e.toString());
                              });
                            },
                          ),*/
                        ],
                      ),
                    ),
                    //_buildForgotRememberWidget(),
                    16.height,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('User Role', style: boldTextStyle(color: primaryColor, size: 12)).paddingLeft(8),
                          //Text('User Role', style: TextStyle(fontSize: 14)),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: RadioListTile(
                                        value: 'provider',
                                        groupValue: _groupValue,
                                        title:  Text('Provider', style: boldTextStyle(color: primaryColor, size: 14)),
                                        onChanged: (newValue) =>
                                            setState(() => _groupValue = newValue!),
                                        activeColor: primaryColor,
                                        selected: false,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: RadioListTile(
                                        value: 'handyman',
                                        groupValue: _groupValue,
                                        title: Text('Handyman', style: boldTextStyle(color: primaryColor, size: 14)),
                                        onChanged: (newValue) =>
                                            setState(() => _groupValue = newValue!),
                                        activeColor: primaryColor,
                                        selected: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    64.height,
                    _buildButtonWidget(),
                    /*16.height,
                    SnapHelperWidget<bool>(
                      future: isIqonicProduct,
                      onSuccess: (data) {
                        if (data) {
                          return UserDemoModeScreen(
                            onChanged: (email, password) {
                              if (email.isNotEmpty && password.isNotEmpty) {
                                emailCont.text = email;
                                passwordCont.text = password;
                              } else {
                                emailCont.clear();
                                passwordCont.clear();
                              }
                            },
                          );
                        }
                        return Offstage();
                      },
                    ),*/
                  ],
                ),
              ),
            ),
            Observer(
              builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
            ),
          ],
        ),
      ),
    );
  }
}
