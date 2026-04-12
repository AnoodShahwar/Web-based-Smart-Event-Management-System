import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final Set<String> _viewedEventIds = {};
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  String _selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'WSEMS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildEventFeed();
      case 1:
        return _buildMyEvents();
      case 2:
        return _buildProfile();
      default:
        return _buildEventFeed();
    }
  }

  // EVENT FEED
  Widget _buildEventFeed() {
    return Column(
      children: [
        // Department dropdown filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  decoration: InputDecoration(
                    hintText: 'All Departments',
                    prefixIcon: const Icon(
                      Icons.school_outlined,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kPrimaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: kDepartments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Row(
                        children: [
                          Icon(
                            dept == 'All'
                                ? Icons.all_inclusive
                                : Icons.school_outlined,
                            size: 16,
                            color: dept == _selectedDepartment
                                ? kPrimaryColor
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dept,
                              style: TextStyle(
                                fontSize: 13,
                                color: dept == _selectedDepartment
                                    ? kPrimaryColor
                                    : Colors.grey.shade800,
                                fontWeight: dept == _selectedDepartment
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDepartment = value!);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Search button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String searchQuery = '';
                        return StatefulBuilder(
                          builder: (context, setDialogState) => AlertDialog(
                            title: const Text(
                              'Search Department',
                              style: TextStyle(fontSize: 16),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Type department name...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      setDialogState(() => searchQuery = v),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 300,
                                  width: double.maxFinite,
                                  child: ListView(
                                    children: kDepartments
                                        .where(
                                          (d) => d.toLowerCase().contains(
                                            searchQuery.toLowerCase(),
                                          ),
                                        )
                                        .map(
                                          (dept) => ListTile(
                                            dense: true,
                                            leading: Icon(
                                              dept == 'All'
                                                  ? Icons.all_inclusive
                                                  : Icons.school_outlined,
                                              size: 16,
                                              color: kPrimaryColor,
                                            ),
                                            title: Text(
                                              dept,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(
                                                () =>
                                                    _selectedDepartment = dept,
                                              );
                                              Navigator.pop(context);
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: StreamBuilder<List<EventModel>>(
            stream: _eventService.getEvents(
              department: _selectedDepartment == 'All'
                  ? null
                  : _selectedDepartment,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try a different department',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) => _buildEventCard(events[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // EVENT CARD
  Widget _buildEventCard(EventModel event) {
    // Track viewed events using a simple set
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Banner(
          message: event.isComingSoon
              ? 'Coming Soon'
              : _viewedEventIds.contains(event.id)
              ? ''
              : 'New',
          location: BannerLocation.topEnd,
          color: event.isComingSoon
              ? kPrimaryColor
              : _viewedEventIds.contains(event.id)
              ? Colors.transparent
              : Colors.green.shade600,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() => _viewedEventIds.add(event.id));
              context.go('/event/${event.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.registrationType == 'Free'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          event.registrationType == 'Free'
                              ? 'Free'
                              : 'Rs. ${event.ticketPrice.toStringAsFixed(0)} • Onsite',
                          style: TextStyle(
                            fontSize: 12,
                            color: event.registrationType == 'Free'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.department,
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimaryColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.isComingSoon
                            ? 'Coming Soon'
                            : '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: event.isComingSoon
                              ? kPrimaryColor
                              : Colors.grey.shade600,
                          fontWeight: event.isComingSoon
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.attendingCount} attending',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MY EVENTS
  Widget _buildMyEvents() {
    return StreamBuilder<List<String>>(
      stream: _eventService.getMyAttendingEventIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final attendingIds = snapshot.data ?? [];
        if (attendingIds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "You haven't marked any events yet",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Tap an event and mark yourself as attending!",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }
        return StreamBuilder<List<EventModel>>(
          stream: _eventService.getEvents(),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allEvents = eventSnapshot.data ?? [];
            final myEvents = allEvents
                .where((e) => attendingIds.contains(e.id))
                .toList();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myEvents.length,
              itemBuilder: (context, index) => _buildEventCard(myEvents[index]),
            );
          },
        );
      },
    );
  }

  // PROFILE
  Widget _buildProfile() {
    final user = _authService.currentUser;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 48,
            backgroundColor: kPrimaryColor,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'S',
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Student',
              style: TextStyle(color: kPrimaryColor, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () async {
                await _authService.logout();
                if (mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
