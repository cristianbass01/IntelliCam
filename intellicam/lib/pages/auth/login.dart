import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/api/auth.dart';

import 'package:ai_shield_app/widgets/input_box.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? AppBar(
              title: const Text('Login'),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).primaryColor],
                    stops: const [0, 1],
                    begin: const AlignmentDirectional(0.87, -1),
                    end: const AlignmentDirectional(-0.87, 1),
                  ),
                ),
                alignment: const AlignmentDirectional(0, -1),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: width * 0.8,
                            constraints: const BoxConstraints(
                              maxWidth: 800,
                              minWidth: 400,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
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
                                padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login to your AI Shield profile',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                                      child: Text(
                                        'Please enter your email and password',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          InputBox(
                                            label: InputBox.email, 
                                            controller: emailController
                                          ),
                                          InputBox(
                                            label: InputBox.password, 
                                            controller: passwordController
                                          ),
                                          
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Forgot your password?  ',
                                                    style: TextStyle(),
                                                  ),
                                                  WidgetSpan(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        context.push(
                                                          NavigationHelper.forgetPasswordPath,
                                                        );
                                                      },
                                                      child: Text(
                                                        'Reset here!',
                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.w600,
                                                          decoration: TextDecoration.underline,
                                                          decorationColor: Theme.of(context).primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(50, 0, 50, 10),
                                            child: FilledButton(
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  bool success = await AuthApi.signInWithEmail(context, emailController, passwordController);
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
                                                  child: Text('Login'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ),

                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Don\'t have an account?  ',
                                            style: TextStyle(),
                                          ),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                context.pop();
                                                context.push(
                                                  NavigationHelper.registrationPath,
                                                );
                                              },
                                              child: Text(
                                                'Register here',
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        style: Theme.of(context).textTheme.bodySmall,
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
          ],
        ),
      );
  }
}