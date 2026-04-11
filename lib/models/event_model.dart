class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final int capacity;
  final int registeredCount;
  final String createdBy;
  final String category;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.capacity,
    required this.registeredCount,
    required this.createdBy,
    required this.category,
  });

  // Converts Firestore document into EventModel object
  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      dateTime: data['dateTime']?.toDate() ?? DateTime.now(),
      capacity: data['capacity'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      category: data['category'] ?? 'General',
    );
  }

  // Converts EventModel into Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'createdBy': createdBy,
      'category': category,
    };
  }

  // Check if event is full
  bool get isFull => registeredCount >= capacity;

  // Check if event is upcoming
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}
