import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel{
  String? uid;
  String? desc;
  String? imageUrl;
  List<String>? tags;
  final time = Timestamp.now().toDate();
  List likes = [];
  List comments = [];

  // receiving data
  PostModel({ this.uid, this.desc,  this.imageUrl,  this.tags, time, likes, comments});

  factory PostModel.fromMap(map) {
    return PostModel(
      uid: map['uid'],
      desc: map['desc'],
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags']),
      time: map['time'].toDate(),
      likes: map['likes'],
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
      'time': Timestamp.fromDate(time),
      'likes': likes,
      'comments': comments,
    };
  }
}

const String POSTS_COLLECTION_REF = "posts";

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _postRef;

  DatabaseService(){
    _postRef = _firestore.collection(POSTS_COLLECTION_REF).withConverter<PostModel>(
        fromFirestore: (snapshots, _)=> PostModel.fromMap(snapshots.data()!,),
        toFirestore: (post, _) => post.toMap()
    );
  }

  Stream<QuerySnapshot> getPosts(){
    return _postRef.snapshots();
  }


  void addPost(PostModel post) async{
    _postRef.add(post);
  }

  void updatePost(String postId, PostModel post) async{
    _postRef.doc(postId).update(post.toMap());
  }

  void deletePost(String postId) async{
    _postRef.doc(postId).delete();
  }

  Future<void> addLike(String postId, String userId) async {
    await _postRef.doc(postId).update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> removeLike(String postId, String userId) async {
    await _postRef.doc(postId).update({
      'likes': FieldValue.arrayRemove([userId])
    });
  }
}