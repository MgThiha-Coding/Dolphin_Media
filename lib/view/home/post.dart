import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolphin/core/image/app_Image.dart';
import 'package:dolphin/view/components/comment.dart';
import 'package:dolphin/view/components/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting the timestamp

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String currentUserEmail;
  final String? imageUrl;
  final Timestamp? time;
  final List<String> likes;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.currentUserEmail,
    this.imageUrl,
    this.time,
    required this.likes,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late TextEditingController commentTextController = TextEditingController();

  // Method to format Timestamp to a readable string
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return ' Just now';
    if (diff.inMinutes < 60) return ' ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return ' ${diff.inHours}h ago';
    if (diff.inDays < 7) return ' ${diff.inDays}d ago';
    if (diff.inDays < 30) return DateFormat('MMM d').format(dateTime); // Apr 28
    return DateFormat('y MMM d').format(dateTime); // 2025 Apr 28
  }

  // get the current user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef = FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  Future<void> addComment(String commentText) async {
    try {
      await FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postId)
          .collection("Comments")
          .add({
            "CommentText": commentText,
            "CommentBy": currentUser.email,
            "CommentTime": Timestamp.now(),
          });
    } catch (e) {
      print("🔥 Failed to add comment: $e");
    }
  }

  // Show the comment drop-up modal
  void showCommentDropUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF2C5364),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFF2C5364),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Text(
                    "Add Comment",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentTextController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write something nice...",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xFF2C5364),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      commentTextController.clear();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (commentTextController.text.trim().isNotEmpty) {
                        addComment(commentTextController.text.trim());
                      }
                      Navigator.pop(context);
                      commentTextController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete the post
  void deletePost(BuildContext context) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Deletion"),
            content: Text("Are you sure you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // User canceled
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // User confirmed
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Delete the post from Firestore
        await FirebaseFirestore.instance
            .collection("User Posts")
            .doc(widget.postId)
            .delete();
        // Optionally, you can also delete the post's associated comments
        // await FirebaseFirestore.instance
        //     .collection("User Posts")
        //     .doc(widget.postId)
        //     .collection("Comments")
        //     .get()
        //     .then((snapshot) {
        //   for (var doc in snapshot.docs) {
        //     doc.reference.delete();
        //   }
        // });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Post deleted successfully")));
      }
    } catch (e) {
      print("🔥 Error deleting post: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete post")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                    const SizedBox(width: 2),
                    Text(widget.user, style: TextStyle(color: Colors.white)),
                    // Format the timestamp
                    if (widget.user == widget.currentUserEmail)
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
                    const SizedBox(width: 2),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6), // spacing between dot and time
                    Text(
                      widget.time != null ? formatTimestamp(widget.time!) : '',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 10),
            // Message body
            Text('${widget.message}', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            // Display the image if imageUrl is available
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Image.network(widget.imageUrl!, fit: BoxFit.cover),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          widget.likes.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      LikeButton(
                        isLiked: isLiked,
                        onTap: () {
                          setState(() {
                            toggleLike();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showCommentDropUp();
                  },
                  child: Text(
                    'Write a comment..',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            // Comments Stream
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .orderBy("CommentTime", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ExpansionTile(
                  title: Row(
                    children: [
                      Text("Comments", style: TextStyle(color: Colors.amber)),
                    ],
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children:
                          snapshot.data!.docs.map((doc) {
                            final commentData = doc.data();
                            final commentId = doc.id;
                            final commentBy = commentData["CommentBy"];

                            return ListTile(
                              title: Comment(
                                text: commentData["CommentText"],
                                user: commentData["CommentBy"],
                                time: formatTimestamp(
                                  commentData["CommentTime"],
                                ),
                                commentBy: commentBy,
                                currentUserEmail: currentUser.email!,
                                commentId: commentId,
                                postId: widget.postId,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                );
              },
            ),
            // Display who liked the post
            ExpansionTile(
              title: Row(
                children: [
                  Text("Reactions", style: TextStyle(color: Colors.amber)),
                ],
              ),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              children:
                  widget.likes.isNotEmpty
                      ? widget.likes
                          .map(
                            (likedUser) => ListTile(
                              title: Text(
                                likedUser,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList()
                      : [
                        ListTile(
                          title: Text(
                            "No reactions yet.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
            ),
          ],
        ),
      ),
    );
  }
}
