import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/auth/verify_Otp.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_student.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_teacher.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => const SignUp(),
    );
  }

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  late TextEditingController email;
  late TextEditingController name;
  late TextEditingController password;
  ValueNotifier<bool> passwordVisibility = ValueNotifier<bool>(true);

  @override
  void initState() {
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    password.dispose();
    name.dispose();
    email.dispose();
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
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(500),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Theme.of(context).dividerColor,
                  offset: const Offset(0, 4),
                  blurRadius: 5)
            ]),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppTheme.fullWidth(context) - 32,
      margin: const EdgeInsets.symmetric(vertical: 32) + const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0xffeaeaea),
            offset: Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            Image.asset(AppConfig.of(context)!.config.appIcon, height: 150),
            const SizedBox(height: 30),
            PTextField(
              type: FieldType.text,
              controller: name,
              label: "Name",
              hintText: "Enter name.",
            ).hP16,
            PTextField(
              type: FieldType.email,
              controller: email,
              label: "Email",
              hintText: "Enter email here",
            ).hP16,
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: passwordVisibility,
              builder: (context, value, child) {
                return PTextField(
                    type: FieldType.password,
                    controller: password,
                    label: "Password",
                    hintText: "Enter password here",
                    obscureText: value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        passwordVisibility.value = !passwordVisibility.value;
                      },
                      icon:
                      Icon(value ? Icons.visibility_off : Icons.visibility),
                    )).hP16;
              },
            ),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PFlatButton(
                  label: "Create",
                  color: PColors.secondary,
                  isLoading: isLoading,
                  onPressed: () {
                    _submit(context);
                  },
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) async {
    try {
      final isValidate = _formKey.currentState?.validate() ?? false;
      if (!isValidate) {
        return;
      }
      final state = Provider.of<AuthState>(context, listen: false);
      state.setEmail = email.text;
      state.setName = name.text;
      state.setPassword = password.text;
      isLoading.value = true;
      final isSucess = await state.register();
      if (isSucess) {
        Navigator.push(context, VerifyOtpScreen.getRoute(onSucess: () async {
          final getIt = GetIt.instance;
          final prefs = getIt.get<SharedPreferenceHelper>();
          final isStudent = await prefs.isStudent();
          Navigator.of(context).pushAndRemoveUntil(
            isStudent ? StudentHomePage.getRoute() : TeacherHomePage.getRoute(),
                (_) => false,
          );
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
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      print("Signup screen ${error.toString()}");
      Utility.displaySnackbar(context, msg: error.toString(), key: scaffoldKey);
    }
    print("End");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: PColors.secondary,
      body: SizedBox(
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
                      SizedBox(
                        width: 150,
                        child: Divider(
                          color: theme.colorScheme.onPrimary ?? Colors.white,
                          thickness: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Already have an account ?",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white60)),
                          Text("SIGN IN",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimary ?? Colors.white))
                              .p16
                              .ripple(() {
                            Provider.of<AuthState>(context, listen: false)
                                .clearData();
                            Navigator.pop(context);
                          }),
                        ],
                      ),
                      const SizedBox(width: 40)
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