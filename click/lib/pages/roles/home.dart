import 'package:click/pages/roles/user.dart';
import 'package:click/pages/sign_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/userModel.dart';
import 'admin.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();
  @override
  Widget build(BuildContext context) {
    return contro();
  }
}

class contro extends StatefulWidget {
  contro();

  @override
  _controState createState() => _controState();
}

class _controState extends State<contro> {
  _controState();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  var rooll;
  var emaill;
  var name;
  var id;
  @override
  void initState() {
    super.initState();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUp(),
          ),
        );
      });
    } else {
    FirebaseFirestore.instance
        .collection("users") //.where('uid', isEqualTo: user!.uid)
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
    }).whenComplete(() {
      setState(() {
        emaill = loggedInUser.email.toString();
        rooll = loggedInUser.role.toString();
        id = loggedInUser.uid.toString();
        name = loggedInUser.name.toString();
      });
    });
  }
}
  routing() {
    if (rooll != null && rooll == 'userRole') {
      return UserPage(
        id: id,
        selectedIndex: 0,
      );
    } else if (rooll != null && rooll == 'adminRole') {
      return AdminPage(
        id: id,
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return

      routing();
  }
}