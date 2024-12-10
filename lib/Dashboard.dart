import 'dart:math';
import 'package:flutter/material.dart';
import 'package:internship_task/UploadDocument.dart'; // Import your UploadDocumentsScreen file

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate random image URLs
    final List<String> storyImages = List.generate(
        10, (index) => 'https://picsum.photos/100?random=$index'); // Stories
    final List<String> postImages = List.generate(
        10, (index) => 'https://picsum.photos/500?random=${index + 10}'); // Posts

    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 188, 111, 10),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(217, 188, 111, 10),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Dashboard'),
        ),
        centerTitle: false, // Ensures the title stays on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the UploadDocumentsScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadDocumentsScreen(),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Stories Section
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: storyImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(storyImages[index]),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Story ${index + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Posts Section
          Expanded(
            child: ListView.builder(
              itemCount: postImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          postImages[index],
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Post Caption
                      Text(
                        'Post ${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Randomly generated post description ${Random().nextInt(100)}',
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
