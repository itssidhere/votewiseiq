import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          FilledButton(onPressed: () {}, child: Text('Donate')),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(children: [
        Flexible(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("login_image.png"), fit: BoxFit.fill)),
          ),
        ),
        Flexible(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 160.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: Get.size.width * 0.2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Login',
                        style: Get.textTheme.headlineLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: Get.size.width * 0.2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No account?'),
                        Spacer(flex: 1),
                        TextButton(
                          onPressed: () {},
                          child: Text('Make account'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email textfield
                  Container(
                    width: Get.size.width * 0.2,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Password textfield
                  Container(
                    width: Get.size.width * 0.2,
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  Container(
                    width: Get.size.width * 0.2,
                    height: 50.0,
                    child: FilledButton(
                      onPressed: () {
                        var email = emailController.text.trim();
                        var password = passwordController.text.trim();

                        FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);
                      },
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
