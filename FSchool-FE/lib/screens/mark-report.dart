import 'package:flutter/material.dart';

class MarkReportScreen extends StatefulWidget {
  const MarkReportScreen({super.key});

  @override
  State<MarkReportScreen> createState() => _MarkReportScreenState();
}

class _MarkReportScreenState extends State<MarkReportScreen> {
  String _selectedYear = '2025 - 2026';
  String _selectedSemester = 'Semester 1';

  final List<String> _years = ['2023 - 2024', '2024 - 2025', '2025 - 2026'];
  final List<String> _semesters = ['Semester 1', 'Semester 2', 'Summer'];

  // Dữ liệu điểm
  final List<Map<String, dynamic>> grades = [
    {'subject': 'Mathematics', 'score': 9.5, 'status': 'Passed'},
    {'subject': 'Literature', 'score': 8.0, 'status': 'Passed'},
    {'subject': 'Physics', 'score': 7.5, 'status': 'Passed'},
    {'subject': 'Chemistry', 'score': 6.5, 'status': 'Passed'},
    {'subject': 'History', 'score': 9.0, 'status': 'Passed'},
    {'subject': 'Physical Education', 'score': 4.0, 'status': 'Retake'},
  ];

  // --- HÀM TÍNH ĐIỂM TRUNG BÌNH ---
  double get _averageScore {
    if (grades.isEmpty) return 0.0;
    double sum = 0;
    for (var item in grades) {
      sum += (item['score'] as num).toDouble();
    }
    return sum / grades.length;
  }

  // --- HÀM XẾP LOẠI ---
  String get _academicRank {
    double avg = _averageScore;
    if (avg >= 9.0) return 'Excellent';
    if (avg >= 8.0) return 'Very Good';
    if (avg >= 6.5) return 'Good';
    if (avg >= 5.0) return 'Average';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Academic Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          },
        ),
      ),

      body: Column(
        children: [
          // 1. FILTER SECTION
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedYear,
                    items: _years,
                    label: "Scholastic",
                    onChanged: (val) => setState(() => _selectedYear = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedSemester,
                    items: _semesters,
                    label: "Semester",
                    onChanged: (val) =>
                        setState(() => _selectedSemester = val!),
                  ),
                ),
              ],
            ),
          ),

          // 2. AVERAGE SCORE CARD (Mới thêm)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Average Score",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _averageScore.toStringAsFixed(
                          1,
                        ), // Hiển thị 1 số thập phân
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 50, color: Colors.white24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Rank",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _academicRank,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Passed: ${grades.where((e) => e['status'] == 'Passed').length}/${grades.length}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. GRADE LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final item = grades[index];
                final bool isPassed = item['status'] == 'Passed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isPassed
                          ? Colors.green[50]
                          : Colors.red[50],
                      child: Icon(
                        isPassed ? Icons.check_circle : Icons.cancel,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      item['subject'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isPassed ? "Passed" : "Retake",
                      style: TextStyle(
                        color: isPassed ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        "${item['score']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isPassed ? Colors.black87 : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget cho Dropdown
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
