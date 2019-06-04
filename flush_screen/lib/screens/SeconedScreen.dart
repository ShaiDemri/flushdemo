import 'package:flutter/material.dart';
import 'package:flush_screen/providers/main.dart';
import 'package:provider/provider.dart';

class SeconedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderInfo>(context);
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('choose'),
            ),
            ListTile(
              title: Text("Home Screen"),
              leading: Icon(Icons.edit),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            Divider(),
            ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  provider.logout();
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Second Screen'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(child: Center(child: Text("Seconed Screen"))),
    );
  }
}
