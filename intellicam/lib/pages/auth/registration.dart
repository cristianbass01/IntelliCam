import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/api/auth.dart';

import 'package:ai_shield_app/widgets/input_box.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool acceptPolicies = false;

  bool passwordVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? AppBar(
              title: const Text('Registration'),
            )
          : null,
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: 100,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBFE8FF), Color(0xFF104DFF)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0.87, -1),
                    end: AlignmentDirectional(-0.87, 1),
                  ),
                ),
                alignment: const AlignmentDirectional(0, -1),
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                maxWidth: 1000,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).cardColor,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x33000000),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Align(
                                alignment: const AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headlineMedium,
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 12, 0, 24),
                                        child: Text(
                                          'Insert your data to create your account',
                                          textAlign: TextAlign.center,
                                          style:
                                              Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      InputBox(
                                        label: InputBox.email, 
                                        controller: emailController
                                      ),
                                      InputBox(
                                        label: InputBox.password, 
                                        controller: passwordController
                                      ),
                                      InputBox(
                                        label: InputBox.confirmPassword, 
                                        controller: confirmPasswordController
                                      ),
                                      
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: acceptPolicies,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                acceptPolicies = value!;
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              'I agree to the Terms of Service and Privacy Policy.',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(50, 20, 50, 10),
                                        child: FilledButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              bool success = await AuthApi.register(context, emailController, passwordController, confirmPasswordController, acceptPolicies);
                                              if (mounted && success) {
                                                context.go(NavigationHelper.surveillancePath);
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            constraints: const BoxConstraints(
                                              maxWidth: 400,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                                              child: Text('Sign Up'),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // You will have to add an action on this rich text to go to your login page.
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Already have an account? ',
                                              style: TextStyle(),
                                            ),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.pop();
                                                  context.push(
                                                    NavigationHelper.loginPath
                                                  );
                                                },
                                                child: Text(
                                                  'Sign In here!',
                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    color: Theme.of(context).primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: Theme.of(context).primaryColor,
                                                  ),
                                                ),

                                              ),
                                            )
                                          ],
                                          style:
                                              Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

}