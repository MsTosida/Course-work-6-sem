import 'package:flutter/material.dart';

class CustomAlertDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Color.fromRGBO(22, 31, 10, 1),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}