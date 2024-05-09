import 'dart:typed_data';
import 'package:click/pages/roles/guest.dart';
import 'package:click/pages/sign_in_page.dart';
import 'package:click/widgets/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/userModel.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'roles/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPage extends StatefulWidget {
  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formkeyyy = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar:AppBar(leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new),
        onPressed: () {
        Navigator.pop(context);
        },)),
        body:  Stack(
            children: [
              SingleChildScrollView(
                child:  Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 80, 40, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Center(
                              child:
                              SvgPicture.asset(
                                  'assets/images/logo.svg',
                                width: 30,
                                height: 30,
                              )
                            ),
                          ),
                          SizedBox(height: 50,),
                          FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Center(
                              child: Text(
                                "Восстановить пароль",
                                style: TextStyle(
                                  color: Color.fromRGBO(22, 31, 10, 1),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          FadeInUp(duration: Duration(milliseconds: 1700),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(color: Color.fromRGBO(67, 108, 35, .3)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(67, 108, 35, .2),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      )
                                    ]
                                ),
                                child: Form(
                                  key: _formkeyyy,
                                  child:  Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                        child: TextFormField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Email",
                                              hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,)
                                          ),
                                          validator: (value) {
                                            if (value!.length == 0) {
                                              return "Заполните поле";
                                            }
                                            if (!RegExp(
                                                "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                                .hasMatch(value)) {
                                              return ("Введите корректный email");
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (value) {
                                            emailController.text = value!;
                                          },
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              )),
                          SizedBox(height: 20,),
                          FadeInUp(duration: Duration(milliseconds: 1900),
                              child: MaterialButton(
                                onPressed: () async {
                                  if (_isLoading) {
                                    return;
                                  }else
                                    sendPasswordResetEmail(emailController.text);
                                    },
                                color: Color.fromRGBO(15, 32, 26, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                child: Center(
                                  child: Stack(
                                    children: [
                                      if (_isLoading) CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(172, 193, 91, 1)), )
                                      else Text("Сбросить", style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                                    ],
                                  ),
                                ),

                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),

            ]


        )

    );
  }


  Future<void> sendPasswordResetEmail(String email) async {
    if (_formkeyyy.currentState!.validate()) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Ошибка", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
                content: Text("Электронная почта не зарегистрирована в системе", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w400)),
                actions: <Widget>[
                  TextButton(
                    child: Text("ОК", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }else await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Успешно", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
              content: Text("На ${email} отправлено сообщение для сброса пароля", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w400)),
              actions: <Widget>[
                TextButton(
                  child: Text("ОК", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
        print('Password reset email sent.');
      } on FirebaseAuthException catch (e) {
        print('Error sending password reset email: ${e.message}');
      }
    }
  }



}