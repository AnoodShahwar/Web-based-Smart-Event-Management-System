import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'WSEMS Admin',
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
              onPressed: () => _showEventForm(context),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildEventList();
      case 1:
        return _buildUserList();
      case 2:
        return _buildDashboard();
      default:
        return _buildEventList();
    }
  }

  // EVENTS LIST
  Widget _buildEventList() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No events yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Event'),
                  onPressed: () => _showEventForm(context),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (event.isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(fontSize: 11, color: kPrimaryColor),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      event.isComingSoon
                          ? 'Coming Soon • ${event.location}'
                          : '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} • ${event.location}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.department} • ${event.registrationType}${event.ticketPrice > 0 ? ' • Rs. ${event.ticketPrice.toStringAsFixed(0)}' : ''}',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: kPrimaryColor,
                      onPressed: () => _showEventForm(context, event: event),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade400,
                      onPressed: () => _confirmDelete(context, event),
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

  // USER LIST
  Widget _buildUserList() {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: kPrimaryColor,
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : user.email[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(user.email),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? kPrimaryColor.withOpacity(0.1)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: user.role == 'admin'
                          ? kPrimaryColor
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // DASHBOARD
  Widget _buildDashboard() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
        final totalEvents = events.length;
        final totalAttending = events.fold(
          0,
          (sum, e) => sum + e.attendingCount,
        );
        final upcomingEvents = events.where((e) => e.isUpcoming).length;
        final paidEvents = events
            .where((e) => e.registrationType == 'Paid (Onsite)')
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Smaller stat cards in a row
              Row(
                children: [
                  _statCard(
                    'Events',
                    totalEvents.toString(),
                    Icons.event,
                    kPrimaryColor,
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    'Attending',
                    totalAttending.toString(),
                    Icons.people,
                    Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    'Upcoming',
                    upcomingEvents.toString(),
                    Icons.upcoming,
                    Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    'Paid',
                    paidEvents.toString(),
                    Icons.attach_money,
                    Colors.orange.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...events
                  .take(3)
                  .map(
                    (event) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${event.attendingCount} attending • ${event.department}',
                        ),
                        trailing: Text(
                          event.isComingSoon
                              ? 'Coming Soon'
                              : '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  // STAT CARD — smaller now
  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // DELETE CONFIRMATION
  void _confirmDelete(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _eventService.deleteEvent(event.id);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Event deleted.')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // CREATE/EDIT EVENT FORM
  void _showEventForm(BuildContext context, {EventModel? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(
      text: event?.description ?? '',
    );
    final locationController = TextEditingController(
      text: event?.location ?? '',
    );
    String selectedCategory = event?.category ?? kCategories[0];
    String selectedDepartment = event?.department ?? kDepartments[1];
    String selectedRegistrationType =
        event?.registrationType ?? kRegistrationTypes[0];
    DateTime selectedDate = event?.dateTime ?? DateTime.now();
    bool isComingSoon = event?.isComingSoon ?? false;
    final ticketPriceController = TextEditingController(
      text: event?.ticketPrice != null && event!.ticketPrice > 0
          ? event.ticketPrice.toStringAsFixed(0)
          : '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event == null ? 'Create New Event' : 'Edit Event',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 12),

                  // Location
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter a location' : null,
                  ),
                  const SizedBox(height: 12),

                  // Department
                  DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    isExpanded: true,
                    menuMaxHeight: 300,
                    decoration: const InputDecoration(
                      labelText: 'Organizing Department',
                      border: OutlineInputBorder(),
                    ),
                    items: kDepartments
                        .where((d) => d != 'All')
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedDepartment = v!),
                  ),
                  const SizedBox(height: 12),

                  // Category
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: kCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),

                  // Registration Type
                  DropdownButtonFormField<String>(
                    value: selectedRegistrationType,
                    decoration: const InputDecoration(
                      labelText: 'Registration Type',
                      border: OutlineInputBorder(),
                    ),
                    items: kRegistrationTypes
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedRegistrationType = v!),
                  ),
                  const SizedBox(height: 12),

                  // Ticket Price (only if Paid)
                  if (selectedRegistrationType == 'Paid (Onsite)') ...[
                    TextFormField(
                      controller: ticketPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ticket Price (Rs.)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 500',
                      ),
                      validator: (v) {
                        if (selectedRegistrationType == 'Paid (Onsite)' &&
                            (v == null || v.isEmpty)) {
                          return 'Please enter ticket price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Coming Soon Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Coming Soon',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Hide date and mark as coming soon',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isComingSoon,
                          activeColor: kPrimaryColor,
                          onChanged: (v) =>
                              setModalState(() => isComingSoon = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date picker (hidden if coming soon)
                  if (!isComingSoon)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: kPrimaryColor,
                      ),
                      title: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                      ),
                      subtitle: const Text('Tap to change date & time'),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time != null) {
                            setModalState(() {
                              selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final newEvent = EventModel(
                          id: event?.id ?? '',
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          location: locationController.text.trim(),
                          dateTime: selectedDate,
                          department: selectedDepartment,
                          category: selectedCategory,
                          registrationType: selectedRegistrationType,
                          attendingCount: event?.attendingCount ?? 0,
                          createdBy: _authService.currentUser?.uid ?? '',
                          isComingSoon: isComingSoon,
                          ticketPrice: ticketPriceController.text.isEmpty
                              ? 0
                              : double.parse(ticketPriceController.text),
                        );
                        if (event == null) {
                          await _eventService.createEvent(newEvent);
                        } else {
                          await _eventService.updateEvent(event.id, newEvent);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(
                        event == null ? 'Create Event' : 'Save Changes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
