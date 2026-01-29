class AdminAvailablitEntity {
  final int id;
  final int userid; // staff id
  final String dte; // yyyy-MM-dd
  final int? organiz;

  final String? amfrom;
  final String? amto;
  final String? pmfrom;
  final String? pmto;
  final String? n8from;
  final String? n8to;

  final String? notes;

  const AdminAvailablitEntity({
    required this.id,
    required this.userid,
    required this.dte,
    this.organiz,
    this.amfrom,
    this.amto,
    this.pmfrom,
    this.pmto,
    this.n8from,
    this.n8to,
    this.notes,
  });

  DateTime get date => DateTime.tryParse(dte) ?? DateTime(1970, 1, 1);
}
