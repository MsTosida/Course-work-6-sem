import 'package:animate_do/animate_do.dart';
import 'package:click/pages/roles/guest.dart';
import 'package:click/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot.dart';
import 'roles/home.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool visible = false;
  bool _obscureText = true;
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 330,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: -40,
                        height: 350,
                        width: width,
                        child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/background.png'),
                                  fit: BoxFit.fill
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        height: 330,
                        width: width+20,
                        child: FadeInUp(duration: Duration(milliseconds: 1000), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/background-2.png'),
                                  fit: BoxFit.fill
                              )
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: Center(
                          child: Text(
                            "Добро пожаловать!",
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
                      FadeInUp(duration: Duration(milliseconds: 1700), child: Container(
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
                          key: _formkey,
                          child:  Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(
                                        color: Color.fromRGBO(67, 108, 35, .3)
                                    ))
                                ),
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
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Пароль",
                                    hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    RegExp regex = new RegExp(r'^.{6,}$');
                                    if (value!.isEmpty) {
                                      return "Заполните поле";
                                    }
                                    if (!regex.hasMatch(value)) {
                                      return ("Пароль не меньше 6 символов");
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    passwordController.text = value!;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              )

                            ],
                          ),
                        ),

                      )),
                      SizedBox(height: 8,),
                      FadeInUp(duration: Duration(milliseconds: 2000),
                          child: Center(
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPage(),
                                      ),
                                    );
                                  },
                                  child: Text("Забыли пароль?", style: TextStyle(color: Color.fromRGBO(172, 193, 91, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),)))),
                      SizedBox(height: 8,),
                      FadeInUp(duration: Duration(milliseconds: 1900), child: MaterialButton(
                        onPressed: () async {

                          setState(() {
                            _isLoading = true;
                          });

                            final message = await signIn(
                              emailController.text,
                              passwordController.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );

                            if (message.contains('Добро пожаловать!')) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            }

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
                              else Text("Войти", style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                            ],
                          ),
                        ),
                      )),
                      SizedBox(height: 20,),
                      FadeInUp(duration: Duration(milliseconds: 2000),
                          child: Center(
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUp(),
                                      ),
                                    );
                                  },
                                  child: Text("Еще не с нами? Зарегистрируйтесь!", style: TextStyle(color: Color.fromRGBO(172, 193, 91, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),)))),
                      FadeInUp(duration: Duration(milliseconds: 2000),
                          child: Center(
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GuestPage(),
                                      ),
                                    );
                                  },
                                  child: Text("Продолжить без входа", style: TextStyle(color: Color.fromRGBO(172, 193, 91, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),)))),

                    ],
                  ),
                )
              ],
            ),
          ),

        ],
      ),

    );
  }

  // void signIn(String email, String password) async {
  //   if (_formkey.currentState!.validate()) {
  //     try {
  //       UserCredential userCredential =
  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => HomePage(),
  //         ),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'user-not-found') {
  //         print('Такого пользователя не существует');
  //       } else if (e.code == 'wrong-password') {
  //         print('Неверный пароль');
  //       }
  //     }
  //   }
  // }

  Future<String> signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return 'Добро пожаловать!';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return 'Юзера с таким email нет';
        } else if (e.code == 'wrong-password') {
          return 'Неверный пароль';
        }
      }finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    return 'Неверные данные'; // Добавлено возвращение сообщения об ошибке
  }

}