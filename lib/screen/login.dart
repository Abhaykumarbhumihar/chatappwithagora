import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../utils/ScreenUtils.dart';
import '../utils/Utils.dart';
import '../utils/color_code.dart';
import '../widgets/double_back_press.dart';
import '../widgets/logintextfield.dart';
import '../widgets/validator.dart';
import 'create_account.dart';

class Login extends StatelessWidget {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    // controller.emailController.text = "diwanshut@solidappmaker.com";
    // controller.passwordController.text = "JhrXMc2ak3Qq";

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return DoubleBack(
      child: Scaffold(
        backgroundColor:
            Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
        body: GetBuilder<LoginController>(builder: (contorller) {
          return SizedBox(
            width: width,
            height: height,
            child: SingleChildScrollView(
              child: Form(
                key: contorller.loginFormGlobalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _logoImage(height),
                    Gap(height * 0.06),
                    _loginText(height, width, context),
                    Gap(height * 0.02),
                    _emailTextField(contorller),
                    Gap(height * 0.03),
                    _passwordTextField(contorller),
                    Gap(height * 0.03),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () {

                              controller.resetPassword(contorller.emailController.value.text);
                            },
                            child: Text("Forgot Password",style: TextStyle(
                              fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.indigo
                            ),),
                          ),
                        ),
                      ],
                    ),
                    _agreeTermsRow(width, height, context, contorller),
                    Gap(height * 0.1 + 14),
                    _loginButton(context, width, height, contorller),
                    const Gap(6),
                    _createAccountText(context, width, height)
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  _logoImage(height) {
    return SvgPicture.asset(
      'assets/svg/ICEF_WHITE.svg',
      color: Colors.white,
    ).paddingOnly(top: height * 0.1);
  }

  _loginText(height, width, context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Login To Your ICEF Account",
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins SemiBold',
            fontSize: ScreenUtils.isSmallScreen(context)
                ? height * 0.03
                : height * 0.03 - 5),
      ).paddingOnly(left: width * 0.09, right: 4.0),
    );
  }

  _emailTextField(LoginController contorller) {
    return TextFieldWidget(
      'Email',
      'admin@gmail.com',
      '',
      validate: (value) {
        return EmailValidator.validateEmail(value);
      },
      isEmail: true,
      controller: contorller.emailController,
    );
  }

  _passwordTextField(LoginController contorller) {
    return TextFieldWidget(
      'Password',
      'Enter Password',
      'Please Enter Password',
      validate: (String? value) {
        if (value!.isEmpty) {
          return 'Password cannot be empty!';
        }
      },
      isPass: true,
      controller: contorller.passwordController,
    );
  }

  _agreeTermsRow(width, height, context, LoginController contorller) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                value: contorller.termValue,
                checkColor: Theme.of(context).secondaryHeaderColor,
                activeColor: Theme.of(context).primaryColor,
                side: BorderSide(
                    color: Color(Utils.hexStringToHexInt(
                        ColorsCode.textfieldborderColor))),
                onChanged: (value) {
                  contorller.termValue = value!;
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
                          'I consent to ICEF using my personal data according to ICEF\'s ',
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

  _loginButton(context, width, height, LoginController contorller) {
    return Utils().createButton(
        context,
        "Login",
        width,
        ScreenUtils.isSmallScreen(context)
            ? (ScreenUtils.isSmallfont(context)
                ? height * 0.07 + 5
                : height * 0.07 + 9)
            : height * 0.07, () {
      controller.getToken();
      if (contorller.loginFormGlobalKey.currentState!.validate()) {

         controller.loginUser(
             email: contorller.emailController.value.text,
             context: context,
             password: controller.passwordController.value.text);
      }
    }).paddingOnly(
        left:
            ScreenUtils.isSmallScreen(context) ? width * 0.1 + 22 : width * 0.2,
        right: ScreenUtils.isSmallScreen(context)
            ? width * 0.1 + 22
            : width * 0.2);
  }

  _createAccountText(context, width, height) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(createRoute(const CreateAccount()));
      },
      child: Text(
        'Create Account',
        style: TextStyle(
          color: Colors.white,
          fontSize:
              ScreenUtils.isSmallScreen(context) ? width * 0.05 : width * 0.03,
          fontFamily: "Poppins Regular",
          decoration: TextDecoration.underline,
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
