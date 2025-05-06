import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String message;
  final String user;
  final String postId;
  final String currentUserEmail;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.currentUserEmail,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user and optional 3-dot menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                Text(user, style: TextStyle(fontWeight: FontWeight.bold)),
                if (user == currentUserEmail)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') deletePost(context);
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete"),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Message body
            Text(message),
          ],
        ),
      ),
    );
  }
}
