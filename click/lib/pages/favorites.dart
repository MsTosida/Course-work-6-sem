import 'package:click/models/postModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/userModel.dart';
import 'detail.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


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
  List<String> searchWords = [];

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

          List<DocumentSnapshot> filteredPosts = [];
          for (var post in snapshot.data!.docs) {
            bool isMatch = true;
            for (var word in searchWords) {
              if (!post['tags'].toLowerCase().contains(word.toLowerCase())) {
                isMatch = false;
                break;
              }
            }
            if (isMatch) {
              filteredPosts.add(post);
            }
          }

          if (filteredPosts.isEmpty) {
            return Center(child: Text("Ничего не найдено", style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontFamily: 'Montserrat', fontWeight: FontWeight.w500,),));
          }

          return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child:
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoSearchTextField(
                            onChanged: (value) {
                              setState(() {
                                searchWords = value.split(' ');
                              });
                            },
                            placeholder: 'Поиск',
                          ),
                        ),
                      ],
                    ),
                ),
                Expanded(child:  StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: filteredPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot post = filteredPosts[index];
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

                                      if(result == 'Download'){
                                        downloadAndSaveImage(post['imageUrl']);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuEntry<String>> menuItems = [];

                                      menuItems.add(const PopupMenuItem<String>(
                                        value: 'Download',
                                        child: Row(
                                          children: [
                                            Icon(Icons.download_outlined),
                                            SizedBox(width: 10,),
                                            Text("Скачать")
                                          ],
                                        ),
                                      ));

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
}
