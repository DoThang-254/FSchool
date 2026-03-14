import 'package:flutter/material.dart';
import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:bai1/models/schedule.dart';
import 'package:bai1/controllers/schedule_controller.dart';
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Ngày đang chọn (Mặc định là hôm nay)
  DateTime _selectedDate = DateTime.now();

  // Danh sách các ngày trong tuần (Giả lập tuần hiện tại)
  late List<DateTime> _weekDays;

  final ScheduleController _controller = ScheduleController();
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  int? _classId;
  int? _staffId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is int) {
      _classId = args;
    } else if (args != null) {
      // Assuming args is something that has classId or staffId (dynamic or AuthResponse)
      try {
        _classId = (args as dynamic).classId;
        _staffId = (args as dynamic).staffId;
      } catch (e) {
        debugPrint("ScheduleScreen: Error parsing arguments: $e");
      }
    }
    
    debugPrint("ScheduleScreen: Fetching for classId: $_classId, staffId: $_staffId");
    _fetchSchedules();
  }

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  Future<void> _fetchSchedules() async {
    final schedules = await _controller.fetchSchedules(
      classId: _classId,
      staffId: _staffId,
    );
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  // Hàm tạo danh sách 7 ngày trong tuần hiện tại
  void _generateWeekDays() {
    DateTime now = DateTime.now();
    // Tìm ngày thứ 2 đầu tuần (Monday = 1)
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    _weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  // Filter data from backend for _selectedDate
  List<Schedule> _getClassesForDay(DateTime date) {
    return _schedules.where((schedule) {
      if (schedule.date.isEmpty) return false;
      try {
        DateTime parsedDate = DateTime.parse(schedule.date);
        return parsedDate.year == date.year &&
               parsedDate.month == date.month &&
               parsedDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách môn học theo ngày đang chọn
    List<Schedule> classes = _getClassesForDay(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          // 1. WEEKLY CALENDAR STRIP (Thanh chọn ngày)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  DateTime date = _weekDays[index];
                  bool isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month;

                  // Mảng tên thứ viết tắt
                  List<String> days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.shade200,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. CLASS LIST (Danh sách tiết học)
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No classes today",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return _buildClassCard(classes[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: -1,
        args: ModalRoute.of(context)?.settings.arguments,
      ),
    );
  }

  // Widget hiển thị từng tiết học
  Widget _buildClassCard(Schedule classInfo) {
    Color statusColor = Colors.grey;
    Color cardBg = Colors.white;

    // Logic màu sắc dựa trên trạng thái
    if (classInfo.status == 'Happening') {
      statusColor = Colors.green;
      cardBg = Colors.white; // Hoặc màu cam nhạt nếu muốn nổi bật
    } else if (classInfo.status == 'Upcoming') {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột giờ bên trái
          Column(
            children: [
              Text(
                classInfo.time.split(' - ').first, // Giờ bắt đầu
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                classInfo.time.split(' - ').length > 1 ? classInfo.time.split(' - ')[1] : '', // Giờ kết thúc
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Đường kẻ dọc (Timeline)
          Container(
            width: 2,
            height: 100,
            color: Colors.orange.withOpacity(0.3),
            margin: const EdgeInsets.only(top: 5),
          ),

          const SizedBox(width: 15),

          // Thẻ thông tin bên phải
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: classInfo.status == 'Happening'
                    ? Border.all(color: Colors.green, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        classInfo.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Chấm trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          classInfo.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.room, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "Room: ${classInfo.room}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        classInfo.teacher,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
