  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import '../models/postModel.dart';
  import '../models/userModel.dart';

  class AdminPanel extends StatefulWidget {
    @override
    _AdminPanelState createState() => _AdminPanelState();
  }

  class _AdminPanelState extends State<AdminPanel> {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];
    List<UserModel> filteredUsers = [];
    PostModel post = PostModel();
    String filterRole = 'all';
    String searchText = '';
    final uId = FirebaseAuth.instance.currentUser?.uid;
    final DatabaseService _databaseService = DatabaseService();

    @override
    void initState() {
      super.initState();
      _fetchUsers();
    }

    void _fetchUsers() async {
      QuerySnapshot querySnapshot;
      if (filterRole == 'all') {
        if (searchText.isEmpty) {
          querySnapshot = await _firestore.collection("users").orderBy("role").get();
        } else {
          querySnapshot = await _firestore
              .collection("users")
              .where("name", isEqualTo: searchText)
              .orderBy("role")
              .get();
        }
      } else {
        querySnapshot = await _firestore.collection("users").where("role", isEqualTo: filterRole).orderBy("role").get();
      }
      setState(() {
        users = querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
        filteredUsers = List.from(users);
      });
    }

    void _changeRole(String userId, String newRole) async {

      if(userId == uId){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Ошибка"),
              content: Text("Нельзя изменять роль у самого себя."),
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
        return;
      }
      final userPostsSnapshot = await _firestore.collection("posts").where("uid", isEqualTo: userId).get();

      if(newRole == 'adminRole' && userPostsSnapshot.docs.isNotEmpty){
        await _firestore.collection("posts").where("uid", isEqualTo: userId).get().then((snapshot) {
          snapshot.docs.forEach((doc) async {
            _firestore.collection("posts").doc(doc.id).delete();
          });
        });

        await _firestore.collection("favorites").where("uid", isEqualTo: userId).get().then((snapshot) {
          snapshot.docs.forEach((doc) async {
            _firestore.collection("favorites").doc(doc.id).delete();
          });
        });

        await FirebaseFirestore.instance
            .collection('posts')
            .where('likes', arrayContains: userId)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            FirebaseFirestore.instance.collection('posts').doc(doc.id).update({
              'likes': FieldValue.arrayRemove([userId])
            });
          });
        });

        await FirebaseFirestore.instance
            .collection('posts')
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            List<dynamic> comments = (doc.data()['comments'] ?? []) as List<dynamic>;
            comments.forEach((comment) {
              if (comment['uid'] == userId) {
                deleteComment(doc.id, comment['cid']);
              }
            });
          });
        });

        if (mounted) {
          setState(() {
            if (post.likes.contains(userId)) {
              post.likes.remove(userId);
            }
          });
        }

        await _firestore.collection("users").doc(userId).update({"role": newRole});
      }
      else if(newRole == 'adminRole'){
        await _firestore.collection("users").doc(userId).update(
            {"role": newRole});

        await FirebaseFirestore.instance
            .collection('posts')
            .where('likes', arrayContains: userId)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            FirebaseFirestore.instance.collection('posts').doc(doc.id).update({
              'likes': FieldValue.arrayRemove([userId])
            });
          });
        });

        await FirebaseFirestore.instance
            .collection('posts')
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            List<dynamic> comments = (doc.data()['comments'] ?? []) as List<dynamic>;
            comments.forEach((comment) {
              if (comment['uid'] == userId) {
                deleteComment(doc.id, comment['cid']);
              }
            });
          });
        });

        if (mounted) {
          setState(() {
            if (post.likes.contains(userId)) {
              post.likes.remove(userId);
            }
          });
        }


      }else await _firestore.collection("users").doc(userId).update(
          {"role": newRole});


      _fetchUsers();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Успешно изменено"),
            content: Text("Роль пользователя была успешно изменена."),
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

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                 Row(
                    children: [
                      Expanded(
                        child: CupertinoSearchTextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              filteredUsers = users.where((user) => user.name!.toLowerCase().contains(searchText.toLowerCase())).toList();
                            });
                          },
                          placeholder: 'Поиск по имени',
                        ),
                      ),
                      // CupertinoButton(
                      //   padding: EdgeInsets.zero,
                      //   child: Icon(CupertinoIcons.search, color: Color.fromRGBO(22, 31, 10, 1),),
                      //   onPressed: () {
                      //     setState(() {
                      //       filteredUsers = users.where((user) => user.name!.toLowerCase().contains(searchText.toLowerCase())).toList();
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                Row(
                  children: <Widget>[
                    Text('Фильтр: ', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1), fontWeight: FontWeight.bold)),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          filterRole = 'all';
                        });
                        _fetchUsers();
                      },
                      child: Text('Все', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1),  decoration: TextDecoration.underline)),
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          filterRole = 'userRole';
                        });
                        _fetchUsers();
                      },
                      child: Text('Юзеры', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1),  decoration: TextDecoration.underline)),
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),

                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          filterRole = 'adminRole';
                        });
                        _fetchUsers();
                      },
                      child: Text('Админы', style: TextStyle(color: Color.fromRGBO(22, 31, 10, 1),  decoration: TextDecoration.underline)),
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 40,
                    ),
                  ],
                ),
                Flexible(
                  child: filteredUsers.isEmpty
                      ? Center(child: Text("Список пуст", style: TextStyle(fontSize: 20)),)
                      : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                      UserModel user = filteredUsers[index];
                      Color? cardColor = user.role == 'adminRole' ? Color.fromRGBO(172, 193, 91, 1) : Colors.grey[300];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: cardColor!, width: 2.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.imageUrl!),
                              radius: 30,
                            ),
                            title: Text(user.name!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email!),
                                DropdownButton<String>(
                                  value: user.role,
                                  onChanged: (String? newValue) {
                                    _changeRole(user.uid!, newValue!);
                                  },
                                  items: <String>['userRole', 'adminRole'].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )

      );
    }

    Future<void> deleteComment(String postId, String commentId) async {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (snapshot.exists &&
            snapshot.data() is Map<String, dynamic> &&
            (snapshot.data() as Map<String, dynamic>).containsKey('comments')) {

          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          List<dynamic> comments = data['comments'] ?? [];

          comments.removeWhere((comment) => comment['cid'] == commentId);

          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
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
  }
