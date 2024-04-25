class PostModel{
  String? uid;
  String? pid;
  String? title;
  String? imageUrl;
  final List<String> tags;

  // receiving data
  PostModel({required this.uid, required this.pid, required this.title, required this.imageUrl, required this.tags});

  factory PostModel.fromMap(map) {
    return PostModel(
      uid: map['uid'],
      pid: map['pid'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      tags: map['tags'],
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pid': pid,
      'title': title,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }
}