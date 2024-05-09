import 'package:flutter/material.dart';

import '../addPost.dart';
import '../allPosts.dart';
import '../favorites.dart';
import '../profile.dart';
import '../search.dart';

class UserPage extends StatefulWidget {
  final int selectedIndex;
  UserPage({required this.selectedIndex});

  @override
  _UserPageState createState() => _UserPageState(selectedIndex: selectedIndex);
}

class _UserPageState extends State<UserPage> {
  int selectedIndex;
  _UserPageState({required this.selectedIndex});

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      AllPostPage(),
      SearchPage(),
      AddPostPage(),
      FavoritesPage(),
      Profile(),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          enableFeedback: false,
          elevation: 0,
          currentIndex: selectedIndex,
          selectedItemColor: Color.fromRGBO(67, 108, 35,.9),
          unselectedItemColor: Colors.white,
          backgroundColor: Color.fromRGBO(22, 31, 10, 1),
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: 'addPost',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'users',
            ),
          ],

        ),
      ),
    );
  }
}
