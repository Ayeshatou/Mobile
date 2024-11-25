import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> books = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchBooks(String query) async {
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=AIzaSyBtdD9tJRL-D5JgoTD2EqOwPxOuYOrNUWI';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        books = data['items'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching books')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search books...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: fetchBooks,
            ),
            SizedBox(height: 10),
            Expanded(
              child: books.isEmpty
                  ? Center(child: Text('Search for books to get started'))
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index]['volumeInfo'];
                        return Card(
                          child: ListTile(
                            leading: book['imageLinks'] != null
                                ? Image.network(book['imageLinks']['thumbnail'])
                                : Icon(Icons.book),
                            title: Text(book['title'] ?? 'No Title'),
                            subtitle: Text(book['authors']?.join(', ') ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailScreen(
                                      bookName: book['title'] ?? 'No Title'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
