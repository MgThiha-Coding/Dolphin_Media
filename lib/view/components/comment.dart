import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  final String commentBy;
  final String currentUserEmail;
  final String commentId;
  final String postId; // ✅ Add postId

  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.commentBy,
    required this.currentUserEmail,
    required this.commentId,
    required this.postId,
  });

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return DateFormat('MMM d').format(dateTime);
    return DateFormat('y MMM d').format(dateTime);
  }

  Future<void> deleteComment() async {
    try {
      await FirebaseFirestore.instance
          .collection("User Posts")
          .doc(postId) // ✅ Correct post
          .collection("Comments")
          .doc(commentId) // ✅ Correct comment
          .delete();
    } catch (e) {
      print("❌ Failed to delete comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C5364),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user,
            style: GoogleFonts.podkova(color: Colors.white, fontSize: 12),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const Spacer(),
              if (commentBy == currentUserEmail)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 18,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      deleteComment();
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem(
                          height: 8,
                          value: 'delete',
                          child: Row(
                            children: [
                              Text(
                                "Delete Comment",
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
            ],
          ),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
