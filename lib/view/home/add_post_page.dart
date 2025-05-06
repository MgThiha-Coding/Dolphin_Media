import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolphin/core/image/app_Image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController postController = TextEditingController();

  void postMessage() async {
    if (postController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('User Posts').add({
        "UserEmail": currentUser.email,
        "Message": postController.text.trim(),
        "TimeStamp": Timestamp.now(),
      });

      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: postMessage,
              child: Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
        title: Row(
          children: [
            Image.asset(AppImage.logo, scale: 15),
            const SizedBox(width: 10),
            Text('Dolphin'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: postController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: "Write down your thought...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
