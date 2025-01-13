import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageContainer extends StatelessWidget {
  final String? message;
  final String sender;
  final String? imageUrl;
  final Timestamp? timestamp;
  final String currentUserId;

  const MessageContainer({
    Key? key,
    required this.sender,
    this.message,
    this.imageUrl,
    this.timestamp,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSender = sender == currentUserId;

    // Format the timestamp
    String formattedTime = 'No timestamp';
    if (timestamp != null) {
      DateTime dateTime = timestamp!.toDate();
      formattedTime = DateFormat('h:mm a').format(dateTime);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender)
            SizedBox(width: 40), // Space for padding on the left for receiver
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSender ? Colors.deepPurpleAccent : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: isSender ? Radius.circular(10) : Radius.zero,
                bottomRight: isSender ? Radius.zero : Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Image.network(
                    imageUrl!,
                    width: 250, // Adjust width as needed
                    height: 250, // Adjust height as needed
                    fit: BoxFit.cover,
                  )
                else if (message != null)
                  Text(
                    message!,
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: isSender ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isSender)
            SizedBox(width: 40), // Space for padding on the right for sender
        ],
      ),
    );
  }
}
