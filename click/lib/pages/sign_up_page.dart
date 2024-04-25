import 'dart:typed_data';
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

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  bool _showCloseButton = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool visible = false;
  var role = "userRole";


  Uint8List? _image;
  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    } else {
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showCloseButton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body:  Stack(
        children: [
          SingleChildScrollView(
            child:  Column(
              children: <Widget>[
                Padding(
            padding: EdgeInsets.fromLTRB(40, 100, 40, 100),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20,),
                FadeInUp(
                  duration: Duration(milliseconds: 1500),
                  child: Center(
                    child: Text(
                      "Регистрация",
                      style: TextStyle(
                        color: Color.fromRGBO(22, 31, 10, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                FadeInUp(
                  duration: Duration(milliseconds: 1700),
                  child: Center(
                    child: Stack(
                      children: [
                        _image != null ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        ) :
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: AssetImage("assets/images/profilo.jpg"),
                        ),
                        Positioned(
                          child: Icon(Icons.add_a_photo),
                          bottom: 10,
                          left: 95,
                        ),
                        InkWell(
                          highlightColor: Colors.transparent,
                          onTap: (){
                            selectImage();
                          },
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
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
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                      color: Color.fromRGBO(67, 108, 35, .3)
                                  ))
                              ),
                              child: TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Имя",
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                ),
                                validator: (value){
                                  if (value!.isEmpty) {
                                    return "Заполните поле";
                                  }
                                },
                                onSaved: (value) {
                                    nameController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                      color: Color.fromRGBO(67, 108, 35, .3)
                                  ))
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Пароль",
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
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
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: TextFormField(
                                controller: confirmPassController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Повторите пароль",
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Заполните поле";
                                  }

                                  RegExp regex = new RegExp(r'^.{6,}$');
                                  if (value != passwordController.text) {
                                    return "Пароли не совпадают";
                                  }
                                  else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  confirmPassController.text = value!;
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
                    signUp(
                        emailController.text, passwordController.text, role, nameController.text, (_image ?? await getDefaultImage()) as Uint8List?);

                  },
                  color: Color.fromRGBO(15, 32, 26, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  child: Center(
                    child: Text("Регистрация", style: TextStyle(color: Colors.white),),
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
                                  builder: (context) => SignIn(),
                                ),
                              );
                            },
                            child: Text("Уже с нами? Войдите!", style: TextStyle(color: Color.fromRGBO(172, 193, 91, 1)),)))),
              ],
            ),
          )
        ],
      ),
    )]


      )

    );
  }

  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveDate({
    required String email, required String role, required String name, required Uint8List file
  }) async{
    String resp = "Some error";
    try{
      String imageUrl = await uploadImageToStorage("profileImage?${DateTime.now().millisecondsSinceEpoch}", file);

      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User? user = _auth.currentUser;
      UserModel userModel = UserModel();
      userModel.uid = user!.uid;
      userModel.email = email;
      userModel.name = name;
      userModel.role = role;
      userModel.imageUrl = imageUrl;

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(userModel.toMap());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));

  }catch(err){
    resp = err.toString();
    }
    return resp;
  }

  Future<Uint8List?> getDefaultImage() async {
    try {
      // Загрузка дефолтного изображения из активов
      ByteData data = await rootBundle.load('assets/images/profilo.jpg');
      Uint8List bytes = data.buffer.asUint8List();

      return bytes;
    } catch (e) {
      print("Ошибка при загрузке дефолтного изображения: $e");
      return null;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  Future<bool> isEmailUnique(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isEmpty;
  }


  void signUp(String email, String password, String role, String name, Uint8List? file) async {
    if (_formkey.currentState!.validate()) {

      bool isEmailUniqueResult = await isEmailUnique(email);
      if (!isEmailUniqueResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email уже используется')),
        );
        return;
      }

      bool isUsernameUniqueResult = await isUsernameUnique(name);
      if (!isUsernameUniqueResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Имя пользователя уже существует')),
        );
        return;
      }

      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {saveDate(email: email, role: role, name: name, file: file!)})
          .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при регистрации: $e')),
        );
      });
    }
  }

}