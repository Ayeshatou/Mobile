import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookName;

  BookDetailScreen({required this.bookName});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _reviewController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> addReview() async {
    if (_reviewController.text.isNotEmpty) {
      await _firestore.collection('reviews').add({
        'bookName': widget.bookName,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _reviewController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Review added!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('reviews')
                  .where('bookName', isEqualTo: widget.bookName)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final reviews = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(reviews[index]['review']),
                      subtitle: Text('User Review'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: 'Write a review...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: addReview,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
