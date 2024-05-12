import 'package:click/models/postModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import '../models/userModel.dart';
import 'detail.dart';

class SearchPage extends StatefulWidget {
  SearchPage();

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final postReference = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('time', descending: true);

  var role;
  final DatabaseService _databaseService = DatabaseService();
  late final  CollectionReference imgColRef;
  String searchText = '';




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.all(8),
            child:  Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    placeholder: 'Поиск по тегам',
                  ),
                ),
              ],
            ),

            ),
          ),

      body: StreamBuilder<QuerySnapshot>(
        stream: searchText.isEmpty
          ? _databaseService.getPosts()
            : _databaseService.getPostsByTags(searchText.split(' ')),

    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Padding(padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                            if (user!= null && role != 'adminRole')...[
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
                                      if (result == 'Favorite') {
                                        _databaseService.addPostFav(post.id);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Успешно"),
                                              content: Text("Пост был добавлен в избранное!"),
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
                                        value: 'download',
                                        child: Row(
                                          children: [
                                            Icon(Icons.download_outlined),
                                            SizedBox(width: 10,),
                                            Text("Скачать")
                                          ],
                                        ),
                                      ));

                                      if (role!= null) {
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
                                      if(role!= null && role == 'userRole' && post['uid'] == user!.uid){
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
                            else if(role == 'adminRole')...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(onPressed: () {_databaseService.deletePost(post.id);}, icon: Icon(Icons.delete_outline))
                                ],
                              )
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

