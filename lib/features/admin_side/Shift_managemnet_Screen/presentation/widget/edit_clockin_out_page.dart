// features/admin_side/Shift_managemnet_Screen/presentation/widget/edit_attendance_dialog.dart

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditAttendanceDialog extends StatefulWidget {
  final ShiftItem shift;

  const EditAttendanceDialog({super.key, required this.shift});

  @override
  State<EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<EditAttendanceDialog> {
  late TextEditingController _signInTimeCtrl;
  late TextEditingController _signOutTimeCtrl;
  late TextEditingController _signInNoteCtrl;
  late TextEditingController _signOutNoteCtrl;
  late TextEditingController _breakCtrl;
  late TextEditingController _managerNameCtrl;
  late TextEditingController _managerDesigCtrl;

  String _signInType = 'Online';
  String _signOutType = 'Online';

  static const List<String> _allowedTypes = ['Online', 'Manual', 'Adjust'];

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    final signIn = _parseDateTime(widget.shift.signIn);
    final signOut = _parseDateTime(widget.shift.signOut);

    _signInTimeCtrl = TextEditingController(
      text: signIn == null ? '' : DateFormat('HH:mm').format(signIn),
    );
    _signOutTimeCtrl = TextEditingController(
      text: signOut == null ? '' : DateFormat('HH:mm').format(signOut),
    );

    _signInNoteCtrl = TextEditingController(
      text: widget.shift.signInReason ?? '',
    );
    _signOutNoteCtrl = TextEditingController(
      text: widget.shift.signOutReason ?? '',
    );
    _breakCtrl = TextEditingController(
      text: widget.shift.breakMinutes ?? '', // safer if null
    );
    _managerNameCtrl = TextEditingController(
      text: widget.shift.managerName ?? '',
    );
    _managerDesigCtrl = TextEditingController(
      text: widget.shift.managerDesignation ?? '',
    );

    // 🔐 Sanitize incoming types (backend might send 'early', 'late', etc.)
    final rawSignInType = widget.shift.signInType;
    final rawSignOutType = widget.shift.signOutType;

    _signInType =
        rawSignInType != null && _allowedTypes.contains(rawSignInType)
            ? rawSignInType
            : 'Online';

    _signOutType =
        rawSignOutType != null && _allowedTypes.contains(rawSignOutType)
            ? rawSignOutType
            : 'Online';
  }

  @override
  void dispose() {
    _signInTimeCtrl.dispose();
    _signOutTimeCtrl.dispose();
    _signInNoteCtrl.dispose();
    _signOutNoteCtrl.dispose();
    _breakCtrl.dispose();
    _managerNameCtrl.dispose();
    _managerDesigCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final currentText = controller.text;
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    if (currentText.isNotEmpty) {
      final parts = currentText.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 9;
        final m = int.tryParse(parts[1]) ?? 0;
        initial = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxDialogWidth = width > 500 ? 500.0 : width * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: BlocConsumer<AdminShiftBloc, AdminShiftState>(
          listener: (context, state) {
            if (state is UpdateShiftAttendanceSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.of(context).pop(); // close dialog
            } else if (state is UpdateShiftAttendanceFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSaving = state is UpdateShiftAttendanceSubmitting;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Clockin/Clockout & Manager',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Clock in/out section
                    const Text(
                      'Clock in/out details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _signInTimeCtrl,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Clock in time (HH:mm)',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () => _pickTime(_signInTimeCtrl),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value:
                                _allowedTypes.contains(_signInType)
                                    ? _signInType
                                    : null, // extra safety
                            decoration: const InputDecoration(
                              labelText: 'Clock in type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Online',
                                child: Text('Online'),
                              ),
                              DropdownMenuItem(
                                value: 'Manual',
                                child: Text('Manual'),
                              ),
                              DropdownMenuItem(
                                value: 'Adjust',
                                child: Text('Adjust'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _signInType = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _signInNoteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Clock in notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _signOutTimeCtrl,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Clock out time (HH:mm)',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () => _pickTime(_signOutTimeCtrl),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value:
                                _allowedTypes.contains(_signOutType)
                                    ? _signOutType
                                    : null, // extra safety
                            decoration: const InputDecoration(
                              labelText: 'Clock out type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Online',
                                child: Text('Online'),
                              ),
                              DropdownMenuItem(
                                value: 'Manual',
                                child: Text('Manual'),
                              ),
                              DropdownMenuItem(
                                value: 'Adjust',
                                child: Text('Adjust'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _signOutType = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _signOutNoteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Clock out notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _breakCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Break (minutes)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Manager info',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _managerNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Manager name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _managerDesigCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Manager designation',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed:
                              isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSaving ? null : _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              isSaving
                                  ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSavePressed() {
    final shiftDate = DateTime.parse(widget.shift.date); // yyyy-MM-dd

    DateTime? _combine(DateTime date, String text) {
      if (text.isEmpty) return null;
      final parts = text.split(':');
      if (parts.length != 2) return null;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final signIn = _combine(shiftDate, _signInTimeCtrl.text);
    final signOut = _combine(shiftDate, _signOutTimeCtrl.text);
    final breakMinutes = int.tryParse(_breakCtrl.text);

    final params = UpdateShiftAttendanceParams(
      shiftId: widget.shift.id,
      signIn: signIn,
      signInType: _signInType,
      signInReason:
          _signInNoteCtrl.text.trim().isEmpty
              ? null
              : _signInNoteCtrl.text.trim(),
      signOut: signOut,
      signOutType: _signOutType,
      signOutReason:
          _signOutNoteCtrl.text.trim().isEmpty
              ? null
              : _signOutNoteCtrl.text.trim(),
      breakMinutes: breakMinutes,
      managerName:
          _managerNameCtrl.text.trim().isEmpty
              ? null
              : _managerNameCtrl.text.trim(),
      managerDesignation:
          _managerDesigCtrl.text.trim().isEmpty
              ? null
              : _managerDesigCtrl.text.trim(),
    );

    context.read<AdminShiftBloc>().add(UpdateShiftAttendanceEvent(params));
  }
}
