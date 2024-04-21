import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/api/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/ai-home.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width * 0.4,
              constraints: const BoxConstraints(
                maxWidth: 1000,
                minWidth: 600,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to IntelliCam!',
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Real-Time WebCam AI-Security',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Our AI-powered security system provides real-time risk analysis and rapid threat response.",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Join us today to experience the future of webcam security!',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontStyle: FontStyle.italic,  
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        
                        AuthApi.isLoggedIn()
                        ? FilledButton(
                            onPressed: () {
                              context.push(NavigationHelper.surveillancePath);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                'Surveillance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () {
                                context.push(NavigationHelper.loginPath);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            OutlinedButton(
                              onPressed: () {
                                context.push(NavigationHelper.registrationPath);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}