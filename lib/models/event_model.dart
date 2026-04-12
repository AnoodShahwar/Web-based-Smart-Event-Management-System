class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String department;
  final String category;
  final String registrationType;
  final String createdBy;
  final int attendingCount;
  final bool isComingSoon;
  final double ticketPrice;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.department,
    required this.category,
    required this.registrationType,
    required this.createdBy,
    required this.attendingCount,
    this.isComingSoon = false,
    this.ticketPrice = 0,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      dateTime: data['dateTime']?.toDate() ?? DateTime.now(),
      department: data['department'] ?? 'General',
      category: data['category'] ?? 'General',
      registrationType: data['registrationType'] ?? 'Free',
      createdBy: data['createdBy'] ?? '',
      attendingCount: data['attendingCount'] ?? 0,
      isComingSoon: data['isComingSoon'] ?? false,
      ticketPrice: (data['ticketPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'department': department,
      'category': category,
      'registrationType': registrationType,
      'createdBy': createdBy,
      'attendingCount': attendingCount,
      'isComingSoon': isComingSoon,
      'ticketPrice': ticketPrice,
    };
  }

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}
