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
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
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
              style: TextStyle(color: Colors.grey[800]),
            ),
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.edit,
                color: Colors.grey[800],
              ),
            ),
          ],
        ));
  }
}
