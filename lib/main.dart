import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// https://github.com/FilledStacks/responsive_builder/blob/master/lib/src/sizing_information.dart#L85
final _mobileExtraLarge = 480.0;

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
            builder: (context) => user != null && user.emailVerified ? HomePage() : LoginPage(),
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
        width: widthScreen > _mobileExtraLarge ? _mobileExtraLarge : double.infinity,
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
            Text(
              'Sign In',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controllerUsername,
              decoration: InputDecoration(
                hintText: 'Username or Email',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                enabledBorder: _createUnderlineInputBorder(),
                icon: Icon(
                  CupertinoIcons.mail,
                  color: Colors.white,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
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
        final userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() => isLoading = false);
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (_) => false,
          );
        } else {
          _showSnackBar(context, 'Please verify your email', widthScreen);
        }
      } on FirebaseAuthException catch (error) {
        final errorCode = error.code;
        var errorMessage = '';
        if (errorCode == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (errorCode == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = '$error';
        }
        _showSnackBar(context, errorMessage, widthScreen);
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordPage(),
              ),
            );
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
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formState = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final firebaseAuth = FirebaseAuth.instance;
  final focusNodeLabelSignUp = FocusNode();

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: widthScreen > _mobileExtraLarge ? _mobileExtraLarge : double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWidgetTitleApp(context),
              SizedBox(height: 48),
              _buildWidgetFormRegister(),
            ],
          )),
    );
  }

  Widget _buildWidgetFormRegister() {
    return IgnorePointer(
      ignoring: isLoading,
      child: Form(
        key: formState,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controllerEmail,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                enabledBorder: _createUnderlineInputBorder(),
                icon: Icon(
                  CupertinoIcons.mail,
                  color: Colors.white,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
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
                _doRegisterByEmailAndPassword();
              },
            ),
            SizedBox(height: 24),
            _buildWidgetButtonSignUp(),
            SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to signin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButtonSignUp() {
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
    final padding = _setPaddingButton();
    return ElevatedButton(
      onPressed: () {
        _doRegisterByEmailAndPassword();
      },
      child: widgetLoading ?? Text('SIGN UP'),
      style: ElevatedButton.styleFrom(
        padding: padding,
      ),
    );
  }

  void _doRegisterByEmailAndPassword() async {
    if (formState.currentState!.validate()) {
      focusNodeLabelSignUp.requestFocus();
      try {
        setState(() => isLoading = true);
        final email = controllerEmail.text.trim();
        final password = controllerPassword.text.trim();
        final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        userCredential.user!.sendEmailVerification();
        setState(() => isLoading = false);
        _showSnackBar(
          context,
          'We have sent a link verification to your email.',
          widthScreen,
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (error) {
        final errorCode = error.code;
        var errorMessage = '';
        if (errorCode == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (errorCode == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = '$error';
        }
        _showSnackBar(context, errorMessage, widthScreen);
        setState(() => isLoading = false);
      }
    }
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

void _showSnackBar(BuildContext context, String message, double widthScreen) {
  if (widthScreen > _mobileExtraLarge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        behavior: SnackBarBehavior.floating,
        width: _mobileExtraLarge,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }
}

InputBorder _createUnderlineInputBorder() {
  return UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
    ),
  );
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formState = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final firebaseAuth = FirebaseAuth.instance;
  final focusNodeLabelForgotPassword = FocusNode();
  final focusNodeLabelResetPasswordCode = FocusNode();

  var widthScreen = 0.0;
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
        width: widthScreen > _mobileExtraLarge ? _mobileExtraLarge : double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWidgetTitleApp(context),
            SizedBox(height: 48),
            _buildWidgetForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetForm() {
    return IgnorePointer(
      ignoring: isLoading,
      child: _buildWidgetFormResetPassword(),
    );
  }

  Widget _buildWidgetFormResetPassword() {
    return Form(
      key: formState,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Focus(
            focusNode: focusNodeLabelForgotPassword,
            child: Text(
              'Forgot Password',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: controllerEmail,
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                color: Colors.grey[500],
              ),
              enabledBorder: _createUnderlineInputBorder(),
              icon: Icon(
                CupertinoIcons.mail,
                color: Colors.white,
              ),
            ),
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _doResetPasswordByEmail();
            },
          ),
          SizedBox(height: 24),
          _buildWidgetButtonResetPassword(),
          SizedBox(height: 24),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back to signin'),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetButtonResetPassword() {
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
    final padding = _setPaddingButton();
    return ElevatedButton(
      onPressed: () {
        _doResetPasswordByEmail();
      },
      child: widgetLoading ?? Text('RESET PASSWORD'),
      style: ElevatedButton.styleFrom(
        padding: padding,
      ),
    );
  }

  void _doResetPasswordByEmail() async {
    if (formState.currentState!.validate()) {
      focusNodeLabelForgotPassword.requestFocus();
      setState(() => isLoading = true);
      final email = controllerEmail.text.trim();
      await firebaseAuth.sendPasswordResetEmail(email: email);
      setState(() => isLoading = false);
      _showSnackBar(
        context,
        'We have sent a link reset password to your email',
        widthScreen,
      );
      Navigator.pop(context);
    }
  }
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter an email address';
  } else {
    final isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
    return isEmailValid ? null : 'Invalid email';
  }
}
