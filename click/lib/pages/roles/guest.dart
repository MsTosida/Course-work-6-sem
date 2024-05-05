import 'package:click/pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../allPosts.dart';


class GuestPage extends StatefulWidget {

  @override
  _GuestPageState createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  int selectedIndex = 0;
  @override
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('posts').snapshots();

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if(selectedIndex>0){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SignIn(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      AllPostPage(),
      SizedBox.shrink(),
      SizedBox.shrink(),
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
