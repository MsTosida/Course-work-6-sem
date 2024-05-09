import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Для форматирования даты

class CommentCard extends StatelessWidget {
  final String? userName; // Имя пользователя
  final String? userPhotoUrl; // URL фото пользователя
  final String? commentText; // Текст комментария
  final DateTime commentTime; // Время добавления комментария

  CommentCard({
    required this.userName,
    required this.userPhotoUrl,
    required this.commentText,
    required this.commentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(userPhotoUrl!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userName!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              commentText!,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd.MM.yyyy').format(commentTime),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
