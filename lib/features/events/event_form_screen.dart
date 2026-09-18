import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'event_controller.dart';
import 'event_model.dart';
import 'event_widgets.dart';

class EventFormScreen extends StatefulWidget {
  final EventController controller;
  final String role;
  final EventModel? existingEvent;

  const EventFormScreen({
    super.key,
    required this.controller,
    required this.role,
    this.existingEvent,
  });

  bool get isEditing => existingEvent != null;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _meetingLinkController;
  late DateTime _startAt;
  late DateTime _endAt;
  DateTime? _registrationDeadline;
  bool _isOnline = false;
  int? _capacity;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();

    final event = widget.existingEvent;

    _titleController = TextEditingController(
      text: event?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );

    _venueController = TextEditingController(
      text: event?.venue ?? '',
    );

    _meetingLinkController = TextEditingController(
      text: event?.meetingLink ?? '',
    );

    _startAt = event?.startAt ??
        DateTime.now().add(
          const Duration(
            hours: 2,
          ),
        );

    _endAt = event?.endAt ??
        _startAt.add(
          const Duration(
            hours: 2,
          ),
        );

    _registrationDeadline = event?.registrationDeadline;

    _isOnline = event?.isOnline ?? false;

    _capacity = event?.capacity;

    _isPublished = event?.isPublished ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit event' : 'Create event',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            AppDimens.space20,
          ),
          children: [
            _section(
              title: 'Event basics',
              subtitle:
                  'Give participants a clear picture of what this event is about.',
              child: Column(
                children: [
                  _textField(
                    controller: _titleController,
                    label: 'Event title',
                    hint: 'CampusConnect Innovation Day',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Event title is required';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _textField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the event...',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              title: 'Location & format',
              subtitle: 'Tell attendees where the event is happening.',
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Online event',
                    ),
                    subtitle: Text(
                      'Turn this on when the event happens remotely.',
                      style: AppTextStyles.bodySmall(
                        AppColors.darkTextSecondary,
                      ),
                    ),
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _textField(
                    controller:
                        _isOnline ? _meetingLinkController : _venueController,
                    label: _isOnline ? 'Meeting link' : 'Venue',
                    hint: _isOnline ? 'https://meet...' : 'Sir MVIT Auditorium',
                    keyboardType:
                        _isOnline ? TextInputType.url : TextInputType.text,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              title: 'Schedule',
              subtitle:
                  'Set when the event starts, ends and closes registrations.',
              child: Column(
                children: [
                  _dateField(
                    label: 'Start',
                    value: _startAt,
                    onTap: () async {
                      final value = await _pickDateTime(
                        _startAt,
                      );

                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _startAt = value;

                        if (_endAt.isBefore(
                          value,
                        )) {
                          _endAt = value.add(
                            const Duration(
                              hours: 2,
                            ),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _dateField(
                    label: 'End',
                    value: _endAt,
                    onTap: () async {
                      final value = await _pickDateTime(
                        _endAt,
                      );

                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _endAt = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _dateField(
                    label: 'Registration deadline',
                    value: _registrationDeadline,
                    optional: true,
                    onTap: () async {
                      final value = await _pickDateTime(
                        _registrationDeadline ??
                            _startAt.subtract(
                              const Duration(
                                hours: 1,
                              ),
                            ),
                      );

                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _registrationDeadline = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              title: 'Capacity',
              subtitle: 'Leave it unrestricted when everyone can participate.',
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _capacity,
                      dropdownColor: AppColors.darkSurfaceElevated,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                      ),
                      items: const [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'Unlimited',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text(
                            '50',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text(
                            '100',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 200,
                          child: Text(
                            '200',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 500,
                          child: Text(
                            '500',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _capacity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              title: 'Publishing',
              subtitle:
                  'New events start as drafts and can be published when ready.',
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Publish immediately',
                ),
                subtitle: const Text(
                  'Students and members can register only after publishing.',
                ),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: AppDimens.buttonHeight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(
                  widget.isEditing ? Icons.save_outlined : Icons.add_rounded,
                ),
                label: Text(
                  widget.isEditing ? 'Save changes' : 'Create event',
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimens.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMedium(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(
              AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppDimens.radiusMedium,
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),
        child: Text(
          value == null
              ? 'Not set'
              : DateFormat(
                  'dd MMM yyyy • hh:mm a',
                ).format(
                  value,
                ),
          style: AppTextStyles.bodyMedium(
            value == null
                ? AppColors.darkTextTertiary
                : AppColors.darkTextPrimary,
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(
        const Duration(
          days: 1,
        ),
      ),
      lastDate: DateTime.now().add(
        const Duration(
          days: 730,
        ),
      ),
      builder: (_, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurfaceElevated,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        initial,
      ),
      builder: (_, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurfaceElevated,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_endAt.isAfter(
      _startAt,
    )) {
      Get.snackbar(
        'Invalid schedule',
        'End time must be after start time.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    if (_registrationDeadline != null &&
        _registrationDeadline!.isAfter(
          _startAt,
        )) {
      Get.snackbar(
        'Invalid registration deadline',
        'Registration deadline must be before the event starts.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final existing = widget.existingEvent;

    final event = EventModel(
      id: existing?.id ?? 'event-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      venue: _isOnline ? null : _venueController.text.trim(),
      isOnline: _isOnline,
      meetingLink: _isOnline ? _meetingLinkController.text.trim() : null,
      startAt: _startAt,
      endAt: _endAt,
      registrationDeadline: _registrationDeadline,
      capacity: _capacity,
      isPublished: _isPublished,
      status: existing?.status ??
          (_startAt.isAfter(
            DateTime.now(),
          )
              ? EventStatus.upcoming
              : EventStatus.ongoing),
      registrationCount: existing?.registrationCount ?? 0,
      attendanceCount: existing?.attendanceCount ?? 0,
      staffQrToken: existing?.staffQrToken,
      studentQrToken: existing?.studentQrToken,
    );

    if (widget.isEditing) {
      final ok = await widget.controller.updateEvent(event);
      if (!ok) return;
    } else {
      final ok = await widget.controller.addEvent(event);
      if (!ok) return;
    }

    Get.back();
  }
}
