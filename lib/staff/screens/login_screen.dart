import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? email;
  String? password;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.userChanges().listen((User? user) {
    //   if (user == null) {
    //     logger.e('User is currently signed out!');
    //   } else {
    //     logger.i('User is signed in!');
    //   }
    // });

    void onLoginHandler() async {
      try {
        setState(() {
          isLoading = true;
        });
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: "+91$email@gmail.com", password: password!);
        logger.i(credential.user!.uid);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
                message: "No user found for that number."),
          );
        } else if (e.code == 'wrong-password') {
          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
                message: "No user found for that number."),
          );
        }
        logger.e("error logging in: ${e.message}");
        if (!context.mounted) return;

        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
              message:
                  "You are not allowed to login. Please contact the Admin"),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(10),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Your credentials will be provided by the admin of this application. If you don't have any credentials, please contact the Admin",
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    prefixText: "+91",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    } else if (value.length != 10) {
                      return 'Please enter valid mobile number';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    email = newValue;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: isObscure
                        ? IconButton(
                            onPressed: () {
                              isObscure = !isObscure;
                              setState(() {});
                            },
                            icon: const Icon(Icons.visibility_off),
                          )
                        : IconButton(
                            onPressed: () {
                              isObscure = !isObscure;
                              setState(() {});
                            },
                            icon: const Icon(Icons.visibility),
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    password = newValue;
                  },
                ),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          onLoginHandler();
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );

    // return SignInScreen(
    //   subtitleBuilder: (context, action) {
    //     return const Text(
    //         "Your credentials will be provided by the admin of this application. If you don't have any credentials, please contact the Admin");
    //   },
    //   showAuthActionSwitch: false,
    //   auth: FirebaseAuth.instance,
    //   providers: [
    //     ui_auth.EmailAuthProvider(),
    //   ],
    //   headerBuilder: (context, constraints, shrinkOffset) {
    //     return Container(
    //       margin: const EdgeInsets.all(8),
    //       decoration: BoxDecoration(
    //         color: Colors.black,
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       child: Image.asset(
    //         "assets/logo.png",
    //         fit: BoxFit.contain,
    //       ),
    //     );
    //   },
    // );
  }
}
