import 'dart:io' show Platform;
import 'package:ai_shield_app/api/auth.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_shield_app/widgets/input_box.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});
  
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController emailController = TextEditingController();

  bool passwordVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? AppBar(
              title: const Text('Forget Password'),
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
                                        'Reset Password',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                                        child: Text(
                                          'Enter your email address. We will send you an email to reset your password.',
                                          textAlign: TextAlign.center,
                                          style:
                                              Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),

                                      InputBox(label: InputBox.email, controller: emailController),
                                      
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(50, 10, 50, 10),
                                        child: FilledButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()){
                                              bool success = await AuthApi.resetPassword(context, emailController);
                                              if(mounted && success) {
                                                // ignore: use_build_context_synchronously
                                                context.pop();
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
                                              child: Text('Send Email'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                            )
                                          ],
                                          style:
                                              Theme.of(context).textTheme.bodyMedium,
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