import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linkable/linkable.dart';
import 'package:intl/intl.dart';

class Message extends StatefulWidget {
  final message;
  final user;

  Message({required this.message, required this.user});

  @override
  MessageFormat createState() => MessageFormat(
        message: message["text"],
        textColor:
            user["userId"] == message["senderId"] ? Colors.white : Colors.black,
        bgColor: user["userId"] == message["senderId"]
            ? Colors.deepPurpleAccent.shade400
            : Colors.white,
        aligment: user["userId"] == message["senderId"]
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        from:
            user["userId"] == message["senderId"] ? "" : message["senderName"],
        timeStamp: message["timeStamp"],
      );
}

class MessageFormat extends State<Message> {
  MessageFormat({
    required this.message,
    required this.textColor,
    required this.bgColor,
    required this.aligment,
    required this.from,
    required this.timeStamp,
  });

  final String message;
  final Color textColor;
  final Color bgColor;
  final CrossAxisAlignment aligment;
  final String from;
  var timeStamp;
  var dateTime;
  String time = '';

  @override
  Widget build(BuildContext context) {
    setState(() {
      dateTime = timeStamp.toDate();
      time = DateFormat("dd-MM-yyyy kk:mm").format(dateTime);
    });
    double textSize = max(max(message.length, from.length), 12) * 8.0 + 24.0;
    return Column(
      crossAxisAlignment: aligment,
      children: [
        Container(
          width: textSize,
          constraints: BoxConstraints(
            minWidth: 30.0,
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: EdgeInsets.all(7),
          margin: EdgeInsets.only(
            bottom: 10,
            right: 10,
            left: 10,
          ),
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              from.length == 0
                  ? Container()
                  : Container(
                      width: textSize,
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        from,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
              Container(
                alignment: Alignment.centerLeft,
                child: Linkable(
                  text: message,
                  textColor: textColor,
                  linkColor: Colors.yellowAccent[400],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: textSize,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
