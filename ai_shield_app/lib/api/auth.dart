import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthApi {
  static Future<bool> signInWithEmail(context,
                            emailController, 
                            passwordController) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error: ${e.code}'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An unknown error occurred while logging in: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }

  static Future<bool> signInWithGoogle(context) async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error: ${e.code}'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An unknown error occurred while logging in: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }

  static bool isLoggedIn() {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> logout(context) async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An unknown error occurred while logging out.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  static Future<bool> register(context,
                                emailController, 
                                passwordController,
                                confirmPasswordController,
                                acceptPolicies) async {
    try {
      if (!acceptPolicies) {
        throw FirebaseAuthException(
          code: 'accept-policies',
          message: 'You must accept the Terms of Service and Privacy Policy to register.',
        );
      }
      if (passwordController.text != confirmPasswordController.text) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'Password and Confirm Password do not match',
        );
      }
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error: ${e.code}'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An unknown error occurred while signing up: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }
  
  static Future<bool> resetPassword(context, emailController) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Email sent'),
            content: const Text('An email has been sent to reset your password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return true;
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error: ${e.code}'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An unknown error occurred while sending the email: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }

  static Future<bool> deleteAccount(context, passwordController) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error: ${e.code}'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An unknown error occurred while deleting the account: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }
}