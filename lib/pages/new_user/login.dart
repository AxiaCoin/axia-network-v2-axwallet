import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/pages/new_user/signup.dart';
import 'package:wallet/pages/new_user/verify.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/spinner.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  Mode mode = Mode.phone;
  TextEditingController emailController =
      new TextEditingController(text: kDebugMode ? "test@test.com" : "");
  TextEditingController passwordController =
      new TextEditingController(text: kDebugMode ? "1111111q%" : "");
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  bool obscurity = true;
  bool submitting = false;
  PhoneNumber phoneNumber = PhoneNumber(
    isoCode:
        StorageService.instance.isoCode ?? Platform.localeName.split('_').last,
    phoneNumber: kDebugMode ? "+919879879871" : null,
  );

  onSubmit() async {
    setState(() {
      submitting = true;
    });
    if (formKey.currentState!.validate()) {
      String deviceId = "";
      if (Platform.isAndroid) {
        var deviceInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = deviceInfo.androidId!;
      } else {
        var deviceInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = deviceInfo.identifierForVendor!;
      }
      var response = await APIServices().signIn(
          email: mode == Mode.email ? emailController.text : null,
          phoneNumber: mode == Mode.phone ? phoneNumber.parseNumber() : null,
          phoneCode:
              mode == Mode.phone ? phoneNumber.dialCode!.substring(1) : null,
          password: passwordController.text,
          deviceId: deviceId);
      if (response["success"]) {
        StorageService.instance.updateAuthToken(response["data"]["authToken"]);
        StorageService.instance.updateSessionID(response["data"]["sessionID"]);
        Services().loadUser();
        Get.off(() => OnboardPage());
      } else if (response.toString().contains("verify")) {
        print("send verify");
        var result = await APIServices().sendVerifyOTP(
          email: mode == Mode.email ? emailController.text : null,
          phoneNumber: mode == Mode.phone ? phoneNumber.parseNumber() : null,
          phoneCode:
              mode == Mode.phone ? phoneNumber.dialCode!.substring(1) : null,
        );
        if (result["success"]) {
          print("reset false");
          Get.to(() => VerificationPage(
              email: mode == Mode.email ? emailController.text : null,
              phoneNumber: mode == Mode.phone ? phoneNumber : null,
              resetPassword: false));
        }
      }
    }
    setState(() {
      submitting = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPhoneMode = mode == Mode.phone;
    print(Localizations.localeOf(context).countryCode.toString());
    Widget phoneField() => InternationalPhoneNumberInput(
          initialValue: phoneNumber,
          onInputChanged: (PhoneNumber number) {
            phoneNumber = number;
            StorageService.instance.updateISOCode(number.isoCode);
            print(number.phoneNumber);
          },
          onInputValidated: (bool value) {
            print(value);
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.DIALOG,
            trailingSpace: false,
            // setSelectorButtonAsPrefixIcon: true,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: TextStyle(color: Colors.black),
          // initialValue: number,
          formatInput: false,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          inputBorder: OutlineInputBorder(),
          validator: (_) => null,
          onSaved: (PhoneNumber number) {
            print('On Saved: $number');
          },
        );
    Widget emailField() => TextFormField(
          controller: emailController,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
          validator: (val) {
            String pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (!regex.hasMatch(val!))
              return 'Enter Valid Email';
            else
              return null;
          },
          onFieldSubmitted: (val) {
            passwordFocus.requestFocus();
          },
        );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          floatingActionButton: kDebugMode
              ? SpeedDial(
                  animatedIcon: AnimatedIcons.menu_home,
                  children: [
                    SpeedDialChild(
                        child: Icon(Icons.next_plan),
                        label: "HomePage",
                        onTap: () => Get.offAll(() => HomePage())),
                    SpeedDialChild(
                        child: Icon(Icons.api),
                        label: "Test WS",
                        onTap: () {
                          print("start");
                          // IO.Socket socket = IO.io("http://13.235.53.197:3001/socket.io/?EIO=4&transport=polling");
                          // IO.Socket socket = IO.io(
                          //     'http://13.235.53.197:3001',
                          //     IO.OptionBuilder()
                          //         .setTransports(['polling'])
                          //         .disableAutoConnect() // disable auto-connection
                          //         .setExtraHeaders({'foo': 'bar'}) // optional
                          //         .build());
                          // socket.connect();
                          // socket.onConnect((_) {
                          //   print('connect');
                          //   socket.emit('msg', 'test');
                          // });
                          // socket.on('event', (data) => print(data));
                          // socket.onDisconnect((_) => print('disconnect'));
                          // socket.on('fromServer', (_) => print(_));
                          print("end");
                        })
                  ],
                )
              : Container(),
          appBar: AppBar(
            title: Text("Login"),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
              child: Form(
            key: formKey,
            child: Stack(
              children: [
                Container(
                  height: Get.height * 0.15,
                  color: appColor[600],
                ),
                Container(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: CommonWidgets.elevatedContainer(
                        padding: 16,
                        margin: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: Get.width * 0.2,
                                width: Get.width * 0.2,
                                child: FlutterLogo()),
                            SizedBox(
                              height: 16,
                            ),
                            // Text(
                            //   "Login",
                            //   style: context.textTheme.headline4,
                            // ),
                            // SizedBox(
                            //   height: 32,
                            // ),
                            Text(
                              "Welcome to your Wallet",
                              style: context.textTheme.caption!
                                  .copyWith(fontSize: 24),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            isPhoneMode ? phoneField() : emailField(),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              controller: passwordController,
                              focusNode: passwordFocus,
                              obscureText: obscurity,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: isPhoneMode
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(obscurity
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () =>
                                        setState(() => obscurity = !obscurity),
                                  )),
                              validator: (val) => passwordController
                                          .text.length <
                                      8
                                  ? "The password should be 8 characters long"
                                  : null,
                              onFieldSubmitted: (val) {
                                if (!isPhoneMode)
                                  confirmPasswordFocus.requestFocus();
                              },
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            // isPhoneMode
                            //     ? Container()
                            //     : TextFormField(
                            //         focusNode: confirmPasswordFocus,
                            //         obscureText: obscurity,
                            //         keyboardType: TextInputType.visiblePassword,
                            //         textInputAction: TextInputAction.done,
                            //         decoration: InputDecoration(
                            //           labelText: "Confirm Password",
                            //           border: OutlineInputBorder(),
                            //         ),
                            //         validator: (val) => val == passwordController.text
                            //             ? null
                            //             : "The passwords do not match",
                            //       ),
                            // isPhoneMode
                            //     ? Container()
                            //     : SizedBox(
                            //         height: 16,
                            //       ),
                            SizedBox(
                              height: 16,
                            ),
                            submitting
                                ? Center(
                                    child: Spinner(),
                                  )
                                : Container(
                                    width: Get.width,
                                    child: TextButton(
                                      onPressed: () {
                                        onSubmit();
                                      },
                                      child: Text("LOGIN"),
                                      style: MyButtonStyles.onboardStyle,
                                    ),
                                  ),
                            SizedBox(
                              height: 32,
                            ),
                            Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() {
                                  mode = mode == Mode.phone
                                      ? Mode.email
                                      : Mode.phone;
                                }),
                                child: Text(
                                  mode == Mode.phone
                                      ? "Use email instead"
                                      : "Use phone number instead",
                                  style: context.textTheme.caption!.copyWith(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text.rich(TextSpan(
                                text: "Not yet registered? ",
                                style: context.textTheme.caption!
                                    .copyWith(color: Colors.black),
                                children: [
                                  WidgetSpan(
                                      child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    // onTap: () => setState(() => mode =
                                    //     isLoginMode ? Mode.register : Mode.login),
                                    onTap: () => Get.to(() => SignupPage()),
                                    child: Text(
                                      "Create Account",
                                      style: context.textTheme.caption!
                                          .copyWith(color: appColor),
                                    ),
                                  ))
                                ])),
                            SizedBox(
                              height: 16,
                            ),
                            Text.rich(TextSpan(
                                text: "Forgot Password? ",
                                style: context.textTheme.caption!
                                    .copyWith(color: Colors.black),
                                children: [
                                  WidgetSpan(
                                      child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    // onTap: () => setState(() => mode =
                                    //     isLoginMode ? Mode.register : Mode.login),
                                    onTap: () => Get.to(() => SignupPage(
                                          resetPassword: true,
                                        )),
                                    child: Text(
                                      "Reset it",
                                      style: context.textTheme.caption!
                                          .copyWith(color: appColor),
                                    ),
                                  ))
                                ])),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ))),
    );
  }
}

enum Mode { phone, email }
