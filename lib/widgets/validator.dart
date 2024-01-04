/*========================Email Validator==============================================*/

import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

import '../utils/app_strings.dart';

class EmailValidator {
  static String? validateEmail(String value, {FocusNode? focusNode}) {
    if (value.isEmpty) {
      if (focusNode != null) {
        focusNode.unfocus();
        focusNode.requestFocus();
      }
      return strEmailEmpty;
    } else if (!GetUtils.isEmail(value.trim())) {
      if (focusNode != null) {
        focusNode.unfocus();
        focusNode.requestFocus();
      }
      return strInvalidEmail;
    }
    return null;
  }

  static String? validateEmptyEmail(String value) {
    if (!GetUtils.isEmail(value.trim()) && value.isNotEmpty) {
      return strInvalidEmail;
    }
    return null;
  }
}

/*================================================== Password Validator ===================================================*/

class PasswordFormValidator {
  static String? validatePassword(String value) {
    var pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return strPasswordEmpty;
    } else if (value.length < 8) {
      return strInvalidPassword;
    } else if (!regExp.hasMatch(value)) {
      return strPasswordNotSecure;
    }
    return null;
  }

  static String? validateConfirmPasswordMatch(String? value, String? password) {
    if (value!.isEmpty) {
      return strCPasswordEmpty;
    } else if (value.length < 8) {
      return strInvalidPassword;
    } else if (value != password) {
      return strPasswordMatch;
    }
    return null;
  }
}
