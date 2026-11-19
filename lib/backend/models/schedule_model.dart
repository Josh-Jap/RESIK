class ScheduleModel {
  final int? idSchedule;
  final String time;
  final String area;
  final String type;
  final String status; // 'Baru', 'Diproses', 'Selesai'
  final String? date;
  final String? day;
  final String? officer;
  final String? notes;

  ScheduleModel({
    this.idSchedule,
    required this.time,
    required this.area,
    required this.type,
    this.status = 'Baru',
    this.date,
    this.day,
    this.officer,
    this.notes,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      idSchedule: map['id_schedule'] != null
          ? int.tryParse(map['id_schedule'].toString())
          : null,
      time: map['time']?.toString() ?? '08:00',
      area: map['area']?.toString() ?? '-',
      type: map['type']?.toString() ?? 'Jenis: Organik',
      status: map['status']?.toString() ?? 'Baru',
      date: map['date']?.toString(),
      day: map['day']?.toString(),
      officer: map['officer']?.toString(),
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idSchedule != null) 'id_schedule': idSchedule,
      'time': time,
      'area': area,
      'type': type,
      'status': status,
      if (date != null) 'date': date,
      if (day != null) 'day': day,
      if (officer != null) 'officer': officer,
      if (notes != null) 'notes': notes,
    };
  }

  ScheduleModel copyWith({
    int? idSchedule,
    String? time,
    String? area,
    String? type,
    String? status,
    String? date,
    String? day,
    String? officer,
    String? notes,
  }) {
    return ScheduleModel(
      idSchedule: idSchedule ?? this.idSchedule,
      time: time ?? this.time,
      area: area ?? this.area,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      day: day ?? this.day,
      officer: officer ?? this.officer,
      notes: notes ?? this.notes,
    );
  }
}
