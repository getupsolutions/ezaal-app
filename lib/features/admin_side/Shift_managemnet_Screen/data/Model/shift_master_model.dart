class OrganizationDto {
  final int id;
  final String name;

  OrganizationDto({required this.id, required this.name});

  factory OrganizationDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return OrganizationDto(id: parsedId, name: (json['name'] ?? '') as String);
  }
}

class StaffTypeDto {
  final int id;
  final String designation;

  StaffTypeDto({required this.id, required this.designation});

  factory StaffTypeDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return StaffTypeDto(
      id: parsedId,
      designation: (json['designation'] ?? '') as String,
    );
  }
}

class StaffDto {
  final int id;
  final String name;

  StaffDto({required this.id, required this.name});

  factory StaffDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return StaffDto(id: parsedId, name: (json['name'] ?? '') as String);
  }
}

class DepartmentDto {
  final int id;
  final String department;

  DepartmentDto({required this.id, required this.department});

  factory DepartmentDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return DepartmentDto(
      id: parsedId,
      department: (json['department'] ?? '') as String,
    );
  }
}

class ShiftMastersDto {
  final List<OrganizationDto> organizations;
  final List<StaffTypeDto> staffTypes;
  final List<StaffDto> staff;
  final List<DepartmentDto> departments;

  ShiftMastersDto({
    required this.organizations,
    required this.staffTypes,
    required this.staff,
    required this.departments,
  });

  factory ShiftMastersDto.fromJson(Map<String, dynamic> json) {
    final orgsJson = (json['organizations'] as List? ?? []);
    final staffTypesJson = (json['staff_types'] as List? ?? []);
    final staffJson = (json['staff'] as List? ?? []);
    final deptsJson = (json['departments'] as List? ?? []);

    return ShiftMastersDto(
      organizations:
          orgsJson
              .map((e) => OrganizationDto.fromJson(e as Map<String, dynamic>))
              .toList(),
      staffTypes:
          staffTypesJson
              .map((e) => StaffTypeDto.fromJson(e as Map<String, dynamic>))
              .toList(),
      staff:
          staffJson
              .map((e) => StaffDto.fromJson(e as Map<String, dynamic>))
              .toList(),
      departments:
          deptsJson
              .map((e) => DepartmentDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
