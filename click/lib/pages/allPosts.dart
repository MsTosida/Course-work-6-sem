import 'package:click/models/postModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/userModel.dart';
import 'detail.dart';


class AllPostPage extends StatefulWidget {
  AllPostPage({Key? key}) : super(key: key);

  @override
  _AllPostPageState createState() => _AllPostPageState();
}

class _AllPostPageState extends State<AllPostPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  var role;
  var id;
  final DatabaseService _databaseService = DatabaseService();
  late final  CollectionReference imgColRef;
  String searchText = '';

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
          id = loggedInUser.uid.toString();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseService.getPosts(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Ошибка!');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text("Постов пока нет"),
            ),
          );
        }
        return Padding(padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      placeholder: 'Поиск',
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.search, color: Color.fromRGBO(22, 31, 10, 1),),
                    onPressed: () {

                    },
                  ),
                ],
              ),
              Expanded(child:  StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot post = snapshot.data!.docs[index];
                  return Card(
                    color: Colors.grey.shade100,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(id: post.id),
                              ),
                            );
                          },
                          child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif', // Путь к вашему GIF или изображению по умолчанию
                            image: post['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        ),
                        if (user!= null)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: Icon(Icons.more_horiz),
                                onSelected: (String result) {
                                  if (result == 'Delete') {
                                    _databaseService.deletePost(post.id);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  List<PopupMenuEntry<String>> menuItems = [];
                                  if(role!= null && role == 'userRole' && post['uid'] == user!.uid){
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
                                  if(role!= null && role == 'userRole' && post['uid'] == user!.uid || role == 'adminRole'){
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
                                  // Возвращаем список элементов меню
                                  return menuItems;
                                },
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                    ),


                  );
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),),

            ],),);
      },
    );
  }
}
