import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../utils/ScreenUtils.dart';
import '../utils/Utils.dart';
import '../utils/color_code.dart';
import '../widgets/logintextfield.dart';
import '../widgets/validator.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _LoginState();
}

class _LoginState extends State<CreateAccount> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  bool value = false;
  final GlobalKey<FormState> loginFormGlobalKey = GlobalKey<FormState>();
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
      body: GetBuilder<LoginController>(builder: (contorller) {
        return SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Form(
              key: loginFormGlobalKey,
              child: Padding(
                padding: ScreenUtils.isLargeScreen(context)
                    ? EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.2,
                        right: MediaQuery.of(context).size.width * 0.2)
                    : EdgeInsets.all(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _imageLogo(height,context),
                    Gap(height * 0.06),
                    _createAccount(width, height),
                    Gap(height * 0.02),
                    _fNameTextField(),
                    Gap(height * 0.02),
                    _lNameTextField(),
                    Gap(height * 0.02),
                    _emailTextField(),
                    Gap(height * 0.03),
                    _passwordTextField(),
                    _agreeTermsRow(context, height, width),
                    Gap(height * 0.1 + 14),
                    _createButton(context, width, height, contorller),
                    const Gap(6),
                    _loginText(width)
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  _imageLogo(height,context) {
      return Image.asset('assets/splash_image.png',
      height: MediaQuery.of(context).size.height*0.1,
      width: MediaQuery.of(context).size.width *0.1,
    ).paddingOnly(top: height * 0.1);
  }

  _createAccount(width, height) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Create an Account",
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins SemiBold',
            fontSize: height * 0.03),
      ).paddingOnly(left: width * 0.09),
    );
  }

  _emailTextField() {
    return TextFieldWidget(
      'Email',
      'admin@gmail.com',
      '',
      validate: (value) {
        return EmailValidator.validateEmail(value);
      },
      isEmail: true,
      controller: emailController,
    );
  }

  _fNameTextField() {
    return TextFieldWidget(
      'First Name',
      'admin@gmail.com',
      '',
      controller: fnameController,
    );
  }

  _lNameTextField() {
    return TextFieldWidget(
      'Last name',
      'admin@gmail.com',
      '',
      controller: lnameController,
    );
  }

  _passwordTextField() {
    return TextFieldWidget(
      'Password',
      'Enter Password',
      'Please Enter Password',
      isPass: true,
      validate: (String? value) {
        if (value!.isEmpty) {
          return 'Password cannot be empty!';
        }
      },
      controller: passwordController,
    );
  }

  _agreeTermsRow(context, height, width) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                right: 1.0,
                bottom: ScreenUtils.isSmallScreen(context)
                    ? height * 0.03 - 4
                    : height * 0.0),
            child: Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: value,
                checkColor: Theme.of(context).secondaryHeaderColor,
                activeColor: Theme.of(context).primaryColor,
                side: BorderSide(
                    color: Color(Utils.hexStringToHexInt(
                        ColorsCode.textfieldborderColor))),
                onChanged: (value) {
                  setState(() {
                    this.value = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: RichText(
              textScaleFactor: 1.2,
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text:
                          'I consent to ChatKaro using my personal data according to ChatKaro\'s ',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins Regular",
                      )),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontFamily: "Poppins Regular",
                        color: Color(Utils.hexStringToHexInt(
                            ColorsCode.textfieldborderColor))),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ).paddingOnly(
          left:
              ScreenUtils.isSmallScreen(context) ? width * 0.04 : width * 0.06,
          top: height * 0.02,
          right: width * 0.08),
    );
  }

  _createButton(context, width, height, LoginController contorller) {
    return Utils().createButton(
        context,
        "Create Account",
        width,
        ScreenUtils.isSmallScreen(context)
            ? (ScreenUtils.isSmallfont(context)
                ? height * 0.07 + 5
                : height * 0.07 + 9)
            : height * 0.07, () {
      if (loginFormGlobalKey.currentState!.validate()) {
        contorller.creatNewUser(
            context: context,
            email: emailController.value.text,
            fNmae: fnameController.value.text,
            lName: lnameController.value.text,
            pass: passwordController.value.text);
      }
    }, contorller).paddingOnly(
        left: ScreenUtils.isSmallScreen(context)
            ? width * 0.1 + 22
            : width * 0.1 + 22,
        right: ScreenUtils.isSmallScreen(context)
            ? width * 0.1 + 22
            : width * 0.1 + 22);
  }

  _loginText(width) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: MouseRegion(
        onEnter: (_) {
          controller.isLoginCreat = true;
        },
        onExit: (_) {
          controller.isLoginCreat = false;
        },
        child: Transform.scale(
            scale: controller.isLoginCreat ? 1.2 : 1.0,
            child: Text(
              'Login',
              style: TextStyle(
                color: controller.isLoginCreat ? Colors.indigo : Colors.white,
                fontSize: ScreenUtils.isSmallScreen(context)
                    ? width * 0.05
                    : width * 0.03,
                fontFamily: "Poppins Regular",
                  decoration: controller.isLoginCreat
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: Colors.indigo,
                  decorationThickness: 2
              ),
            )
        ),
      ),
    );
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
