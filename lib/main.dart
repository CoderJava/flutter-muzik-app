import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (mounted) {
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => user == null ? LoginPage() : HomePage(),
          ),
          (_) => false,
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[900],
        alignment: Alignment.center,
        child: _buildWidgetTitleApp(context),
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
  final firebaseAuth = FirebaseAuth.instance;
  final focusNodeForgotPassword = FocusNode();

  var widthScreen = 0.0;
  var isVisiblePassword = false;
  var isLoading = false;

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

  Widget _buildWidgetContent() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        width: widthScreen > 480 ? 480 : double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWidgetTitleApp(context),
            SizedBox(height: 48),
            _buildWidgetFormLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetFormLogin() {
    return IgnorePointer(
      ignoring: isLoading,
      child: Form(
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
              validator: (value) {
                return value == null || value.isEmpty ? 'Enter an email address' : null;
              },
              textInputAction: TextInputAction.next,
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
              validator: (value) {
                return value == null || value.isEmpty ? 'Enter a password' : null;
              },
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (value) {
                _doLoginByEmailAndPassword();
              },
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
                    // TODO: buat fitur register
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
      ),
    );
  }

  Widget _buildWidgetButtonLogin() {
    Widget? widgetLoading;
    if (isLoading) {
      if (kIsWeb) {
        widgetLoading = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
            strokeWidth: 2,
          ),
        );
      } else {
        widgetLoading = Platform.isIOS || Platform.isMacOS
            ? CupertinoActivityIndicator()
            : SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                  strokeWidth: 2,
                ),
              );
      }
    }
    var padding = _setPaddingButton();
    return ElevatedButton(
      onPressed: () {
        _doLoginByEmailAndPassword();
      },
      child: widgetLoading ?? Text('LOGIN'),
      style: ElevatedButton.styleFrom(
        padding: padding,
      ),
    );
  }

  void _doLoginByEmailAndPassword() async {
    if (formState.currentState!.validate()) {
      focusNodeForgotPassword.requestFocus();
      try {
        setState(() => isLoading = true);
        final email = controllerUsername.text.trim();
        final password = controllerPassword.text.trim();
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() => isLoading = false);
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (_) => false,
        );
      } on FirebaseAuthException catch (error) {
        // TODO: buat UI pesan error gagal login
        final errorCode = error.code;
        if (errorCode == 'user-not-found') {
          debugPrint('No user found for that email.');
        } else if (errorCode == 'wrong-password') {
          debugPrint('Wrong password provided for that user.');
        } else {
          debugPrint('error: ${error.toString()}');
        }
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildWidgetTextForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            // TODO: fitur forgot password
          },
          child: Focus(
            focusNode: focusNodeForgotPassword,
            child: Text(
              'Forgot password?',
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildWidgetImageBackground(),
          _buildWidgetOverlayImageBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWidgetTitleApp(context),
                SizedBox(height: 48),
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Colors.white,
                      ),
                ),
                SizedBox(height: 16),
                _buildWidgetButtonLogout(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetButtonLogout(BuildContext context) {
    var padding = _setPaddingButton();
    return ElevatedButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (_) => false,
        );
      },
      child: Text('LOGOUT'),
      style: ElevatedButton.styleFrom(
        padding: padding,
      ),
    );
  }
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

Widget _buildWidgetTitleApp(BuildContext context) {
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

EdgeInsets _setPaddingButton() {
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
  return padding;
}
