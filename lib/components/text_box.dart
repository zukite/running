import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Color.fromRGBO(79, 111, 82, 1.0), // 원하는 테두리 색상으로 변경
          ),
        ),
        padding: const EdgeInsets.only(
          left: 15,
          bottom: 5,
          top: 5,
        ),
        margin: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.grey[850]),
            ),
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.edit,
                color: Colors.grey[600],
              ),
            ),
          ],
        ));
  }
}
