import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import '../services/class_service.dart';
import '../services/subject_service.dart';
import '../services/room_service.dart';
import '../services/staff_service.dart';
import '../services/slot_service.dart';
import '../models/schedule.dart' as model;
import 'package:intl/intl.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final ClassService _classService = ClassService();
  final SubjectService _subjectService = SubjectService();
  final RoomService _roomService = RoomService();
  final StaffService _staffService = StaffService();
  final SlotService _slotService = SlotService();

  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  List<model.Schedule> _schedules = [];
  bool _isLoading = false;

  // Tuần hiện tại đang hiển thị
  DateTime _focusedDate = DateTime.now();
  late DateTime _weekStart;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _setWeek(DateTime.now());
    _loadInitialData();
  }

  void _setWeek(DateTime date) {
    _weekStart = date.subtract(Duration(days: date.weekday - 1));
    _weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    _focusedDate = date;
  }

  void _changeWeek(int delta) {
    setState(() {
      _setWeek(_weekStart.add(Duration(days: delta * 7)));
    });
    _loadSchedules();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _classService.getClasses();
      setState(() {
        _classes = List<Map<String, dynamic>>.from(classes);
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchedules() async {
    if (_selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await _scheduleService.getSchedulesByDateRange(
        classId: _selectedClass!['id'],
        fromDate: _weekDays.first,
        toDate: _weekDays.last,
      );
      setState(() {
        _schedules = result['schedules'] as List<model.Schedule>;
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Schedule Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() => _setWeek(DateTime.now()));
              _loadSchedules();
            },
            tooltip: "This Week",
          )
        ],
      ),
      body: Column(
        children: [
          _buildClassSelector(),
          _buildWeekNavigator(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedClass == null
                    ? _buildEmptyState("Please select a class to manage schedule")
                    : _buildScheduleList(),
          ),
        ],
      ),
      floatingActionButton: _selectedClass != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: "add_single",
                  onPressed: _showAddSingleScheduleDialog,
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: "add_batch",
                  onPressed: _showBatchScheduleDialog,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Batch Schedule"),
                  backgroundColor: Colors.orange,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator() {
    final df = DateFormat('dd/MM');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeWeek(-1),
          ),
          Text(
            "${df.format(_weekDays.first)} - ${df.format(_weekDays.last)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedClass,
        decoration: InputDecoration(
          labelText: "Select Class",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.class_outlined),
        ),
        items: _classes.map((c) {
          return DropdownMenuItem(
            value: c,
            child: Text(c['className']),
          );
        }).toList(),
        onChanged: (val) {
          setState(() => _selectedClass = val);
          _loadSchedules();
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return _buildEmptyState("No classes scheduled for this week");
    }

    // Group schedules by day
    Map<String, List<model.Schedule>> grouped = {};
    for (var s in _schedules) {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(s.date));
      grouped.putIfAbsent(dateStr, () => []).add(s);
    }

    // Sort dates
    var sortedDates = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final daySchedules = grouped[dateStr]!;
        final date = DateTime.parse(dateStr);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_getDayName(date.weekday)}, ${DateFormat('dd/MM/yyyy').format(date)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            ...daySchedules.map((s) => _buildScheduleCard(s)).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteSchedule(model.Schedule s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete session for ${s.subject} on ${DateFormat('dd/MM').format(DateTime.parse(s.date))}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && s.id != null) {
      setState(() => _isLoading = true);
      try {
        await _scheduleService.deleteSchedule(s.id!);
        _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session deleted")));
        }
      } catch (e) {
        _showError(e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  String _getDayName(int weekday) {
    const names = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[weekday % 8 == 0 ? 7 : weekday];
  }

  Widget _buildScheduleCard(model.Schedule s) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.time.split(' - ').first,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
                    Text(
                      s.time.split(' - ').last,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 24, thickness: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                        ),
                        _buildStatusBadge(s.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.room_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s.room, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s.teacher, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                onPressed: () => _showEditScheduleDialog(s),
                tooltip: "Edit",
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmDeleteSchedule(s),
                tooltip: "Delete",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Happening') color = Colors.green;
    else if (status == 'Upcoming') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddSingleScheduleDialog() async {
    final subjects = await _subjectService.getSubjects();
    final rooms = await _roomService.getRooms();
    final staffs = await _staffService.getStaffs();
    final slots = await _slotService.getSlots();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _AddSingleScheduleDialog(
        subjects: subjects,
        rooms: rooms,
        staffs: staffs,
        slots: slots,
        classId: _selectedClass!['id'],
        initialDate: _focusedDate,
        onSuccess: () {
          _loadSchedules();
        },
      ),
    );
  }

  void _showEditScheduleDialog(model.Schedule schedule) async {
    setState(() => _isLoading = true);
    try {
      final subjects = await _subjectService.getSubjects();
      final rooms = await _roomService.getRooms();
      final staffs = await _staffService.getStaffs();
      final slots = await _slotService.getSlots();

      setState(() => _isLoading = false);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _AddSingleScheduleDialog(
          subjects: subjects,
          rooms: rooms,
          staffs: staffs,
          slots: slots,
          classId: _selectedClass!['id'],
          initialDate: DateTime.parse(schedule.date),
          editSchedule: schedule,
          onSuccess: () {
            _loadSchedules();
          },
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showBatchScheduleDialog() async {
    final subjects = await _subjectService.getSubjects();
    final rooms = await _roomService.getRooms();
    final staffs = await _staffService.getStaffs();
    final slots = await _slotService.getSlots();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BatchScheduleWizard(
        subjects: subjects,
        rooms: rooms,
        staffs: staffs,
        slots: slots,
        classId: _selectedClass!['id'],
        onSuccess: () {
          Navigator.pop(context);
          _loadSchedules();
        },
      ),
    );
  }
}

class _AddSingleScheduleDialog extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> staffs;
  final List<Map<String, dynamic>> slots;
  final int classId;
  final DateTime initialDate;
  final VoidCallback onSuccess;
  final model.Schedule? editSchedule;

  const _AddSingleScheduleDialog({
    required this.subjects,
    required this.rooms,
    required this.staffs,
    required this.slots,
    required this.classId,
    required this.initialDate,
    required this.onSuccess,
    this.editSchedule,
  });

  bool get isEditing => editSchedule != null;

  @override
  State<_AddSingleScheduleDialog> createState() => _AddSingleScheduleDialogState();
}

class _AddSingleScheduleDialogState extends State<_AddSingleScheduleDialog> {
  int? _selectedSubject;
  int? _selectedRoom;
  int? _selectedStaff;
  int? _selectedSlot;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    if (widget.isEditing) {
      final s = widget.editSchedule!;
      // Look up IDs from names
      _selectedSubject = _findId(widget.subjects, 'subjectName', s.subject);
      _selectedRoom = _findId(widget.rooms, 'roomName', s.room);
      _selectedStaff = _findId(widget.staffs, 'fullName', s.teacher);
      _selectedSlot = s.slotId;
    }
  }

  int? _findId(List<Map<String, dynamic>> list, String nameKey, String nameValue) {
    try {
      return list.firstWhere((item) => item[nameKey] == nameValue)['id'] as int;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? "Edit Session" : "Add Single Session",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Date"),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: () async {
                final res = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (res != null) setState(() => _selectedDate = res);
              },
            ),
            _buildDropdown("Môn học", widget.subjects, "id", "subjectName", _selectedSubject, (val) => _selectedSubject = val),
            const SizedBox(height: 8),
            _buildDropdown("Phòng học", widget.rooms, "id", "roomName", _selectedRoom, (val) => _selectedRoom = val),
            const SizedBox(height: 8),
            _buildDropdown("Giáo viên", widget.staffs, "id", "fullName", _selectedStaff, (val) => _selectedStaff = val),
            const SizedBox(height: 8),
            _buildDropdown("Tiết học", widget.slots, "id", "slotName", _selectedSlot, (val) => _selectedSlot = val),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.isEditing ? "Update" : "Add"),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items, String valueKey, String textKey, int? initialValue, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label, isDense: true),
      value: initialValue,
      items: items.map((i) => DropdownMenuItem(value: i[valueKey] as int, child: Text(i[textKey]))).toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedSubject == null || _selectedRoom == null || _selectedStaff == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all information")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        "classId": widget.classId,
        "subjectId": _selectedSubject,
        "roomId": _selectedRoom,
        "staffId": _selectedStaff,
        "slotId": _selectedSlot,
        "date": _selectedDate.toIso8601String(),
      };

      if (widget.isEditing) {
        await ScheduleService().updateSchedule(widget.editSchedule!.id!, data);
      } else {
        await ScheduleService().createSchedule(data);
      }

      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? "Session updated successfully" : "Session added successfully", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String msg = e.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _BatchScheduleWizard extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> staffs;
  final List<Map<String, dynamic>> slots;
  final int classId;
  final VoidCallback onSuccess;

  const _BatchScheduleWizard({
    required this.subjects,
    required this.rooms,
    required this.staffs,
    required this.slots,
    required this.classId,
    required this.onSuccess,
  });

  @override
  State<_BatchScheduleWizard> createState() => _BatchScheduleWizardState();
}

class _BatchScheduleWizardState extends State<_BatchScheduleWizard> {
  int? _selectedSubject;
  int? _selectedRoom;
  int? _selectedStaff;
  List<int> _selectedSlots = [];
  List<int> _selectedDays = [1, 3, 5]; // Mon, Wed, Fri by default
  DateTime _startDate = DateTime.now();
  final _sessionsController = TextEditingController(text: "30");
  bool _isLoading = false;

  final Map<int, String> _dayNames = {
    1: "Mon",
    2: "Tue",
    3: "Wed",
    4: "Thu",
    5: "Fri",
    6: "Sat",
    0: "Sun",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Batch Schedule Creation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreSmall("Subject", widget.subjects, "id", "subjectName", (val) => _selectedSubject = val),
                  const SizedBox(height: 12),
                  _buildScoreSmall("Room", widget.rooms, "id", "roomName", (val) => _selectedRoom = val),
                  const SizedBox(height: 12),
                  _buildScoreSmall("Teacher", widget.staffs, "id", "fullName", (val) => _selectedStaff = val),
                  const SizedBox(height: 20),
                  const Text("Select Days of Week", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _dayNames.entries.map((e) {
                      final isSelected = _selectedDays.contains(e.key);
                      return FilterChip(
                        label: Text(e.value),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) _selectedDays.add(e.key);
                            else _selectedDays.remove(e.key);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("Select Slots", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: widget.slots.map((s) {
                      final isSelected = _selectedSlots.contains(s['id']);
                      return FilterChip(
                        label: Text(s['slotName']),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) _selectedSlots.add(s['id']);
                            else _selectedSlots.remove(s['id']);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () async {
                                final res = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (res != null) setState(() => _startDate = res);
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _sessionsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Total Sessions",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleBatchSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Create Schedule Now", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSmall(String label, List<Map<String, dynamic>> items, String valueKey, String textKey, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((i) => DropdownMenuItem(value: i[valueKey] as int, child: Text(i[textKey]))).toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  Future<void> _handleBatchSchedule() async {
    if (_selectedSubject == null || _selectedRoom == null || _selectedStaff == null || _selectedSlots.isEmpty || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all information")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await ScheduleService().batchSchedule({
        "classId": widget.classId,
        "subjectId": _selectedSubject,
        "roomId": _selectedRoom,
        "staffId": _selectedStaff,
        "slotIds": _selectedSlots,
        "daysOfWeek": _selectedDays,
        "startDate": _startDate.toIso8601String(),
        "totalSessions": int.parse(_sessionsController.text),
        "skipHolidays": true,
        "skipSundays": !_selectedDays.contains(0),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      widget.onSuccess();
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
