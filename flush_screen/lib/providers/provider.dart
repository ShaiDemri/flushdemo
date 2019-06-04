import 'dart:async';
import 'dart:convert';

import 'package:flush_screen/blue_Prints/authMode.dart';
import 'package:flush_screen/blue_Prints/user.dart';
import 'package:flutter/foundation.dart';

import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// CLASS CombinedProdsUserModel /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class CombinedProdsUserModel with ChangeNotifier {
  ////////////////////////////////////////////////
  //////////////////// MEMBERS ///////////////////
  ////////////////////////////////////////////////

  User _authenticatedUser;
  bool _isLoading = false;

  ////////////////////////////////////////////////
  //////////////////// GET/SET ///////////////////
  ////////////////////////////////////////////////

  ////////////////////////////////////////////////
  //////////////////// METHODS ///////////////////
  ////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// CLASS UserModel ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
mixin UserModel on CombinedProdsUserModel {
  ////////////////////////////////////////////////
  //////////////////// MEMBERS ///////////////////
  ////////////////////////////////////////////////
  //Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();
  bool _isAuthenticated = false;

  ////////////////////////////////////////////////
  //////////////////// GET/SET ///////////////////
  ////////////////////////////////////////////////
  User get getUser {
    return _authenticatedUser;
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  PublishSubject<bool> get getUserSubject {
    return _userSubject;
  }

  void setIsAuthenticated(bool isAuth) {
    _isAuthenticated = isAuth;
    notifyListeners();
  }

  ////////////////////////////////////////////////
  //////////////////// METHODS ///////////////////
  ////////////////////////////////////////////////
  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final token = 'token';
    final Map<String, dynamic> loginData = {
      'username': email,
      'password': password,
    };
    final Map<String, dynamic> authData = {
      'intent': 'email',
      'identity_data': {
        'username': email,
        'password': password,
      },
    };
    final Map<String, String> authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'url',
        body: json.encode(loginData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'url',
        headers: authHeaders,
        body: json.encode(authData),
      );
    }
    print(response.body);

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    bool hasError = true;
    String responeMessage = 'Something went wrong. Try again later.';

    if (response.statusCode ~/ 100 == 2) {
      hasError = false;
      responeMessage = 'Auth succeeded';
      _authenticatedUser = User(
        id: responseData['id'],
        email: email,
        jwtToken: responseData['token'],
      );
      _userSubject.add(true);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['token']);
      prefs.setString('email', email);
      prefs.setString('id', responseData['id']);
    } else {
      debugPrint(response.body);
      responeMessage = 'Wrong credentials provided.';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': responeMessage};
  }

  void resume() async {
    _isLoading = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final Map<String, String> resumeHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final Map<String, String> resumeBody = {};
    if (token != null) {
      final http.Response response = await http.post(
        'url',
        headers: resumeHeaders,
        body: json.encode(resumeBody),
      );
      if (response.statusCode ~/ 100 != 2) {
        print('resume faild. ${response.statusCode} ${response.body}');
        _userSubject.add(false);
        _isLoading = false;
        notifyListeners();
        return;
      }
      _isLoading = false;
      _userSubject.add(true);
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final toDeleteToken = prefs.get('token');
    http.Response response = await http.delete(
      'url',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $toDeleteToken',
      },
    );
    if (response.statusCode ~/ 100 != 2) {
      //accepts all status codes other then the 2XX ones...
      print("Delete we have a problem!");
      print(response.body);
    }

    _authenticatedUser = null;
    _userSubject.add(false);
    prefs.remove('token');
    prefs.remove('email');
    prefs.remove('id');
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// CLASS UtilityModel /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
mixin UtilityModel on CombinedProdsUserModel {
////////////////////////////////////////////////
//////////////////// MEMBERS ///////////////////
////////////////////////////////////////////////

////////////////////////////////////////////////
//////////////////// GET/SET ///////////////////
////////////////////////////////////////////////

  ////////////////////////////////////////////////
  //////////////////// METHODS ///////////////////
  ////////////////////////////////////////////////
  bool get getIsLoading {
    return _isLoading;
  }
}
