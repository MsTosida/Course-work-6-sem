import 'package:click/models/postModel.dart';
import 'package:click/pages/roles/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/userModel.dart';
import 'package:intl/intl.dart';


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
  var desc;
  var imageUrlForPost;
  var imageUrlForUser;
  var nameForUser;
  var imageUrlForCurUser;
  var uId;
  List likes = [];
  DateTime time =  DateTime.now();

  List<String>? tags;
  final DatabaseService _databaseService = DatabaseService();

  _DetailPageState({required this.id});
  @override
  void initState() {
    super.initState();
    if (user!= null){
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

      FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .get()
          .then((value) {
        this.post = PostModel.fromMap(value.data());
      }).whenComplete(() {
        setState(() {
          desc = post.desc.toString();
          imageUrlForPost = post.imageUrl.toString();
          time = post.time;
          tags = post.tags;
          uId = post.uid;
          likes = post.likes;
        });
      });

    }
  }


  Future<Map<String, dynamic>?> getImageUrlAndNameForUser(String postId) async {
    String userId = postId;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      String? imageUrlForUser = userSnapshot['imageUrl'];
      String? nameForUser = userSnapshot['name'];
      return {'imageUrl': imageUrlForUser, 'name': nameForUser};
    } else {
      return null;
    }
  }

  Future<void> likePost(
      BuildContext context,
      ) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          'likes': FieldValue.arrayUnion([user!.uid])
        },
      );
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }

  Future<void> dislikePost(
      BuildContext context,
      ) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          'likes': FieldValue.arrayRemove([user!.uid])
        },
      );
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => {
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => UserPage(id: user!.uid, selectedIndex: 0,),
          ),
          )
          },
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            color: Colors.white,
            icon: Icon(Icons.more_vert),
            onSelected: (String result) {
              if (result == 'Delete') {
                _databaseService.deletePost(id);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserPage(id: user!.uid, selectedIndex: 0,)));
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
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                future: getImageUrlAndNameForUser(uId?? 'defaultUserId'),
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    String? imageUrl = snapshot.data?['imageUrl'];
                    String? name = snapshot.data?['name'];
                    return Row(
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
                                backgroundImage: imageUrl!= null? NetworkImage(imageUrl) : null,
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
                                if (likes.contains(user!.uid)) {
                                  dislikePost(context);
                                } else {
                                  likePost(context);
                                }
                              },
                              icon: likes.contains(user!.uid)
                                  ? const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              )
                                  : const Icon(
                                Icons.favorite_border,
                                color: Colors.grey,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            Text(
                              likes.length.toString(),
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Text('Данные не найдены'); // Обрабатываем случай, когда данные не найдены
                  }
                },
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Flexible(
                      child: Text(
                        desc ?? 'Описание',
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
                children: tags?.map((tag) => Text(tag, style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),)).toList()?? [],
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
