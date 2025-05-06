import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolphin/core/image/app_Image.dart';
import 'package:dolphin/view/home/add_post_page.dart';
import 'package:dolphin/view/home/post.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 3),
                          Text(
                            currentUser.email!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Are you sure to Log out?',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            signOut();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CircleAvatar(
                child: Icon(Icons.person_outline, color: Colors.blue),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPostPage()),
                    );
                  },
                  icon: CircleAvatar(child: Icon(Icons.add_outlined)),
                ),
                hintText: "What's on your mind?",

                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('User Posts')
                        .orderBy('TimeStamp', descending: false)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return Card(
                          child: Post(
                            message: post['Message'],
                            user: post['UserEmail'],
                            postId: post.id,
                            currentUserEmail: currentUser.email!,
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error ${snapshot.error}');
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
