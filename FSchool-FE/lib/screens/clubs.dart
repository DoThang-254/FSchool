import 'package:bai1/screens/clubs-details.dart';
import 'package:flutter/material.dart';

class ClubsScreen extends StatelessWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final List<Map<String, dynamic>> clubs = [
      {
        'name': 'Coding Club',
        'category': 'Academic',
        'members': 45,
        'image': 'https://picsum.photos/id/5/200/200',
        'description':
            'For students who love programming, algorithms, and building software.',
      },
      {
        'name': 'Basketball Team',
        'category': 'Sports',
        'members': 20,
        'image': 'https://picsum.photos/id/9/200/200',
        'description':
            'Join the school basketball team. We practice every Tuesday and Thursday.',
      },
      {
        'name': 'Art & Design',
        'category': 'Arts',
        'members': 30,
        'image': 'https://picsum.photos/id/10/200/200',
        'description':
            'Unleash your creativity with painting, sketching, and digital art.',
      },
      {
        'name': 'Music Club',
        'category': 'Arts',
        'members': 50,
        'image': 'https://picsum.photos/id/12/200/200',
        'description': 'Choir, band, and instrument learning for everyone.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Clubs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          childAspectRatio: 0.8, // Tỷ lệ khung hình (cao hơn rộng)
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailScreen(club: club),
                ),
              );
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo tròn
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(club['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  ),
                  Text(
                    club['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club['category'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
