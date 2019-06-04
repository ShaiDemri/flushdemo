import 'package:flush_screen/blue_Prints/authMode.dart';
import 'package:flutter/material.dart';
import 'package:flush_screen/providers/main.dart';
import 'package:flush_screen/utils/adaptiveTheme.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthStatePage();
  }
}

class _AuthStatePage extends State<AuthPage> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  final Map<String, dynamic> _authForm = {
    'userName': null,
    'userEmail': null,
    'userPassword': null,
    'termsAccepted': false,
  };
  Widget _switchTileSubtitle = Text('');
  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = new TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  Widget _buildUserEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: 'User Email', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid Email address.';
        }
      },
      onSaved: (String value) {
        _authForm['userEmail'] = value;
      },
    );
  }

  Widget _buildUserPasswordTextField() {
    return TextFormField(
      obscureText: true,
      controller: _passwordTextController,
      decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty || value.length < 4) {
          return 'Password must be longer than 4 characters.';
        }
      },
      onSaved: (String value) {
        _authForm['userPassword'] = value;
      },
    );
  }

  Widget _buildUserPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          obscureText: true,
          decoration:
              InputDecoration(labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
          validator: (String value) {
            if (_authMode == AuthMode.Signup && value != _passwordTextController.text) {
              return 'Password do not match.';
            }
          },
        ),
      ),
    );
  }

  Widget _buildAcceptTermsSwitch() {
    return SwitchListTile(
      value: _authForm['termsAccepted'],
      title: Text("Accept Terms"),
      subtitle: _switchTileSubtitle,
      onChanged: (bool value) {
        setState(() {
          _authForm['termsAccepted'] = value;
        });
      },
    );
  }

  void _warnSwitchTileValid() {
    if (_authForm['termsAccepted'] == false) {
      setState(() {
        _switchTileSubtitle = Text(
          'You must accept the terms to continue',
          style: TextStyle(color: Colors.red),
        );
      });
    } else {
      setState(() {
        _switchTileSubtitle = Text('');
      });
    }
  }

  void _submitAuth(Function authenticate) async {
    if (!_authFormKey.currentState.validate() || _authForm['termsAccepted'] == false) {
      _warnSwitchTileValid();
      return;
    }
    _authFormKey.currentState.save();
    Map<String, dynamic> successInfo =
        await authenticate(_authForm['userEmail'], _authForm['userPassword'], _authMode);

    if (successInfo['success']) {
      print("success!!");
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occured'),
            content: Text(successInfo['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('O.K.'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    var providerInfo = Provider.of<ProviderInfo>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode.toString().split('.')[1]),
      ),
      body: Form(
        key: _authFormKey,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
              image: AssetImage("assets/images/background.png"),
            ),
          ),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: targetWidth,
                child: Column(
                  children: <Widget>[
                    _buildUserEmailTextField(),
                    SizedBox(height: 10.0),
                    _buildUserPasswordTextField(),
                    SizedBox(height: 10.0),
                    _buildUserPasswordConfirmTextField(),
                    _buildAcceptTermsSwitch(),
                    SizedBox(height: 10.0),
                    FlatButton(
                      child: Text('Switch To ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        if (_authMode == AuthMode.Login) {
                          setState(() {
                            _authMode = AuthMode.Signup;
                          });
                          _animationController.forward();
                        } else {
                          setState(() {
                            _authMode = AuthMode.Login;
                          });
                          _animationController.reverse();
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    providerInfo.getIsLoading
                        ? Center(child: AdaptiveProgressIndicator())
                        : RaisedButton(
                            textColor: Colors.white,
                            child: Text('SUBMIT'),
                            onPressed: () => _submitAuth(providerInfo.authenticate),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
