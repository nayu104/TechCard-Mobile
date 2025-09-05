//サインイン画面
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget{
  const SignInPage({super.key});
  static const route = '/sign-in';

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(child: Text('Sign In')),
    );
  }
}