import 'package:flutter/material.dart';
import 'package:bai1/controllers/absence_request_controller.dart';
import 'package:bai1/controllers/schedule_controller.dart';
import 'package:bai1/models/absence_request.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _selectedRequestType = 0;

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSelectAll = false;
  bool _isSubmitting = false;
  bool _isLoadingSlots = false;
  int? _accountId;
  int? _classId;
  AbsenceRequestModel? _editRequest;

  final AbsenceRequestController _controller = AbsenceRequestController();
  final ScheduleController _scheduleController = ScheduleController();
  
  List<Map<String, dynamic>> _allSchedules = []; // cache all fetched schedules
  List<Map<String, dynamic>> _slots = []; // slots filtered for selected date

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is int) {
        _accountId = args;
      } else if (args is Map<String, dynamic>) {
        _accountId = args['accountId'];
        _classId = args['classId'];
        _editRequest = args['editRequest'];
        if (_editRequest != null) {
          _selectedDate = DateTime.parse(_editRequest!.date);
          _reasonController.text = _editRequest!.reason;
        }
      }

      if (_allSchedules.isEmpty && !_isLoadingSlots) {
        _fetchAllSchedules();
      }
    }
  }

  /// Fetch all schedules once, then filter by date locally
  Future<void> _fetchAllSchedules() async {
    setState(() => _isLoadingSlots = true);

    final schedules = await _scheduleController.fetchSchedules(classId: _classId);

    final List<Map<String, dynamic>> parsed = [];
    for (var s in schedules) {
      try {
        DateTime slotDate = DateTime.parse(s.date);
        String dateOnly = "${slotDate.year}-${slotDate.month.toString().padLeft(2, '0')}-${slotDate.day.toString().padLeft(2, '0')}";

        // Parse end time to check if slot has ended
        String timeStr = s.time.replaceAll(' ', '');
        List<String> times = timeStr.split('-');
        if (times.length < 2) continue;
        String endTimeStr = times.last;
        int endHour = int.parse(endTimeStr.split(':').first);
        int endMinute = int.parse(endTimeStr.split(':').last);

        parsed.add({
          'id': s.slotId,
          'name': 'Slot: ${s.subject}',
          'time': s.time,
          'room': s.room,
          'isSelected': false,
          'date': s.date,
          'dateOnly': dateOnly,
          'endHour': endHour,
          'endMinute': endMinute,
        });
      } catch (e) {
        debugPrint("Error parsing schedule: $e");
      }
    }

    _allSchedules = parsed;
    _filterSlotsForSelectedDate();
  }

  /// Filter cached schedules for the currently selected date
  void _filterSlotsForSelectedDate() {
    final now = DateTime.now();
    String selectedDateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final filtered = _allSchedules.where((s) {
      if (s['dateOnly'] != selectedDateStr) return false;

      // If the selected date is today, filter out slots that have already ended
      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day) {
        DateTime slotEnd = DateTime(now.year, now.month, now.day, s['endHour'], s['endMinute']);
        if (slotEnd.isBefore(now)) return false;
      }

      return true;
    }).map((s) => Map<String, dynamic>.from(s)).toList();

    // Sort by time
    filtered.sort((a, b) => a['time'].compareTo(b['time']));

    // Reset selection
    for (var s in filtered) {
      s['isSelected'] = false;
    }

    // Re-apply selection if editing
    if (_editRequest != null) {
      for (var slot in filtered) {
        slot['isSelected'] = _editRequest!.slots.any((s) => s.id == slot['id']);
      }
    }

    setState(() {
      _slots = filtered;
      _isLoadingSlots = false;
      _isSelectAll = _slots.isNotEmpty && _slots.every((s) => s['isSelected'] == true);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
        _selectedDate = picked;
        _isSelectAll = false;
      });
      _filterSlotsForSelectedDate();
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      for (var slot in _slots) {
        slot['isSelected'] = _isSelectAll;
      }
    });
  }

  void _toggleSlot(int index, bool? value) {
    setState(() {
      _slots[index]['isSelected'] = value ?? false;
      _isSelectAll = _slots.isNotEmpty && _slots.every((s) => s['isSelected'] == true);
    });
  }

  void _resetForm() {
    setState(() {
      _reasonController.clear();
      _isSelectAll = false;
      _selectedDate = DateTime.now();
      _selectedRequestType = 0;
    });
    _filterSlotsForSelectedDate();
  }

  Future<void> _submitRequest() async {
    final selectedSlotIds = _slots
        .where((s) => s['isSelected'] == true)
        .map<int>((s) => s['id'] as int)
        .toList();

    if (selectedSlotIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 slot')),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = false;
    if (_editRequest != null) {
      success = await _controller.updateAbsenceRequest(
        id: _editRequest!.id,
        date: _selectedDate,
        reason: _reasonController.text.trim(),
        slotIds: selectedSlotIds,
      );
    } else {
      final result = await _controller.submitAbsenceRequest(
        date: _selectedDate,
        reason: _reasonController.text.trim(),
        accountId: _accountId ?? 1,
        slotIds: selectedSlotIds,
      );
      success = result != null;
    }

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editRequest != null ? 'Update successful!' : 'Request submitted!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _editRequest != null ? 'Edit Absence Request' : 'Create Absence Request',
          style: const TextStyle(color: Colors.white),
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
            // 1. DATE PICKER - chọn ngày muốn nghỉ
            const Text(
              "Absence Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange.shade50.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
                    ),
                    const Icon(Icons.calendar_month, size: 20, color: Colors.orange),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. SLOT LIST HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Slots on $formattedDate",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (!_isLoadingSlots && _slots.isNotEmpty)
                  Row(
                    children: [
                      Checkbox(
                        value: _isSelectAll,
                        activeColor: Colors.orange,
                        onChanged: _toggleSelectAll,
                      ),
                      const Text("Select All"),
                    ],
                  ),
              ],
            ),

            // 3. SLOT LIST
            if (_isLoadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_slots.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No slots available on this date."),
                ),
              )
            else
              ..._slots.asMap().entries.map((entry) {
                int idx = entry.key;
                Map slot = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: slot['isSelected'] ? Colors.orange : Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      slot['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: slot['isSelected'] ? Colors.orange : Colors.black87,
                      ),
                    ),
                    subtitle: Text("${slot['time']}  •  Room: ${slot['room']}"),
                    trailing: Checkbox(
                      value: slot['isSelected'],
                      activeColor: Colors.orange,
                      onChanged: (val) => _toggleSlot(idx, val),
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 20),

            // 4. REASON
            const Text(
              "Reason",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter reason for absence",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 5. BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _editRequest != null ? "Update" : "Submit",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.orange,
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
}
