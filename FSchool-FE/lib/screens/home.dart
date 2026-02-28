import 'package:flutter/material.dart';

final List<Map<String, dynamic>> menuItems = [
  {'icon': Icons.assignment, 'label': 'Mark Report', 'route': '/mark-report'},
  {'icon': Icons.check_circle_outline, 'label': 'Report', 'route': '/report'},
  {'icon': Icons.calendar_today, 'label': 'Schedule', 'route': '/schedule'},
  {'icon': Icons.newspaper, 'label': 'Events', 'route': '/events'},
  {'icon': Icons.people, 'label': 'Clubs', 'route': '/clubs'},
  {'icon': Icons.computer, 'label': 'E-Learn', 'route': null},
  {'icon': Icons.phone, 'label': 'Contact', 'route': null},
  {'icon': Icons.bed, 'label': 'Dorm', 'route': null},
];

final List<Map<String, dynamic>> newsItems = [
  {
    "title": "News1",
    "content": "flower1",
    "image":
        "https://www.foxroad.co.nz/cdn/shop/articles/flowers-nature-pictures_900x.jpg?v=1725492833",
  },
  {
    "title": "News2",
    "content": "flower1",
    "image":
        "https://www.gardenia.net/wp-content/uploads/2023/05/freesia-780x520.webp",
  },
  {
    "title": "News3",
    "content": "flower1",
    "image":
        "https://hips.hearstapps.com/hmg-prod/images/sacred-lotus-gettyimages-1143403162-646fa5a441f5d.jpg?crop=0.535xw:1.00xh;0.0519xw,0",
  },
];

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.account_circle),
                  Icon(Icons.notifications),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Đỗ Quang Thắng",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "Class: 12A1 - Roll Number: "),
                      TextSpan(
                        text: "FS123456",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(menuItems.length, (index) {
                  final item = menuItems[index];

                  return GestureDetector(
                    onTap: () {
                      if (item['route'] != null) {
                        Navigator.pushNamed(context, item['route']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Feature not implemented yet'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Icon(
                              item["icon"],
                              size: 28,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              item["label"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsItems.length,
                itemBuilder: (context, index) {
                  final item = newsItems[index];

                  return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item["image"],
                                    width: 1000,
                                    height: 500,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  item["title"]!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item["content"]!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
