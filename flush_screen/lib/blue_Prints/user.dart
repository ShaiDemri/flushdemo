import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String jwtToken;

  User({@required this.id, @required this.email, @required this.jwtToken});
}
