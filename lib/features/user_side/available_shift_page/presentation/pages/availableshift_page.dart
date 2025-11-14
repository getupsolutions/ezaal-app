import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/custom_shift_card.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_event.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailableshiftPage extends StatefulWidget {
  const AvailableshiftPage({super.key});

  @override
  State<AvailableshiftPage> createState() => _AvailableshiftPageState();
}

class _AvailableshiftPageState extends State<AvailableshiftPage> {
  String? selectedOrganization;
  List<String> allOrganizations = [];

  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(FetchShifts());
  }

  void _showFilterDialog(BuildContext context, List<String> organizations) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? tempSelectedOrg = selectedOrganization;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, color: kWhite),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Filter by Organization',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kWhite,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: kWhite),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // All Organizations Option
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempSelectedOrg = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    tempSelectedOrg == null
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color:
                                        tempSelectedOrg == null
                                            ? primaryColor
                                            : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    tempSelectedOrg == null
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color:
                                        tempSelectedOrg == null
                                            ? primaryColor
                                            : Colors.grey,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'All Organizations',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            tempSelectedOrg == null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            tempSelectedOrg == null
                                                ? primaryColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (tempSelectedOrg == null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${organizations.length}',
                                        style: TextStyle(
                                          color: kWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(thickness: 1),
                          ),

                          // Organization List
                          ...organizations.map((org) {
                            final isSelected = tempSelectedOrg == org;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  tempSelectedOrg = org;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryColor.withOpacity(0.1)
                                          : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color:
                                          isSelected
                                              ? primaryColor
                                              : Colors.transparent,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color:
                                          isSelected
                                              ? primaryColor
                                              : Colors.grey,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        org,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    // Footer Actions
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedOrganization = tempSelectedOrg;
                              });
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: kWhite,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Apply Filter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (allOrganizations.isNotEmpty) {
                    _showFilterDialog(context, allOrganizations);
                  }
                },
                child: Icon(Icons.filter_list, color: kWhite),
              ),
              if (selectedOrganization != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
        ],
        title: 'Available Shift',
        backgroundColor: primaryDarK,
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftClaimSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Shift claimed successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ShiftLoaded) {
            // Extract unique organization names and update the list
            final organizations =
                state.shifts.map((shift) => shift.agencyName).toSet().toList()
                  ..sort();

            // Update allOrganizations for the filter dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  allOrganizations = organizations;
                });
              }
            });

            // Filter shifts based on selected organization
            final filteredShifts =
                selectedOrganization == null
                    ? state.shifts
                    : state.shifts
                        .where(
                          (shift) => shift.agencyName == selectedOrganization,
                        )
                        .toList();

            if (state.shifts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No shifts available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (filteredShifts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      selectedOrganization != null
                          ? 'No shifts available for $selectedOrganization'
                          : 'No shifts available',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    if (selectedOrganization != null) ...[
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedOrganization = null;
                          });
                        },
                        child: Text('Clear Filter'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (selectedOrganization != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    color: primaryColor.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 20, color: primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtered by: $selectedOrganization',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedOrganization = null;
                            });
                          },
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredShifts.length,
                    itemBuilder: (context, index) {
                      final shift = filteredShifts[index];
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ShiftCardWidget(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          duration: shift.duration,
                          time: shift.time,
                          agencyName: shift.agencyName,
                          notes: shift.notes,
                          location: shift.location,
                          onButtonPressed: () {
                            context.read<ShiftBloc>().add(ClaimShift(shift.id));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ShiftError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShiftBloc>().add(FetchShifts());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('No Shift Available'));
        },
      ),
    );
  }
}
