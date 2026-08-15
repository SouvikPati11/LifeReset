import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';

/// Edit profile: photo (via image URL), name, DOB, gender, location, bio.
/// Email is read-only. Preserves the existing update logic.
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
  bool _nameError = false;

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
        backgroundColor: HomeStyle.card,
        title: const Text('Profile photo'),
        content: TextField(
          controller: controller,
          autofocus: true,
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
            style: FilledButton.styleFrom(backgroundColor: HomeStyle.primary),
            child: const Text('Use photo'),
          ),
        ],
      ),
    );
    if (url != null) setState(() => _photoUrl = url.isEmpty ? null : url);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final ok = await ref.read(profileControllerProvider.notifier).saveProfile(
          name: name,
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

    ref.listen(profileControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text((next.error as Failure).message)),
          );
      }
    });

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Edit Profile',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  Center(child: _PhotoPicker(url: _photoUrl, onTap: _editPhoto)),
                  const SizedBox(height: AppSizes.xl),
                  _Field(
                    label: 'Full Name',
                    error: _nameError ? 'Please enter your name.' : null,
                    child: _Input(
                      controller: _name,
                      hint: 'Your name',
                      onChanged: (_) {
                        if (_nameError) setState(() => _nameError = false);
                      },
                    ),
                  ),
                  _Field(
                    label: 'Email',
                    child: _ReadOnlyValue(text: widget.profile.email),
                  ),
                  _Field(
                    label: 'Date of Birth',
                    child: _TapValue(
                      text: _dob == null
                          ? 'Select date'
                          : DateFormat('d MMMM yyyy').format(_dob!),
                      placeholder: _dob == null,
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDob,
                    ),
                  ),
                  _Field(
                    label: 'Gender',
                    child: _GenderField(
                      value: _gender,
                      onChanged: (g) => setState(() => _gender = g),
                    ),
                  ),
                  _Field(
                    label: 'Location',
                    child: _Input(controller: _location, hint: 'City, Country'),
                  ),
                  _Field(
                    label: 'Bio',
                    child: _Input(
                      controller: _bio,
                      hint: 'A little about you',
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  LsButton(
                    label: 'Save Changes',
                    icon: Icons.check_rounded,
                    loading: saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.url, required this.onTap});

  final String? url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = url != null && url!.isNotEmpty;
    return Stack(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasPhoto ? null : HomeStyle.scoreGradient,
            image: hasPhoto
                ? DecorationImage(
                    image: NetworkImage(url!), fit: BoxFit.cover)
                : null,
            boxShadow: HomeStyle.softShadow,
          ),
          child: hasPhoto
              ? null
              : const Icon(Icons.person_rounded, size: 44, color: Colors.white),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: HomeStyle.primary,
            shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.camera_alt_rounded,
                    size: 15, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.error});

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: HomeStyle.inkSoft,
              ),
            ),
          ),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, top: 6),
              child: Text(
                error!,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFB91C1C)),
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration _fieldBox() => BoxDecoration(
      color: HomeStyle.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      border: Border.all(color: HomeStyle.border),
    );

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _fieldBox(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14.5, color: HomeStyle.ink),
        cursorColor: HomeStyle.primary,
        decoration: InputDecoration(
          isDense: true,
          // The white field container is the background; disable the global
          // filled InputDecorationTheme so it never paints a grey/dark fill.
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: HomeStyle.inkSoft, fontSize: 14.5),
        ),
      ),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: HomeStyle.border),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.5, color: HomeStyle.inkSoft),
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              size: 16, color: HomeStyle.inkSoft),
        ],
      ),
    );
  }
}

class _TapValue extends StatelessWidget {
  const _TapValue({
    required this.text,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final bool placeholder;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        decoration: _fieldBox(),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.5,
                  color: placeholder ? HomeStyle.inkSoft : HomeStyle.ink,
                ),
              ),
            ),
            Icon(icon, size: 18, color: HomeStyle.primary),
          ],
        ),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.value, required this.onChanged});

  final Gender? value;
  final ValueChanged<Gender?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _fieldBox(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Gender>(
          value: value,
          isExpanded: true,
          hint: const Text('Select',
              style: TextStyle(fontSize: 14.5, color: HomeStyle.inkSoft)),
          icon: const Icon(Icons.expand_more_rounded, color: HomeStyle.primary),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          style: const TextStyle(fontSize: 14.5, color: HomeStyle.ink),
          items: [
            for (final g in Gender.values)
              DropdownMenuItem(value: g, child: Text(g.label)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
