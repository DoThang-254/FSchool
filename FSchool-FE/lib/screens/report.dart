import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Cập nhật dữ liệu giả lập cho khớp với wireframe
    // Thêm trường 'title' (loại đơn) và 'duration' (thời gian nghỉ)
    final List<Map<String, String>> history = [
      {
        'title': 'Request for Absent',
        'duration': '1 Day',
        'date': '12/02/2026',
        'status': 'Approved',
      },
      {
        'title': 'Request for Long Absent',
        'duration': '3 Days',
        'date': '10/02/2026',
        'status': 'Rejected',
      },
      {
        'title': 'Request for Absent',
        'duration': '1 Day',
        'date': '02/02/2026',
        'status': 'Pending',
      },
      {
        'title': 'Request for Absent',
        'duration': '1 Day',
        'date': '02/02/2026',
        'status': 'Pending',
      },
    ];

    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Nền xám nhẹ làm nổi bật các Card trắng
      appBar: AppBar(
        title: const Text(
          'My Requests', // Đổi tên cho thân thiện hơn
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return _buildReportCard(item);
        },
      ),
      // Nút tạo đơn mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.pushNamed(context, '/create-report');
        },
      ),
    );
  }

  // 2. Widget Card được thiết kế riêng (Custom Widget)
  Widget _buildReportCard(Map<String, String> item) {
    // Xác định màu sắc dựa trên trạng thái
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.access_time_filled; // Pending icon

    if (item['status'] == 'Approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (item['status'] == 'Rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
        border: Border.all(color: Colors.grey.shade200), // Viền mỏng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng 1: Icon tài liệu + Tiêu đề + Trạng thái
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge trạng thái nhỏ gọn
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            item['status']!,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),

          // Hàng 2: Thông tin chi tiết (Time, Created Date)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Time", item['duration']!),
              _buildInfoColumn("Created Date", item['date']!),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con hiển thị cột thông tin nhỏ
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
