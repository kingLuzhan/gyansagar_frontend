import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/auth/update_password.dart';
import 'package:gyansagar_frontend/ui/page/auth/verify_Otp.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => ForgotPasswordPage(),
    );
  }

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> useMobile = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  late TextEditingController email;
  late TextEditingController mobile;

  @override
  void initState() {
    email = TextEditingController();
    mobile = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    useMobile.dispose();
    isLoading.dispose();
    mobile.dispose();
    email.dispose();
    super.dispose();
  }

  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontSize: 26, color: Colors.white),
      ),
    );
  }

  Positioned _background(BuildContext context) {
    return Positioned(
      top: -AppTheme.fullHeight(context) * .5,
      left: -AppTheme.fullWidth(context) * .55,
      child: Container(
        height: AppTheme.fullHeight(context),
        width: AppTheme.fullHeight(context),
        decoration: BoxDecoration(
            color: PColors.secondary,
            borderRadius: BorderRadius.circular(500),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Theme.of(context).dividerColor,
                  offset: Offset(0, 4),
                  blurRadius: 5)
            ]),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppTheme.fullWidth(context) - 32,
      margin: EdgeInsets.symmetric(vertical: 32) + EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xffeaeaea),
            offset: Offset(4, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Image.asset(AppConfig.of(context)!.config.appIcon, height: 150),
            SizedBox(height: 40),
            ValueListenableBuilder<bool>(
                valueListenable: useMobile,
                builder: (context, value, child) {
                  return customSwitcherWidget(
                      duraton: Duration(milliseconds: 300),
                      child: value
                          ? PTextField(
                        key: ValueKey(1),
                        type: Type.email,
                        controller: email,
                        label: "Email ID",
                        hintText: "Enter your email id",
                        height: null,
                      ).hP16
                          : PTextField(
                        key: ValueKey(2),
                        type: Type.phone,
                        controller: mobile,
                        label: "Mobile No.",
                        height: null,
                        hintText: "Enter your mobile no",
                      ).hP16);
                }),
            ValueListenableBuilder<bool>(
                valueListenable: useMobile,
                builder: (context, value, child) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      value ? "Use Phone Number" : "Use Email Id",
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: PColors.secondary, fontSize: 12),
                    ).p16.ripple(() {
                      useMobile.value = !useMobile.value;
                      if (value) {
                        email.clear();
                      } else {
                        mobile.clear();
                      }
                    }),
                  );
                }),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PFlatButton(
                label: "Send OTP",
                color: PColors.secondary,
                isLoading: isLoading,
                onPressed: () {
                  _submit(context);
                },
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget customSwitcherWidget(
      {required Widget child, Duration duraton = const Duration(milliseconds: 500)}) {
    return AnimatedSwitcher(
      duration: duraton,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: child,
    );
  }

  void _submit(BuildContext context) async {
    try {
      final isValidate = _formKey.currentState!.validate();
      if (!isValidate) {
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
      final state = Provider.of<AuthState>(context, listen: false);
      state.setEmail = email.text;
      state.setMobile = mobile.text;
      isLoading.value = true;
      final isSucess = await state.forgetPassword();
      checkLoginStatus(isSucess);
    } catch (error) {
      print("Screen ${error.toString()}");
      Utility.displaySnackbar(context, msg: error.toString(), key: scaffoldKey);
    }
    isLoading.value = false;
  }

  void checkLoginStatus(bool isSucess) async {
    if (isSucess) {
      Navigator.push(context, VerifyOtpScreen.getRoute(onSucess: () {
        Navigator.pop(context);
        Navigator.of(context).push(UpdatePasswordPage.getRoute());
      }));
    } else {
      Alert.success(context,
          message: "Some error occurred. Please try again in some time!!",
          title: "Message",
          height: 170,
          onPressed: () {
            Navigator.of(context).pop(); // or any other action you want to perform
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        height: AppTheme.fullHeight(context),
        child: SafeArea(
          top: false,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _background(context),
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 120),
                      _title("Forget password"),
                      _form(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}