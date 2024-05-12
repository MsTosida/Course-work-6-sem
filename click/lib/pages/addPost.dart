import 'dart:io' as io;
import 'package:click/models/postModel.dart';
import 'package:click/pages/roles/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPostPage extends StatefulWidget {
  AddPostPage({Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  _AddPostPageState();
  final _formkeey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _isImageSelected = false;
  final FocusNode _focusNode = FocusNode();
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    selectFile();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (_tagsController.text.isEmpty || !_tagsController.text.startsWith('#')) {
        _tagsController.text = '#' + _tagsController.text;
      }
    }
  }

  PlatformFile? pickedFile;
  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],);
    if(result == null) return;

    setState(() {
      pickedFile= result.files.first;
      _isImageSelected = true;
    });
  }

  Future<String> uploadFile() async{
    final path = 'post/${pickedFile!.name}';
    final file = io.File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 55, 40, 55),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text("Добавить пост", style: TextStyle(fontSize: 20,  fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),),
                      SizedBox(height: 20,),
                      Stack(
                        children: [
                          InkWell(
                            highlightColor: Colors.transparent,
                            onTap: (){
                              selectFile();
                            },
                            child: pickedFile != null ?
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(172, 193, 91, 1),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              height: 400,
                              width: 400,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  io.File(pickedFile!.path!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),

                              ),
                            ):
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(172, 193, 91, 1),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(13), // Закругленные углы
                              ),
                              height: 400,
                              width: 400,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  "assets/images/noPhoto.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8), // Внутренний отступ для иконки
                              child: Icon(
                                Icons.edit,
                                color: Color.fromRGBO(172, 193, 91, 1),
                              ),
                            ),
                          )
                        ],
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
                          key: _formkeey,
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
                                  controller: _descController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Описание",
                                      hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,)
                                  ),
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return "Заполните поле";
                                    }

                                    if (value.length > 50) {
                                      return "Текст должен содержать не более 50 символов";
                                    }
                                  },
                                  onSaved: (value) {
                                    _descController.text = value!;
                                  },
                                  keyboardType: TextInputType.text,
                                  maxLength: 50,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: TextFormField(
                                  controller: _tagsController,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Тэги",
                                    hintStyle: TextStyle(color: Colors.grey.shade700, fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Заполните поле";
                                    }
                                    List<String> words = value.split(' ');
                                    for (var word in words) {
                                      if (!word.startsWith('#') || word.length <= 1) {
                                        return "Введите теги корректно";
                                      }
                                      // Удаляем символ # из слова, чтобы проверить, что после него есть символы
                                      String tagWithoutHash = word.substring(1);
                                      // Проверяем, что символ # не повторяется в теге
                                      if (tagWithoutHash.contains('#')) {
                                        return "Без повторяющегося символа # в теге";
                                      }
                                      // if (tagWithoutHash.length>10) {
                                      //   return "Тег меньше 10 символов";
                                      // }
                                    }
                                    return null;
                                  },


                                  onSaved: (value) {
                                    _tagsController.text = value!;
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
                          if (_isImageSelected) {
                            setState(() {
                              _isLoading = true;
                            });

                            User? user = _auth.currentUser;
                            addPost(user!.uid, _descController.text, _tagsController.text);

                          } else if (!_isImageSelected) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Ошибка', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                                  content: Text('Выберите фото для поста', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                                      onPressed: () {
                                        Navigator.of(context).pop();
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
                              else Text("Добавить", style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  )
                ],
              ),
            )
          ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> addPost(String uid, String desc, String tagText) async{
    if (_formkeey.currentState!.validate()) {
      try {
        List<String> tagList = _tagsController.text.split(' ')
            .where((tag) => tag.startsWith('#'))
            .toList();

        String imageUrl = await uploadFile();

        PostModel post = PostModel(uid: uid,
            desc: desc,
            imageUrl: imageUrl,
            tags: tagList);

        _databaseService.addPost(post);

      } finally {

        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Успешно', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
              content: Text('Пост добавлен', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w400,),),
              actions: <Widget>[
                TextButton(
                  child: Text('OK', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => UserPage(selectedIndex: 0)));
                  },
                ),
              ],
            );
          },
        );
      }
  }else {
      setState(() {
        _isLoading = false;
      });
    }
  }


}
