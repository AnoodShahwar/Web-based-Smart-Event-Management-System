import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET ALL EVENTS - returns a live stream of events
  Stream<List<EventModel>> getEvents() {
    return _firestore.collection('events').orderBy('dateTime').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // GET SINGLE EVENT
  Future<EventModel?> getEvent(String eventId) async {
    DocumentSnapshot doc = await _firestore
        .collection('events')
        .doc(eventId)
        .get();
    if (doc.exists) {
      return EventModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  }

  // CREATE EVENT (admin only)
  Future<String?> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // UPDATE EVENT (admin only)
  Future<String?> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore.collection('events').doc(eventId).update(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // DELETE EVENT (admin only)
  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // REGISTER FOR EVENT (student)
  Future<String?> registerForEvent(String eventId) async {
    try {
      String uid = _auth.currentUser!.uid;

      // Check if already registered
      DocumentSnapshot existing = await _firestore
          .collection('registrations')
          .doc('${uid}_$eventId')
          .get();

      if (existing.exists) {
        return 'You are already registered for this event.';
      }

      // Get event to check capacity
      EventModel? event = await getEvent(eventId);
      if (event == null) return 'Event not found.';
      if (event.isFull) return 'This event is full.';

      // Add registration
      await _firestore.collection('registrations').doc('${uid}_$eventId').set({
        'userId': uid,
        'eventId': eventId,
        'registeredAt': DateTime.now(),
      });

      // Increment registered count
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(1),
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // CANCEL REGISTRATION (student)
  Future<String?> cancelRegistration(String eventId) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore
          .collection('registrations')
          .doc('${uid}_$eventId')
          .delete();

      // Decrement registered count
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(-1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // CHECK IF STUDENT IS REGISTERED FOR AN EVENT
  Future<bool> isRegistered(String eventId) async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore
        .collection('registrations')
        .doc('${uid}_$eventId')
        .get();
    return doc.exists;
  }

  // GET STUDENT'S REGISTERED EVENTS
  Stream<List<String>> getMyRegisteredEventIds() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['eventId'] as String).toList(),
        );
  }
}
