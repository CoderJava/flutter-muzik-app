import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Muzik App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ).copyWith(
        unselectedWidgetColor: Colors.grey[500],
      ),
      home: LoginPage(),
      // home: HelloPage(),
    );
  }
}

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Hello World',
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formState = GlobalKey<FormState>();
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();

  var widthScreen = 0.0;
  var isVisiblePassword = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    widthScreen = mediaQueryData.size.width;
    return Scaffold(
      body: Stack(
        children: [
          _buildWidgetImageBackground(),
          _buildWidgetOverlayImageBackground(),
          _buildWidgetContent(),
        ],
      ),
    );
  }

  Widget _buildWidgetOverlayImageBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900]?.withOpacity(0.8),
    );
  }

  Widget _buildWidgetImageBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/img_concert.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildWidgetContent() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        width: widthScreen > 480 ? 480 : double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWidgetTitleApp(),
            SizedBox(height: 48),
            _buildWidgetFormLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetFormLogin() {
    return Form(
      key: formState,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: controllerUsername,
            decoration: InputDecoration(
              hintText: 'Username or Email',
              hintStyle: TextStyle(
                color: Colors.grey[500],
              ),
              enabledBorder: _createUnderlineInputBorder(),
              icon: Icon(
                CupertinoIcons.person,
                color: Colors.white,
              ),
            ),
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: controllerPassword,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey[500],
              ),
              enabledBorder: _createUnderlineInputBorder(),
              icon: Icon(
                CupertinoIcons.lock,
                color: Colors.white,
              ),
              suffixIcon: InkWell(
                onTap: () => setState(() => isVisiblePassword = !isVisiblePassword),
                child: Icon(
                  isVisiblePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
            ),
            style: TextStyle(
              color: Colors.white,
            ),
            obscureText: !isVisiblePassword,
            obscuringCharacter: '•',
          ),
          SizedBox(height: 16),
          _buildWidgetTextForgotPassword(),
          SizedBox(height: 24),
          _buildWidgetButtonLogin(),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Not a member? ',
                style: TextStyle(
                  color: Colors.white,
                  wordSpacing: 1,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: fitur register
                },
                child: Text(
                  'Join Now',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                    wordSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetButtonLogin() {
    var padding;
    if (kIsWeb) {
      padding = EdgeInsets.symmetric(
        horizontal: 64,
        vertical: 20,
      );
    } else {
      padding = Platform.isAndroid || Platform.isIOS
          ? EdgeInsets.symmetric(horizontal: 48)
          : EdgeInsets.fromLTRB(
              64,
              16,
              64,
              18,
            );
    }
    return ElevatedButton(
      onPressed: () {
        // Respond to button press
      },
      child: Text('LOGIN'),
      style: ElevatedButton.styleFrom(
        padding: padding,
      ),
    );
  }

  Widget _buildWidgetTextForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            // TODO: fitur forgot password
          },
          child: Text(
            'Forgot password?',
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetTitleApp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Muzik',
          style: GoogleFonts.montserrat().merge(
            Theme.of(context).textTheme.headline4?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          'App',
          style: GoogleFonts.montserrat().merge(
            Theme.of(context).textTheme.headline4?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  InputBorder _createUnderlineInputBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
      ),
    );
  }
}
