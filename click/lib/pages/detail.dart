import 'package:click/models/postModel.dart';
import 'package:click/pages/roles/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../models/userModel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../widgets/showDialog.dart';


class DetailPage extends StatefulWidget {
  String id;
  DetailPage({required this.id});

  @override
  _DetailPageState createState() => _DetailPageState(id: id);
}


class _DetailPageState extends State<DetailPage> {
  String id;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  PostModel post = PostModel();
  var role;
  var imageUrlForPost;
  var imageUrlForCurUser;
  var uId;
  DateTime time =  DateTime.now();
  final DatabaseService _databaseService = DatabaseService();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLiked = false;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final _formkeeey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  final _commentController = TextEditingController();

  _DetailPageState({required this.id});
  @override
  void initState() {
    super.initState();

    if (user!= null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        this.loggedInUser = UserModel.fromMap(value.data());
      }).whenComplete(() {
        setState(() {
          role = loggedInUser.role.toString();
          imageUrlForCurUser = loggedInUser.imageUrl.toString();
        });
      });
    }

      FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .get()
          .then((value) {
        this.post = PostModel.fromMap(value.data());
      }).whenComplete(() {
        setState(() {
          imageUrlForPost = post.imageUrl.toString();
          uId = post.uid;
        });
      });

  }

  Future<void> likePost(BuildContext context) async {
    try {
      if(user!= null && role != null && role != 'adminRole'){
        await FirebaseFirestore.instance.collection('posts').doc(id).update(
          {
            'likes': FieldValue.arrayUnion([userId])
          },
        );
        setState(() {
          if (!post.likes.contains(userId)) {
            post.likes.add(userId);
          }
          isLiked =!isLiked;
        });
      }
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }

  Future<void> dislikePost(BuildContext context) async {
    try {
      if(user!= null && role != null && role != 'adminRole'){
        await FirebaseFirestore.instance.collection('posts').doc(id).update(
          {
            'likes': FieldValue.arrayRemove([userId])
          },
        );
        setState(() {
          if (post.likes.contains(userId)) {
            post.likes.remove(userId);
          }
          isLiked =!isLiked;
        });
      }
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> getInfoPost(String postId) async {
    DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get();

    if (postSnapshot.exists && userSnapshot.exists) {
      List<dynamic> likes = postSnapshot['likes'];
      String? imageUrlForUser = userSnapshot['imageUrl'];
      String? nameForUser = userSnapshot['name'];
      String? desc = postSnapshot['desc'];
      String? tags = postSnapshot['tags'];
      return {'likes': likes, 'desc': desc, 'tags': tags, 'imageUrl': imageUrlForUser, 'name': nameForUser};
    } else {
      return null;
    }
  }

  Future<void> _editPost(BuildContext context) async {
    final TextEditingController descController = TextEditingController(text: post.desc);
    final TextEditingController tagsController = TextEditingController(text: post.tags ?? '');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать пост', style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formkeeey,
                  child:  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextFormField(
                          controller: descController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Описание',
                                labelStyle: TextStyle(color: Color.fromRGBO(15, 32, 26, 1),fontFamily: 'Montserrat', fontWeight: FontWeight.w400,), // Цвет текста метки
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromRGBO(67, 108, 35, .3)), // Цвет границы при фокусе
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromRGBO(67, 108, 35, .3)), // Цвет границы при активации
                                ),
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
                            descController.text = value!;
                          },
                          keyboardType: TextInputType.text,
                          maxLength: 50,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextFormField(
                          controller: tagsController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Теги',
                            labelStyle: TextStyle(color: Color.fromRGBO(15, 32, 26, 1),fontFamily: 'Montserrat', fontWeight: FontWeight.w400,), // Цвет текста метки
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(67, 108, 35, .3)), // Цвет границы при фокусе
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(67, 108, 35, .3)), // Цвет границы при активации
                            ),
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
                              String tagWithoutHash = word.substring(1);
                              if (tagWithoutHash.contains('#')) {
                                return "Без повторяющегося символа # в теге";
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            tagsController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Отмена', style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Сохранить', style: TextStyle(color: Color.fromRGBO(15, 32, 26, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,)),
              onPressed: () {
                if (_formkeeey.currentState!.validate()) {
                  _updatePost(descController.text, tagsController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );

  }

  Future<void> _updatePost(String newDesc, String newTags) async {
      try {
        await _databaseService.updatePost(id, {
          'desc': newDesc,
          'tags': newTags,
        });

        setState(() {
          post.desc = newDesc;
          post.tags = newTags;
        });
      } catch (e) {
        print("Ошибка при обновлении поста: $e");
      }

  }

  Future<void> postComment(String text) async {
    try {
      final String commentId = Uuid().v4();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(id)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'cid': commentId,
            'uid': userId,
            'text': text,
            'time': Timestamp.now().toDate(),
          }
        ])
      });

      _commentController.clear();
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error posting comment'),
        ),
      );
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    return await userRef.get();
  }

  Future<void> deleteComment(String commentId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(id)
          .get();

      if (snapshot.exists &&
          snapshot.data() is Map<String, dynamic> &&
          (snapshot.data() as Map<String, dynamic>).containsKey('comments')) {

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> comments = data['comments'] ?? [];

        comments.removeWhere((comment) => comment['cid'] == commentId);

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(id)
            .update({
          'comments': comments,
        });

        setState(() {});
      } else {
        print("Comment with ID $commentId not found.");
      }
    } on FirebaseException catch (e) {
      print("Error deleting comment: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting comment: ${e.message}'),
        ),
      );
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final appDir = await getTemporaryDirectory();
      final file = File('${appDir.path}/image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      final result = await ImageGallerySaver.saveFile(file.path);
      if (result['isSuccess']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Успешно',
                style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Text(
                'Изображение успешно сохранено',
                style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Color.fromRGBO(22, 31, 10, 1),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        print('Изображение успешно сохранено в галерее');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Ошибка',
                style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Text(
                'Ошибка при сохранении изображения: ${result['errorMessage']}',
                style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Color.fromRGBO(22, 31, 10, 1),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        print('Ошибка при сохранении изображения: ${result['errorMessage']}');
      }
    } else {
      print('Ошибка при скачивании изображения. Код статуса: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          Visibility(
            visible: role == 'adminRole',
            child: IconButton(
              onPressed: () {
                _databaseService.deletePost(widget.id);
                Navigator.pop(context);
              },
              icon: Icon(Icons.delete_outline),
            ),
          ),
          Visibility(
            visible: role == 'userRole',
            child: PopupMenuButton<String>(
              color: Colors.white,
              icon: Icon(Icons.more_vert),
              onSelected: (String result) async {
                if (result == 'Delete') {
                  _databaseService.deletePost(id);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserPage(selectedIndex: 0,)));
                }

                if (result == 'Edit') {
                  _editPost(context);
                }

                if(result == 'Download'){
                  downloadAndSaveImage(imageUrlForPost);
                }

                if (result == 'Favorite') {

                  bool addedToFavorites = await _databaseService.addPostFav(id);
                  if (addedToFavorites)
                  CustomAlertDialog.show(
                    context: context,
                    title: 'Успешно',
                    content: 'Пост был добавлен в избранное!',
                    buttonText: 'ОК',
                  );

                  else CustomAlertDialog.show(
                    context: context,
                    title: 'Ошибка',
                    content: 'Пост уже в избранном!',
                    buttonText: 'ОК',
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> menuItems = [];
                if(role!= null && role == 'userRole' && uId == user!.uid){
                  menuItems.add(const PopupMenuItem<String>(
                    value: 'Edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 10,),
                        Text("Редактировать")
                      ],
                    ),
                  ));
                }
                if (role!= null && role == 'userRole' && role != 'adminRole') {
                  menuItems.add(const PopupMenuItem<String>(
                    value: 'Download',
                    child: Row(
                      children: [
                        Icon(Icons.file_download_outlined),
                        SizedBox(width: 10,),
                        Text("Скачать")
                      ],
                    ),
                  ));
                }
                if (role!= null && role == 'userRole') {
                  menuItems.add(const PopupMenuItem<String>(
                    value: 'Favorite',
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 10,),
                        Text("В избранное")
                      ],
                    ),
                  ));
                }
                if (role!= null && role == 'userRole' && uId == user!.uid || role == 'adminRole') {
                  menuItems.add(const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10,),
                        Text("Удалить")
                      ],
                    ),
                  ));
                }

                return menuItems;
              },
            ),
          ),
          Visibility(
            visible: userId == null,
            child: IconButton(
              onPressed: () {
                downloadAndSaveImage(imageUrlForPost);
              },
              icon: Icon(Icons.file_download_outlined),
            ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrlForPost!= null
                    ? FadeInImage.assetNetwork(
                  placeholder: 'assets/images/loading.gif',
                  image: imageUrlForPost!,
                  fit: BoxFit.cover,
                )
                    : Image.asset('assets/images/noPhoto.png'),
              ),
              SizedBox(height: 20,),
              FutureBuilder<Map<String, dynamic>?>(
                  future: getInfoPost(id?? 'defaultUserId'),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Ошибка: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      String? imageUrl = snapshot.data?['imageUrl'];
                      String? name = snapshot.data?['name'];
                      List likes = snapshot.data?['likes'];
                      String? desc = snapshot.data?['desc'];
                      String? tags = snapshot.data?['tags'];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color.fromRGBO(172, 193, 91, 1),
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: imageUrl!= null? NetworkImage(imageUrl) : AssetImage("assets/images/noPhoto.png") as ImageProvider,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    name?? 'userName',
                                    style: TextStyle(
                                      color: Color.fromRGBO(22, 31, 10, 1),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if(user!= null){
                                        if (likes.contains(userId)) {
                                          dislikePost(context);
                                        } else {
                                          likePost(context);
                                        }
                                      }
                                    },
                                    icon: user!= null && likes.contains(userId)
                                        ? const Icon(
                                      Icons.favorite,
                                      color: Color.fromRGBO(172, 193, 91, 1),
                                    )
                                        : const Icon(
                                      Icons.favorite_border,
                                      color: Color.fromRGBO(22, 31, 10, 1),
                                    ),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                  Text(
                                    likes.length.toString(),
                                    style: const TextStyle(
                                      color: Color.fromRGBO(22, 31, 10, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    desc?? 'Описание',
                                    style: TextStyle(
                                      color: Color.fromRGBO(22, 31, 10, 1),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children:
                            [Text(tags ?? 'tags', style: TextStyle(
                              color: Color.fromRGBO(22, 31, 10, 1),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                    ]
                    )
                        ],
                      );
                    } else {
                      return Text('Данные не найдены');
                    }
                  }),
              SizedBox(height: 10,),
              Row(
                  children:[
                    Text(
                      DateFormat('dd.MM.yyyy').format(time) ?? 'Время',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    )
                  ]
              ),
              SizedBox(height: 30,),

                 Row(
                  children: [
                    Text('Комментарии', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: 20),)
                  ],
                ),


                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(id)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('There was an error fetching comments'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('Пока пусто('),
                      );
                    }

                    final post = snapshot.data;
                    if (post == null) {
                      return const Text('User data is not available');
                    }

                    final comments = post['comments'];
                    bool hasComments = comments.isNotEmpty;

                    return Column(
                      children: [
                        if (!hasComments)
                          Container(
                            padding: EdgeInsets.only(top: 30),
                            child: Text(
                              'Будьте первым!',
                              style: TextStyle(
                                color: Color.fromRGBO(22, 31, 10, 1),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ...List.generate(
                        comments.length,
                            (index) {
                          final comment = comments[index];
                          DateTime time = comment['time'].toDate();
                          final uid = comment['uid'];
                          return FutureBuilder<DocumentSnapshot>(
                            future: getUserData(uid),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.hasError) {
                                return const Text('Error loading user data');
                              }
                              if (!userSnapshot.hasData) {
                                return const Text('Loading user data...');
                              }

                              final userData = userSnapshot.data;
                              if (userData == null) {
                                return const Text('User data is not available');
                              }

                              final imageUrl = userData['imageUrl'];
                              final name = userData['name'];

                              return
                                Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Color.fromRGBO(172, 193, 91, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage: imageUrl!= null? NetworkImage(imageUrl) : AssetImage("assets/images/noPhoto.png") as ImageProvider,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                      color: Color.fromRGBO(22, 31, 10, 1),
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (userId != null && uid == user!.uid || role == 'adminRole')
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                onPressed: () async {
                                                  try {
                                                    await deleteComment(comment['cid']);
                                                  } catch (e) {
                                                    print(e);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('$e'),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          comment['text'],
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                          ),
                                          maxLines: 6,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('dd.MM.yyyy').format(time),
                                            style: TextStyle(color: Colors.grey,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w400,
                                            ),),
                                        ],
                                      ),
                                    ],
                                  ),)

                              );
                            },
                          );
                        },
                      ),
                    ]);
                  },
                ),
              ],
          ),
        ),
          ),
      bottomSheet:
          Visibility(
            visible: role == 'userRole',
            child: Container(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _commentController,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,

                  style: const TextStyle(
                    fontSize: 17,
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Why do you want to post an empty comment?';
                    }
                    return null;
                  },
                  onFieldSubmitted: ((value) {
                    if (_commentController.text.isNotEmpty) {
                      postComment(_commentController.text);
                      FocusScope.of(context).unfocus();
                    }
                  }),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          postComment(_commentController.text);
                          FocusScope.of(context).unfocus();
                        } else {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content:
                                Text('Why do you want to post an empty comment?'),
                              ),
                            );
                        }
                      },
                      icon: const Icon(Icons.send),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    hintText: "Добавить комментарий",
                    hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400 // Пример веса шрифта
                    ),
                    border: const UnderlineInputBorder(),

                  ),
                  maxLength: 100,
                ),
              ),
            ),
          )

        );
  }
}
