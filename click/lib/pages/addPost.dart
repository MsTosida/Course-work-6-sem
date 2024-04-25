import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostPage extends StatefulWidget {
  final String id;

  AddPostPage({Key? key, required this.id}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  List<String> _tags = [];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _savePost() {
    if (_titleController.text.isNotEmpty && _tags.isNotEmpty) {
      FirebaseFirestore.instance.collection('posts').add({
        'id': widget.id,
        'title': _titleController.text,
        'tags': _tags,
        // Добавьте поле для изображения, если вы хотите сохранить его в Firebase
        // 'image': _image?.path,
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(labelText: 'Теги'),
              onChanged: (value) {
                if (value.endsWith(' ')) {
                  _addTag(value.trim());
                  _tagsController.clear();
                }
              },
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Выбрать фото'),
            ),
            if (_image != null)
              Image.file(File(_image!.path)),
            ElevatedButton(
              onPressed: _savePost,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
