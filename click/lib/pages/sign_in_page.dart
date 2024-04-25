import 'package:animate_do/animate_do.dart';
import 'package:click/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'roles/home.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool visible = false;
  bool _obscureText = true;
  bool _showCloseButton = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showCloseButton = true;
      });
    });
  }


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
                              fontWeight: FontWeight.bold,
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
                                      hintStyle: TextStyle(color: Colors.grey.shade700)
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
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
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
                      SizedBox(height: 20,),
                      FadeInUp(duration: Duration(milliseconds: 1900), child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            visible = true;
                          });
                          final message = await login(
                            emailController.text,
                            passwordController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );

                          if (message.contains('Success')) {
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
                          child: Text("Войти", style: TextStyle(color: Colors.white),),
                        ),
                      )),
                      SizedBox(height: 30,),
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
                                  child: Text("Еще не с нами? Зарегестрируйтесь!", style: TextStyle(color: Color.fromRGBO(172, 193, 91, 1)),)))),

                    ],
                  ),
                )
              ],
            ),
          ),
          if (_showCloseButton)
            Positioned(
              top: 40, // Отступ от верхнего края
              right: 10, // Отступ от правого края
              child: IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white, // Цвет границы
                      width: 2.0, // Толщина границы
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white, // Цвет иконки
                    size: 30.0, // Размер иконки
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(), // Замените AnotherPage на вашу страницу
                    ),
                  );
                },
              ),
            ),

        ],
      ),

    );
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('Такого пользователя не существует');
        } else if (e.code == 'wrong-password') {
          print('Неверный пароль');
        }
      }
    }
  }

  Future<String> login(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        return 'Success';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          return 'Wrong password provided for that user.';
        }
      }
    }
    return 'Неверные данные'; // Добавлено возвращение сообщения об ошибке
  }

}