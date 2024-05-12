import 'dart:typed_data';
import 'package:click/pages/roles/user.dart';
import 'package:click/widgets/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


class UpdateProfile extends StatefulWidget {
  String id;
  String email;
  String name;
  String image;
  UpdateProfile({required this.id, required this.email, required this.name, required this.image});

  @override
  _UpdateProfileState createState() => _UpdateProfileState(id: id, email: email, name: name, image: image);
}

class _UpdateProfileState extends State<UpdateProfile>  {
  String id;
  String email;
  String name;
  String image;
  bool _isLoading = false;
  _UpdateProfileState({required this.id, required this.email, required this.name, required this.image});


  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _formkeyyy = GlobalKey<FormState>();
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
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
        body:  Stack(
            children: [
              SingleChildScrollView(
                child:  Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20,),
                          Center(
                              child: Text(
                                "Изменить профиль",
                                style: TextStyle(
                                  color: Color.fromRGBO(22, 31, 10, 1),
                                  fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          SizedBox(height: 20,),
                           Center(
                              child: Stack(
                                children: [
                                  _image != null ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: MemoryImage(_image!),
                                  ) :
                                  CircleAvatar(
                                    radius: 64,
                                    backgroundImage: NetworkImage(image ?? ''),
                                  ),
                                  Positioned(
                                    child: Icon(Icons.edit),
                                    bottom: 10,
                                    left: 108,
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

                          SizedBox(height: 20,),
                          Container(
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
                                        decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(
                                                color: Color.fromRGBO(67, 108, 35, .3)
                                            ))
                                        ),
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: name,
                                            hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),
                                          ),
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
                                            hintText: "Новый пароль",
                                            hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),
                                          ),
                                          validator: (value) {
                                            if(!passwordController.text.isEmpty){
                                              RegExp regex = new RegExp(r'^.{6,}$');
                                              if (!regex.hasMatch(value!)) {
                                                return ("Пароль не меньше 6 символов");
                                              } else {
                                                return null;
                                              }
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
                                            hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),
                                          ),
                                          validator: (value) {

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
                              ),
                          SizedBox(height: 20,),
                         MaterialButton(
                            onPressed: () async {
                              if (_formkeyyy.currentState!.validate()) {

                                setState(() {
                                  _isLoading = true;
                                });

                                _formkeyyy.currentState!.save();
                                try {
                                  if(!passwordController.text.isEmpty  && !confirmPassController.text.isEmpty){
                                    await _auth.currentUser!.updatePassword(passwordController.text);
                                    print("Пароль успешно изменен");
                                  }
                                } catch (e) {
                                  print("Ошибка при изменении пароля: $e");
                                }

                                if (_image != null) {
                                  try {
                                    Reference ref = FirebaseStorage.instance.ref().child('profileImages/${_auth.currentUser!.uid}');
                                    UploadTask uploadTask = ref.putData(_image!);
                                    TaskSnapshot snapshot = await uploadTask;
                                    String downloadUrl = await snapshot.ref.getDownloadURL();
                                    // Обновление ссылки на изображение в Firestore

                                    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid);
                                    await userDocRef.update({'imageUrl': downloadUrl});
                                    print("Изображение профиля успешно обновлено");
                                  } catch (e) {
                                    print("Ошибка при обновлении изображения профиля: $e");
                                  }
                                }
                                // Изменение имени пользователя

                                try {
                                  if(!nameController.text.isEmpty){
                                    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid);
                                    await userDocRef.update({'name': nameController.text});
                                    print("Имя пользователя успешно обновлено");
                                  }
                                } catch (e) {
                                  print("Ошибка при обновлении имени пользователя: $e");
                                }

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Успешно изменено", style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
                                      content: Text("Данные были успешно изменены", style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("ОК", style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) =>UserPage(selectedIndex: 4,)),
                                                  (Route<dynamic> route) => false,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
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
                                  else Text("Сохранить", style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),

                        ],
                      ),
                    )
                  ],
                ),
              )]
        ),
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

  Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }


  void updateProfile(  String name, String password, Uint8List? file) async {
    if (_formkeyyy.currentState!.validate()) {
      try{
        bool isUsernameUniqueResult = await isUsernameUnique(name);
        if (!nameController.text.isEmpty  && !isUsernameUniqueResult) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Имя пользователя уже существует')),
          );
          return;
        }
        Map<String, dynamic> updateData = {};

        if (name != widget.name) {
          updateData['name'] = name;
        }

        if (file != widget.image) {
          String imageUrl = await uploadImageToStorage("profileImage?${DateTime.now().millisecondsSinceEpoch}", file!);
          updateData['imageUrl'] = imageUrl;
        }

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.id)
            .update(updateData)
            .then((value) {
          Navigator.of(context).pop();
        });

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении профиля: $e')),
        );
      }finally {
        setState(() {
          _isLoading = false;
        });
      }


    }
  }


}