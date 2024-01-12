import 'package:flutter/material.dart';

import '../utils/Utils.dart';
import '../utils/color_code.dart';

class TextFieldWidget extends StatefulWidget {
  String _hint;
  final validate;
  String _label;
  String _error;
  TextInputType _textInputType;

  bool _isPassword,
      _isEmail,
      _isPhone,
      _isPass,
      _isDisable,
      _issufi,
      _isaccount;
  bool _readonly;
  int limit;
  TextEditingController _controller = TextEditingController();

  TextFieldWidget(String hint, String label, String error,
      {Key? key,
      bool isPassword = false,
      bool isEmail = false,
      bool isPhone = false,
      bool isPass = false,
      bool readonly = false,
      bool isDisable = true,
      TextInputType textInputType = TextInputType.text,
      required TextEditingController controller,
      validate,
      bool issufix = false,
      int limit = 50,
      bool isaccount = false})
      : _hint = hint,
        _label = label,
        _error = error,
        validate = validate,
        _textInputType = textInputType,
        _isPassword = isPassword,
        _isEmail = isEmail,
        _isPhone = isPhone,
        _isPass = isPass,
        _readonly = readonly,
        _isDisable = isDisable,
        _controller = controller,
        _issufi = issufix,
        _isaccount = isaccount,
        limit = limit,
        super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: width * 0.09),
            child: Text(
              widget._hint,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins Regular',
              ),
            ),
          ),
          SizedBox(height: height*0.01,),
          Padding(
            padding: EdgeInsets.only(left: width * 0.08, right: width * 0.05),
            child: Center(
              child: TextFormField(
                validator: widget.validate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: const TextStyle(color: Colors.black),
                cursorColor: Theme.of(context).primaryColor,
                controller: widget._controller,
                autofocus: false,
                showCursor: true,
                enabled:  widget._isDisable,
                maxLength: widget.limit,
                readOnly: widget._readonly,
                textAlign: TextAlign.start,
                obscureText: widget._isPass == true ? _obscureText : false,
                obscuringCharacter: '*',
                keyboardType: widget._textInputType,
                decoration: InputDecoration(
                  filled: true,
                  counterText: "",
                  disabledBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    borderSide: const BorderSide(width: 2.0, color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    borderSide:
                        const BorderSide(width: 2.0, color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    borderSide:
                        const BorderSide(width: 2.0, color: Colors.white),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    borderSide: const BorderSide(width: 2.0, color: Colors.red),
                  ),
                  hoverColor: Colors.indigo.shade100,
                  hintStyle: const TextStyle(fontSize: 12),
                  helperStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
