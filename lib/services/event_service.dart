import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET ALL EVENTS
  Stream<List<EventModel>> getEvents({String? department}) {
    Query query = _firestore.collection('events').orderBy('dateTime');
    if (department != null && department != 'All') {
      query = query.where('department', isEqualTo: department);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => EventModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
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

  // CREATE EVENT
  Future<String?> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // UPDATE EVENT
  Future<String?> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore.collection('events').doc(eventId).update(event.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // DELETE EVENT
  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // MARK ATTENDING
  Future<String?> markAttending(String eventId) async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot existing = await _firestore
          .collection('attendees')
          .doc('${uid}_$eventId')
          .get();

      if (existing.exists) {
        return 'You have already marked attendance for this event.';
      }

      await _firestore.collection('attendees').doc('${uid}_$eventId').set({
        'userId': uid,
        'eventId': eventId,
        'markedAt': DateTime.now(),
      });

      await _firestore.collection('events').doc(eventId).update({
        'attendingCount': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // UNMARK ATTENDING
  Future<String?> unmarkAttending(String eventId) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore.collection('attendees').doc('${uid}_$eventId').delete();

      await _firestore.collection('events').doc(eventId).update({
        'attendingCount': FieldValue.increment(-1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // CHECK IF ATTENDING
  Future<bool> isAttending(String eventId) async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore
        .collection('attendees')
        .doc('${uid}_$eventId')
        .get();
    return doc.exists;
  }

  // GET MY ATTENDING EVENT IDs
  Stream<List<String>> getMyAttendingEventIds() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('attendees')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['eventId'] as String).toList(),
        );
  }
}
