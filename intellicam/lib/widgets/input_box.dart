import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputBox extends StatefulWidget {
  final String label;
  
  
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';

  TextEditingController controller;

  final bool validate;

  InputBox({super.key, 
    required this.label,
    required this.controller,
    this.validate = true,
  }) : assert(label == password || label == email || label == confirmPassword);

  @override
  InputBoxState createState() => InputBoxState();
}

class InputBoxState extends State<InputBox> {
  bool passwordVisibility = false;

  static final Map<String, String> autoFillHints = {
    'email': AutofillHints.email,
    'password': AutofillHints.password,
    'confirmPassword': AutofillHints.newPassword,
  };

  static final Map<String, TextInputType> inputType = {
    'email': TextInputType.emailAddress,
    'password': TextInputType.visiblePassword,
    'confirmPassword': TextInputType.visiblePassword,
  };

  static final Map<String, String> errorText = {
    'email': 'Please enter a valid email address',
    'password_init': "The password must contain:",
    'password_length' : "- at least 8 characters and at most 16 characters",
    'password_number' : "- at least one number",
    'password_uppercase' : "- at least one uppercase letter",
    'password_lowercase' : "- at least one lowercase letter",
    'password_special' : "- at least one special character",
    'confirmPassword': 'Please confirm your password',
  };

  static final Map<String, String> labelText = {
    'email': 'Email*',
    'password': 'Password*',
    'confirmPassword': 'Confirm Password*',
  };

  static final Map<String, String? Function(String?)> validator = {
    'email': (value) {
      if (value == null || value.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
        return errorText['email'];
      }
      return null;
    },
    'password': (value) {
      String errorMsg = errorText['password_init']!;
      if (value == null || value.isEmpty || value.length < 8 || value.length > 16) {
        errorMsg += '\n${errorText['password_length']!}';
      }
      if (value == null || !value.contains(RegExp(r'[0-9]'))) {
        errorMsg += '\n${errorText['password_number']!}';
      }
      if (value == null || !value.contains(RegExp(r'[a-z]'))) {
        errorMsg += '\n${errorText['password_lowercase']!}';
      }
      if (value == null || !value.contains(RegExp(r'[A-Z]'))) {
        errorMsg += '\n${errorText['password_uppercase']!}';
      }
      if (value == null || !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        errorMsg += '\n${errorText['password_special']!}';
      }
      if (errorMsg != errorText['password_init']!) {
        return errorMsg;
      }
      return null;
    },
    'confirmPassword': (value) {
      if (value == null || value.isEmpty) {
        return errorText['confirmPassword'];
      }
      return null;
    },

  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: TextFormField(
              controller: widget.controller,
              autofocus: true,
              autofillHints: [autoFillHints[widget.label]!],
              obscureText: widget.label == InputBox.password ? !passwordVisibility : false,
              decoration: InputDecoration(
                labelText: labelText[widget.label],
                labelStyle: Theme.of(context).textTheme.bodySmall,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                suffixIcon: widget.label == InputBox.password || widget.label == InputBox.confirmPassword
                ? InkWell(
                    onTap: () => setState(
                      () => passwordVisibility = !passwordVisibility,
                    ),
                    child: Icon(
                      passwordVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context).primaryColorDark,
                      size: 24,
                    ),
                  )
                : null,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: inputType[widget.label],
              validator: widget.validate
                ? validator[widget.label]
                : null,
            ),
      ),
    );
  }
}
