import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';

class AddShiftScreen extends StatefulWidget {
  const AddShiftScreen({Key? key}) : super(key: key);

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  String selectedOrganization = 'Dhelkaya Health';
  String selectedStaffType = 'EEN';
  String selectedDepartment = 'Ellery Hous';
  String selectedStaff = 'Staff';
  String selectedLocation = 'Ellery Hous';

  final TextEditingController startTimeController = TextEditingController(
    text: '07:00',
  );
  final TextEditingController endTimeController = TextEditingController(
    text: '15:30',
  );
  final TextEditingController breakController = TextEditingController(
    text: '30 Min',
  );

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryDarK,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Shift Request',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Yellow header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFFF9C4),
            child: const Text(
              'modify request 26-11-2025',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel('Organization'),
                  buildDropdown(
                    value: selectedOrganization,
                    items: ['Dhelkaya Health'],
                    onChanged:
                        (value) =>
                            setState(() => selectedOrganization = value!),
                  ),

                  const SizedBox(height: 20),
                  buildLabel('Staff Type'),
                  buildDropdown(
                    value: selectedStaffType,
                    items: ['EEN', 'RN', 'EN'],
                    onChanged:
                        (value) => setState(() => selectedStaffType = value!),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel('Start Time'),
                            _buildTextField(startTimeController),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel('End Time'),
                            _buildTextField(endTimeController),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  buildLabel('Break'),
                  _buildTextField(breakController),

                  const SizedBox(height: 20),
                  buildLabel('Choose Department'),
                  buildDropdown(
                    value: selectedDepartment,
                    items: ['Ellery Hous', 'Emergency', 'ICU'],
                    onChanged:
                        (value) => setState(() => selectedDepartment = value!),
                  ),

                  const SizedBox(height: 20),
                  buildLabel('Select Staff'),
                  buildDropdown(
                    value: selectedStaff,
                    items: ['Staff', 'John Doe', 'Jane Smith'],
                    onChanged:
                        (value) => setState(() => selectedStaff = value!),
                  ),

                  const SizedBox(height: 20),
                  buildLabel('Notes/Location'),
                  buildDropdown(
                    value: selectedLocation,
                    items: ['Ellery Hous', 'Building A', 'Building B'],
                    onChanged:
                        (value) => setState(() => selectedLocation = value!),
                  ),

                  const SizedBox(height: 30),
                  // Duplicate button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Duplicate action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5A0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Duplicate this',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shift submitted successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          icon: const Icon(Icons.keyboard_arrow_down),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
