import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';

/// Edit profile: photo (via image URL), name, DOB, gender, location, bio.
/// Email is read-only.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _bio;
  Gender? _gender;
  DateTime? _dob;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _location = TextEditingController(text: p.location);
    _bio = TextEditingController(text: p.bio);
    _gender = p.gender;
    _dob = p.dateOfBirth;
    _photoUrl = p.photoUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _editPhoto() async {
    final controller = TextEditingController(text: _photoUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profile photo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Use photo'),
          ),
        ],
      ),
    );
    if (url != null) setState(() => _photoUrl = url.isEmpty ? null : url);
  }

  Future<void> _save() async {
    final ok = await ref.read(profileControllerProvider.notifier).saveProfile(
          name: _name.text.trim(),
          gender: _gender,
          dateOfBirth: _dob,
          bio: _bio.text.trim(),
          location: _location.text.trim(),
          photoUrl: _photoUrl,
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(profileControllerProvider).isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(profileControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text((next.error as Failure).message)),
          );
      }
    });

    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(onPressed: saving ? null : _save, child: const Text('Save')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        hasPhoto ? NetworkImage(_photoUrl!) : null,
                    child: hasPhoto
                        ? null
                        : Icon(Icons.person_rounded,
                            size: 44, color: colorScheme.primary),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _editPhoto,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            _Label('Full Name'),
            TextField(controller: _name),
            const SizedBox(height: AppSizes.md),
            _Label('Email'),
            TextFormField(
              initialValue: widget.profile.email,
              enabled: false,
            ),
            const SizedBox(height: AppSizes.md),
            _Label('Date of Birth'),
            InkWell(
              onTap: _pickDob,
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                child: Text(
                  _dob == null
                      ? 'Select date'
                      : DateFormat('d MMMM yyyy').format(_dob!),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _Label('Gender'),
            DropdownButtonFormField<Gender>(
              value: _gender,
              items: [
                for (final g in Gender.values)
                  DropdownMenuItem(value: g, child: Text(g.label)),
              ],
              onChanged: (g) => setState(() => _gender = g),
            ),
            const SizedBox(height: AppSizes.md),
            _Label('Location'),
            TextField(controller: _location),
            const SizedBox(height: AppSizes.md),
            _Label('Bio'),
            TextField(controller: _bio, maxLines: 3),
            const SizedBox(height: AppSizes.xl),
            PrimaryButton(
              label: 'Save Changes',
              isLoading: saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
