import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  bool isAttending = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAttending();
  }

  Future<void> _checkAttending() async {
    final result = await _eventService.isAttending(widget.eventId);
    setState(() => isAttending = result);
  }

  Future<void> _toggleAttending(EventModel event) async {
    setState(() => isLoading = true);

    String? error;
    if (isAttending) {
      error = await _eventService.unmarkAttending(widget.eventId);
    } else {
      error = await _eventService.markAttending(widget.eventId);
    }

    setState(() => isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade600),
        );
      }
    } else {
      setState(() => isAttending = !isAttending);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAttending
                  ? "You're attending this event!"
                  : 'Removed from your events.',
            ),
            backgroundColor: isAttending
                ? Colors.green.shade600
                : Colors.orange.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student'),
        ),
        title: const Text('Event Details'),
      ),
      body: FutureBuilder<EventModel?>(
        future: _eventService.getEvent(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  color: kPrimaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              event.registrationType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.department,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info cards
                      Row(
                        children: [
                          _infoCard(
                            Icons.calendar_today,
                            'Date',
                            '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            Icons.access_time,
                            'Time',
                            '${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            Icons.people,
                            'Attending',
                            '${event.attendingCount}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.location,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Registration type notice
                      if (event.registrationType == 'Paid (Onsite)')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is a paid event. Tickets are available for purchase onsite on the day of the event.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'About this event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Attend button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _toggleAttending(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAttending
                                ? Colors.red.shade600
                                : kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isAttending
                                      ? "Remove from My Events"
                                      : "I'm Attending",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
