import 'package:click/widgets/profileMenu.dart';
import 'package:click/pages/editProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/userModel.dart';
import 'sign_in_page.dart';


class Profile extends StatefulWidget {
  String id;
  Profile({required this.id});
  @override
  _ProfileState createState() => _ProfileState(id: id);
}

class _ProfileState extends State<Profile>  {
  String id;
  var rooll;
  var emaill;
  var name;
  var image;
  UserModel loggedInUser = UserModel();

  _ProfileState({required this.id});

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users") //.where('uid', isEqualTo: user!.uid)
        .doc(id)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
    }).whenComplete(() {
      CircularProgressIndicator();
      setState(() {
        emaill = loggedInUser.email?.toString() ?? '';
        rooll = loggedInUser.role?.toString() ?? '';
        id = loggedInUser.uid?.toString() ?? '';
        name = loggedInUser.name?.toString() ?? '';
        image = loggedInUser.imageUrl?.toString() ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 80 , 20, 0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromRGBO(172, 193, 91, 1),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(image ?? ''), // URL изображения
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(name ?? '', style: TextStyle(fontSize: 25,  fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
              Text(emaill ?? '', style: TextStyle(fontSize: 16,  fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),),
              const SizedBox(height: 20),

              /// -- BUTTON
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UpdateProfile(id: id, email: emaill, name: name, image: image),
                    ),
                  );
                },
                color: Color.fromRGBO(15, 32, 26, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                child: Center(
                  child: Text("Редактировать", style: TextStyle(color: Colors.white, fontSize: 15,  fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                ),
              ),
              const SizedBox(height: 30),
              if (rooll == 'userRole')
                ProfileMenuWidget(
                  title: "Избранное",
                  icon: Icons.favorite,
                  endIcon: false,
                  onPress: () {
                    // Ваш код здесь
                  },
                ),

              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: "Выход",
                icon: Icons.logout_outlined,
                endIcon: false,
                onPress: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Выход из системы'),
                        content: Text('Вы уверены, что хотите выйти?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              logout(context);
                              Navigator.pop(context);
                            },
                            child: Text("Да", style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1))),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Нет", style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1))),
                          ),
                        ],
                      );
                    },
                  );

                },
              ),
                ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SignIn(),
      ),
    );
  }
}

