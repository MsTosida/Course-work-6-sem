import 'package:click/models/postModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/userModel.dart';
import 'detail.dart';


class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final DatabaseService _databaseService = DatabaseService();
  late final  CollectionReference imgColRef;
  String searchText = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 8), // Устанавливаем отступ в 0// Смещаем содержимое влево на 10 пикселей
          child: Text("Избранное", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
          ),
        ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseService.getPostsFav(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text("Постов пока нет(", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
              ),
            );
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text("Постов пока нет", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),),
              ),
            );
          }
          return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(id: post.id),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/loading.gif',
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
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Успешно"),
                                              content: Text("Пост был удален."),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text("ОК", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1)),),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      if (result == 'FavoriteDelete') {
                                        _databaseService.deletePostFav(post.id);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Успешно"),
                                              content: Text("Пост был удален из избранного!"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text("ОК", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1)),),
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
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuEntry<String>> menuItems = [];

                                      menuItems.add(const PopupMenuItem<String>(
                                        value: 'FavoriteDelete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline),
                                            SizedBox(width: 10,),
                                            Text("Удалить из избранного")
                                          ],
                                        ),
                                      ));

                                      if(post['uid'] == user!.uid){
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
      ),
    );
  }
}
