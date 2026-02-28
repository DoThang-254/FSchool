import 'package:flutter/material.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // 0: Request for Absent, 1: Request for Long Absent
  int _selectedRequestType = 0;

  // Quản lý ngày tháng
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();

  // Quản lý Checkbox "Select All"
  bool _isSelectAll = false;

  // Dữ liệu giả lập các tiết học (Slots)
  final List<Map<String, dynamic>> _slots = [
    {
      'id': 1,
      'name': 'Slot 1 : Math',
      'time': '7h30 - 9h30',
      'room': 'BE-333',
      'isSelected': false,
    },
    {
      'id': 2,
      'name': 'Slot 2 : English',
      'time': '9h45 - 11h45',
      'room': 'BE-333',
      'isSelected': false,
    },
  ];

  // --- LOGIC FUNCTIONS ---

  // Hàm chọn ngày
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // Hàm xử lý "Select All"
  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      for (var slot in _slots) {
        slot['isSelected'] = _isSelectAll;
      }
    });
  }

  // Hàm xử lý chọn từng slot
  void _toggleSlot(int index, bool? value) {
    setState(() {
      _slots[index]['isSelected'] = value ?? false;
      // Kiểm tra xem có phải tất cả đều được chọn không để update nút "Select All"
      _isSelectAll = _slots.every((slot) => slot['isSelected'] == true);
    });
  }

  // Hàm Reset form
  void _resetForm() {
    setState(() {
      _reasonController.clear();
      _isSelectAll = false;
      for (var slot in _slots) {
        slot['isSelected'] = false;
      }
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      _selectedRequestType = 0;
    });
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày hiển thị (DD/MM/YYYY)
    String formattedFrom =
        "${_fromDate.day}/${_fromDate.month}/${_fromDate.year}";
    String formattedTo = "${_toDate.day}/${_toDate.month}/${_toDate.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Report',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. REQUEST TYPE SELECTION (2 ô vuông to)
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    index: 0,
                    icon: Icons.edit_document,
                    label: "Request for Absent",
                    isSelected: _selectedRequestType == 0,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTypeCard(
                    index: 1,
                    icon: Icons.plagiarism_outlined, // Icon tìm kiếm tài liệu
                    label: "Request for Long Absent", // Sửa text theo ảnh
                    isSelected: _selectedRequestType == 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. DATE PICKERS (From - To)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedFrom),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedTo),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. LESSON OF THE DAY & SELECT ALL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lesson Of The Day",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isSelectAll,
                      activeColor: Colors.orange,
                      onChanged: _toggleSelectAll,
                    ),
                    const Text("Select All Slot"),
                  ],
                ),
              ],
            ),

            // 4. LIST OF SLOTS
            ..._slots.asMap().entries.map((entry) {
              int idx = entry.key;
              Map slot = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: slot['name'].split(':')[0] + " : ",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: slot['name'].split(':')[1],
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        slot['time'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Room : ",
                            style: TextStyle(color: Colors.black87),
                          ),
                          Text(
                            slot['room'],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: slot['isSelected'],
                    activeColor: Colors.orange,
                    onChanged: (val) => _toggleSlot(idx, val),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 10),

            // 5. REASON INPUT
            const Text(
              "Reason",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type here",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 6. BUTTONS (SEND & RESET)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Report Sent!")),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400], // Màu nền theo ảnh
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget con để vẽ ô chọn loại Request (Hình vuông to)
  Widget _buildTypeCard({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRequestType = index;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: Colors.black87),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox nhỏ ở góc phải trên
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.orange)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
