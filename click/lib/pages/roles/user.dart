import 'package:click/pages/allPosts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../addPost.dart';
import '../profile.dart';


class UserPage extends StatefulWidget {
  final String id;  
  final int selectedIndex;
  UserPage({required this.id,required this.selectedIndex});

  @override
  _UserPageState createState() => _UserPageState(id: id, selectedIndex: selectedIndex);
}

class _UserPageState extends State<UserPage> {
  String id;
  int selectedIndex;
  _UserPageState({required this.id, required this.selectedIndex});

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      AllPostPage(),
      AddPostPage(id: widget.id),
      Profile(id: widget.id),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        showSelectedLabels: false,
          enableFeedback: false,
        elevation: 0,
        backgroundColor:  Color.fromRGBO(15, 32, 26, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: 'addPost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'users',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color.fromRGBO(67, 108, 35, .9),
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
