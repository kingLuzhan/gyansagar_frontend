import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/auth/forgot_password.dart';
import 'package:gyansagar_frontend/ui/page/auth/signup.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_student.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_teacher.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => LoginPage(),
    );
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  ValueNotifier<bool> useMobile = ValueNotifier<bool>(false);
  ValueNotifier<bool> passwordVisibility = ValueNotifier<bool>(true);

  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController mobile;
  late CustomLoader loader;

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    mobile = TextEditingController();
    loader = CustomLoader();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    mobile.dispose();
    useMobile.dispose();
    isLoading.dispose();
    passwordVisibility.dispose();
    super.dispose();
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

  void _submit(BuildContext context) async {
    try {
      final isValidate = _formKey.currentState?.validate() ?? false;
      if (!isValidate) {
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
      final state = Provider.of<AuthState>(context, listen: false);
      state.setEmail = email.text;
      state.setMobile = mobile.text;
      state.setPassword = password.text;
      isLoading.value = true;
      final isSucess = await state.login();
      checkLoginStatus(isSucess);
    } catch (error) {
      print("Screen ${error.toString()}");
      Utility.displaySnackbar(context, msg: error.toString(), key: scaffoldKey);
    }
    isLoading.value = false;
  }

  void checkLoginStatus(bool isSucess) async {
    if (isSucess) {
      final getIt = GetIt.instance;
      final prefs = getIt<SharedPreferenceHelper>();
      final isStudent = await prefs.isStudent();
      Navigator.of(context).pushAndRemoveUntil(
        isStudent ? StudentHomePage.getRoute() : TeacherHomePage.getRoute(),
            (_) => false,
      );
    } else {
      Alert.success(context,
          message: "Some error occurred. Please try again in some time!!",
          title: "Message",
          height: 170,
          onPressed: () {
            Navigator.of(context).pop(); // or any other action you want to perform
          });
    }
    loader.hideLoader();
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppTheme.fullWidth(context) - 32,
      margin: EdgeInsets.symmetric(vertical: 16) + EdgeInsets.only(top: 32),
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
            SizedBox(height: 30),
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
                      ).hP16
                          : PTextField(
                        key: ValueKey(2),
                        type: Type.phone,
                        controller: mobile,
                        label: "Mobile No.",
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
                    ).p(8).ripple(() {
                      useMobile.value = !useMobile.value;
                      if (value) {
                        email.clear();
                      } else {
                        mobile.clear();
                      }
                    }).pR(8),
                  );
                }),
            ValueListenableBuilder<bool>(
                valueListenable: passwordVisibility,
                builder: (context, value, child) {
                  return PTextField(
                      type: Type.password,
                      controller: password,
                      label: "Password",
                      hintText: "Enter password here",
                      obscureText: value,
                      suffixIcon: IconButton(
                        onPressed: () {
                          passwordVisibility.value = !passwordVisibility.value;
                        },
                        icon: Icon(
                            value ? Icons.visibility_off : Icons.visibility),
                      )).hP16;
                }),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Forgot password?",
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: PColors.secondary, fontSize: 12))
                  .p16
                  .ripple(() {
                Provider.of<AuthState>(context, listen: false).clearData();
                Navigator.push(context, ForgotPasswordPage.getRoute());
              }),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PFlatButton(
                label: "Login",
                color: PColors.secondary,
                isLoading: isLoading,
                onPressed: () {
                  _submit(context);
                },
              ),
            )
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

  Widget _googleLogin(BuildContext context) {
    return Center(
      child: Container(
        height: 50,
        width: AppTheme.fullWidth(context) - 32,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xffeaeaea),
              offset: Offset(4, 4),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: <Widget>[
            Image.asset("assets/images/google_icon.png", height: 30),
            Spacer(),
            Text("Continue with Google"),
            Spacer(),
          ],
        ),
      ).ripple(() async {
        loader.showLoader(context);
        var isSucess = await Provider.of<AuthState>(context, listen: false)
            .signInWithGoogle();
        checkLoginStatus(isSucess);
      }).p16,
    );
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
                      _form(context),
                      _googleLogin(context),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 150,
                        child: Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account ?",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey)),
                          Text("SIGN UP",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold))
                              .p16
                              .ripple(() {
                            Provider.of<AuthState>(context, listen: false)
                                .clearData();
                            Navigator.push(context, SignUp.getRoute());
                          }),
                        ],
                      ),
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