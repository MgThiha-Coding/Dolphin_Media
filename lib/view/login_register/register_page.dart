import 'package:dolphin/core/image/app_Image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function() onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController confirmPasswordController =
      TextEditingController();

  GlobalKey key = GlobalKey<FormState>();
  bool obscure = true;
  bool confirmobscure = true;

  void signUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // safely close dialog
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        displayMessage(e.message ?? "Registration failed");
      }
    }
  }

  void displayMessage(String message, {String title = "Notice"}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImage.logo, scale: 8),
            Text(
              'Dolphin',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: key,
              child: Column(
                children: [
                  TextFormField(
                    maxLines: 1,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      prefixIconColor: Colors.grey[600],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.blue),
                      ),

                      hintText: "Email",
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email.";
                      } else if (!EmailValidator.validate(value)) {
                        return "Please enter a valid email address.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: obscure,
                    maxLines: 1,
                    controller: passwordController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Colors.grey[600],
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        icon:
                            obscure
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: "Password",
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password!";
                      } else if (value.length != 6) {
                        return "Password must be exactly 5 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    maxLines: 1,
                    obscureText: confirmobscure,
                    controller: confirmPasswordController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Colors.grey[600],
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            confirmobscure = !confirmobscure;
                          });
                        },
                        icon:
                            confirmobscure
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: "Confirm Password",
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        signUp();
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "If you have an account?",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Log In',
                          style: TextStyle(color: Colors.blue),
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
    );
  }
}
