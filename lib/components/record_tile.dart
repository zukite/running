import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyRecordTile extends StatelessWidget {
  final String recordTime;
  final Timestamp timeStamp;

  const MyRecordTile({
    super.key,
    required this.recordTime,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = timeStamp.toDate();
    final formattedTimestamp = DateFormat('MM월 dd일 HH:mm').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Card(
        color: Colors.grey[50],
        elevation: 0.5,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                formattedTimestamp,
                style: TextStyle(
                  color: Colors.grey[850],
                ),
              ),
              Text(
                recordTime,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[850],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
