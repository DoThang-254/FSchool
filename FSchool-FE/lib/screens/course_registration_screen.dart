import 'package:flutter/material.dart';
import '../controllers/registration_controller.dart';
import '../services/subject_service.dart';
import '../services/semester_service.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final int studentId;
  const CourseRegistrationScreen({super.key, required this.studentId});

  @override
  State<CourseRegistrationScreen> createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  final _registrationController = RegistrationController();
  final _subjectService = SubjectService();
  final _semesterService = SemesterService();

  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _semesters = [];
  
  int? _selectedSubjectId;
  int? _selectedSemesterId;
  bool _isLoading = true;
  bool _isModifying = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _subjectService.getSubjects(),
        _semesterService.getSemesters(),
      ]);
      
      setState(() {
        _subjects = results[0];
        _semesters = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleRegister() async {
    if (_selectedSubjectId == null || _selectedSemesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select subject and semester')));
      return;
    }

    setState(() => _isModifying = true);
    try {
      await _registrationController.registerSubject(
        studentId: widget.studentId,
        subjectId: _selectedSubjectId!,
        semesterId: _selectedSemesterId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isModifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Subject'),
                  items: _subjects.map((s) => DropdownMenuItem<int>(
                    value: s['id'],
                    child: Text(s['subjectName']),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedSubjectId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                   decoration: const InputDecoration(labelText: 'Select Semester'),
                   value: _selectedSemesterId,
                   items: _semesters.map((s) => DropdownMenuItem<int>(
                     value: s['id'],
                     child: Text(s['name']),
                   )).toList(),
                   onChanged: (v) => setState(() => _selectedSemesterId = v),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isModifying ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isModifying 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }
}
