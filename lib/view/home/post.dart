import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolphin/core/image/app_Image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the timestamp

class Post extends StatelessWidget {
  final String message;
  final String user;
  final String postId;
  final String currentUserEmail;
  final String? imageUrl;
  final Timestamp? time;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.currentUserEmail,
    this.imageUrl,
    this.time,
  });

  void deletePost(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(postId)
          .delete();
    }
  }

  // Method to format Timestamp to a readable string
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy.MM.dd (HH:mm:ss)').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user and optional 3-dot menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        AppImage.logo,
                        fit: BoxFit.cover,
                        scale: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(user, style: TextStyle(color: Colors.white)),
                    // Format the timestamp
                    if (user == currentUserEmail)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'delete') deletePost(context);
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              PopupMenuItem(
                                height: 10,
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  time != null ? formatTimestamp(time!) : '',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 10),
            // Message body
            Text('$message', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            // Display the image if imageUrl is available
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(imageUrl!, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
