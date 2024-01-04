import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:country_code_picker/country_code_picker.dart';

class UserInputWidget extends StatefulWidget {
  @override
  _UserInputWidgetState createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  bool isPhone = true;
  String userInput = '';
  String selectedCountryCode = 'US'; // Set your default country code here

  TextEditingController userInputController = TextEditingController();

  void validateInput() async {
    if (isPhone) {
      try {
        //bool isValid = await FlutterLibphonenumber.parse(userInput, region: selectedCountryCode);
        print('Is valid phone number:');
      } catch (e) {
        print('Error: $e');
      }
    } else {
      bool isValid = EmailValidator.validate(userInput);
      print('Is valid email: $isValid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(

      child: SafeArea(
        child: Column(
          children: [
            TextFormField(
              controller: userInputController,
              onChanged: (value) {
                setState(() {
                  userInput = value;
                  isPhone = !userInput.contains('@');
                });
              },
              decoration: InputDecoration(
                hintText: 'Email or Phone',
              ),
            ),
            SizedBox(height: 10),
            if (isPhone)
              CountryCodePicker(
                initialSelection: selectedCountryCode,
                onChanged: (value) {
                  setState(() {
                    selectedCountryCode = value.code!;
                  });
                },
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateInput,
              child: Text('Validate'),
            ),
          ],
        ),
      ),
    );
  }
}