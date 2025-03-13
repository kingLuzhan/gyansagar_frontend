import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/auth/widgets/Otp_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:provider/provider.dart';

class VerifyOtpScreen extends StatefulWidget {
  VerifyOtpScreen({Key? key, required this.onSucess}) : super(key: key);
  final Function onSucess;
  static MaterialPageRoute getRoute({required Function onSucess}) {
    return MaterialPageRoute(
      builder: (_) => VerifyOtpScreen(onSucess: onSucess),
    );
  }

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  late TextEditingController email;
  late TextEditingController name;
  late TextEditingController password;
  late TextEditingController mobile;

  @override
  void initState() {
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    mobile = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    password.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    mobile.dispose();
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

  void _submit(BuildContext context) async {
    try {
      final isValidate = _formKey.currentState?.validate() ?? false;
      if (!isValidate) {
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
      final state = Provider.of<AuthState>(context, listen: false);
      isLoading.value = true;
      final isSucess = await state.verifyOtp();
      if (isSucess) {
        widget.onSucess();
      } else {
        Alert.success(
          context,
          message: "Some error occurred. Please try again in some time!!",
          title: "Message",
          height: 170,
          onPressed: () {
            Navigator.of(context).pop(); // or any other action you want to perform
          },
        );
      }
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      print("Screen ${error.toString()}");
      Utility.displaySnackbar(context, msg: error.toString(), key: scaffoldKey);
    }
    print("End");
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<AuthState>(context, listen: false);
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
            SizedBox(height: 20),
            Image.asset(AppConfig.of(context)?.config.appIcon ?? '', height: 150),
            SizedBox(height: 10),
            Text(
              "Please enter OTP we’ve sent you on ${state.email ?? state.mobile}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).hP16,
            SizedBox(height: 10),
            SizedBox(height: 10),
            Consumer<AuthState>(
              builder: (context, state, child) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: OTPTextField(
                    clearOTP: true,
                    onSubmitted: (val) {
                      print(val);
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PFlatButton(
                  label: "Verify",
                  color: PColors.secondary,
                  isLoading: isLoading,
                  onPressed: () {
                    _submit(context);
                  },
                )),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: PColors.white,
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
                      _title("Verify OTP"),
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