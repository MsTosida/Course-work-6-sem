import 'package:click/pages/allPosts.dart';
import 'package:click/pages/profile.dart';
import 'package:flutter/material.dart';

import '../adminPanel.dart';

class AdminPage extends StatefulWidget {
  final String id;
  AdminPage({required this.id});
  @override
  _AdminPageState createState() => _AdminPageState(id: id);
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  String id;
  _AdminPageState({required this.id});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      AllPostPage(),
      AdminPanel(),
      Profile(id: widget.id),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        showSelectedLabels: false,
        backgroundColor: Color.fromRGBO(15, 32, 26, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'adminPanel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(67, 108, 35, .9),
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
