import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostModel{
  String? uid;
  String? desc;
  String? imageUrl;
  List<String>? tags;
  List likes = [];
  final time = Timestamp.now().toDate();
  List comments = [];

  // receiving data
  PostModel({ this.uid, this.desc,  this.imageUrl,  this.tags, likes, time, comments});

  factory PostModel.fromMap(map) {
    return PostModel(
      uid: map['uid'],
      desc: map['desc'],
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags']),
      likes: map['likes'],
      time: map['time'].toDate(),
      comments: List.from(map['comments']),
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'desc': desc,
      'imageUrl': imageUrl,
      'tags': tags,
      'likes': likes,
      'time': Timestamp.fromDate(time),
      'comments': comments,
    };
  }
}

class FavModel{
  String? uid;
  String? pid;

  // receiving data
  FavModel({ this.uid, this.pid});

  factory FavModel.fromMap(map) {
    return FavModel(
      uid: map['uid'],
      pid: map['pid'],
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pid': pid,
    };
  }
}
const String POSTS_COLLECTION_REF = "posts";
const String FAVORITES_COLLECTION_REF = "favorites";

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _postRef;
  late final CollectionReference _favRef;

  DatabaseService(){
    _postRef = _firestore.collection(POSTS_COLLECTION_REF).withConverter<PostModel>(
        fromFirestore: (snapshots, _)=> PostModel.fromMap(snapshots.data()!,),
        toFirestore: (post, _) => post.toMap()
    );

    _favRef = _firestore.collection(FAVORITES_COLLECTION_REF).withConverter<FavModel>(
        fromFirestore: (snapshots, _)=> FavModel.fromMap(snapshots.data()!,),
        toFirestore: (post, _) => post.toMap()
    );

  }

  Stream<QuerySnapshot> getPosts(){
    return _postRef.snapshots();
  }

  void addPost(PostModel post) async{
    _postRef.add(post);
  }

  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    await _postRef.doc(postId).update(updates);
  }

  void deletePost(String postId) async{
    final querySnapshot = await _favRef.where('pid', isEqualTo: postId).get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    _postRef.doc(postId).delete();
  }

  //***************************************************************************

  Future<List<String>> getFavPostIds() async {
    final querySnapshot = await _favRef.where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get();
    return querySnapshot.docs.map((doc) => doc['pid'].toString()).toList();
  }

  Stream<QuerySnapshot> getPostsFav() async* {
    final favPostIds = await getFavPostIds();
    yield* _postRef.where(FieldPath.documentId, whereIn: favPostIds).snapshots();
  }


  void addPostFav(String postId) async{
    FavModel post = FavModel(
      uid: FirebaseAuth.instance.currentUser?.uid,
      pid: postId,
       );

    _favRef.add(post);
  }

  Future<void> deletePostFav(String pid) async {
    final querySnapshot = await _favRef.where('pid', isEqualTo: pid).get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }


}