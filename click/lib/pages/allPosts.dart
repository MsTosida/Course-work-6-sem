import 'dart:io';
import 'package:click/models/postModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import '../models/userModel.dart';
import '../widgets/showDialog.dart';
import 'detail.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';


class AllPostPage extends StatefulWidget {
  AllPostPage({Key? key}) : super(key: key);

  @override
  _AllPostPageState createState() => _AllPostPageState();
}

class _AllPostPageState extends State<AllPostPage> {
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
        });
      });
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
          title: Padding(
            padding: EdgeInsets.only(left: 8),
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 20,
            ),
          ),
        ),
        body:  StreamBuilder<QuerySnapshot>(
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
                                    onSelected: (String result) async {
                                      if (result == 'Delete') {
                                        _databaseService.deletePost(post.id);
                                      }
                                      if (result == 'Favorite') {
                                        bool addedToFavorites = await _databaseService.addPostFav(post.id);
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
      )
    );
  }
}
