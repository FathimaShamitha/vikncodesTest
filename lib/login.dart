import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'homepage.dart';

class LoginClass extends StatelessWidget {
  final String loginUrl =
      'https://api.accounts.vikncodes.com/api/v1/users/login';
  final RxBool isLoading = true.obs;

  LoginClass({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          child: Column(
            children: [
              SizedBox(
                height: 200,
              ),
              Text(
                "Login",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                "Login ot your vikin account",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: height * 0.2,
                width: width * 0.8,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4)),
                          hintText: "Username",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue,
                          )),
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                        hintText: "Password",
                        prefixIcon: Icon(
                          Icons.key_sharp,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Forgotten Password?",
                style: TextStyle(color: Colors.blue),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    _login();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeClass()));
                  },
                  child: Text(
                    "Sign in ->",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  )),
              SizedBox(
                height: 80,
              ),
              Text("Don't have an Account?"),
              Text(
                "Sign up now!",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> loginData = {
        'username': 'Rabeeh@vk',
        'password': 'Rabeeh@000',
        'is_mobile': true,
      };

      final response = await http
          .post(Uri.parse(loginUrl), body: json.encode(loginData), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final accessToken = responseData['access'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access', accessToken);

        Get.snackbar('Success', 'Login successful. Access Token: $accessToken');
      } else {
        Get.snackbar(
            'Error', 'Login failed. Status Code: ${response.statusCode}');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
