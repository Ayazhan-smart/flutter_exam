import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:book_tracker/blocs/auth/auth_bloc.dart';
import 'package:book_tracker/blocs/user/user_bloc.dart';
import 'package:book_tracker/components/animated_widgets.dart';
import 'package:book_tracker/models/user.dart';
import 'package:book_tracker/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // ignore: use_build_context_synchronously
      context.read<UserBloc>().add(UpdateAvatar(image));
    }
  }

  void _toggleEdit(User user) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _nameController.text = user.name;
        _bioController.text = user.bio ?? '';
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserBloc>().add(
        UpdateProfile(
          name: _nameController.text,
          bio: _bioController.text,
        ),
      );
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoaded) {
          final user = state.user;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  FadeSlideAnimation(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60.r,
                          // ignore: deprecated_member_use
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Icon(Icons.person, size: 60.r, color: kPrimaryColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18.r,
                            backgroundColor: kPrimaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              iconSize: 18.r,
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (_isEditing)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeSlideAnimation(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: l10n.name,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? l10n.nameRequired : null,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          FadeSlideAnimation(
                            child: TextFormField(
                              controller: _bioController,
                              decoration: InputDecoration(
                                labelText: l10n.bio,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        FadeSlideAnimation(
                          child: Text(
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (user.bio != null) ...[
                          SizedBox(height: 8.h),
                          FadeSlideAnimation(
                            child: Text(
                              user.bio!,
                              style: TextStyle(
                                fontSize: 16.sp,
                                // ignore: deprecated_member_use
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  SizedBox(height: 24.h),
                  FadeSlideAnimation(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          _StatisticTile(
                            icon: Icons.book,
                            title: l10n.booksRead,
                            value: user.booksRead.toString(),
                          ),
                          if (user.favoriteGenre != null)
                            _StatisticTile(
                              icon: Icons.category,
                              title: l10n.favoriteGenre,
                              value: user.favoriteGenre!,
                            ),
                          _StatisticTile(
                            icon: Icons.calendar_today,
                            title: l10n.memberSince,
                            value: l10n.memberSinceDate(user.joinedAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeSlideAnimation(
                        child: ElevatedButton.icon(
                          onPressed: () => _isEditing ? _saveProfile() : _toggleEdit(user),
                          icon: Icon(_isEditing ? Icons.save : Icons.edit),
                          label: Text(_isEditing ? l10n.save : l10n.editProfile),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      FadeSlideAnimation(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(SignOut());
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.logout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Text(
            l10n.errorLoadingProfile,
            style: TextStyle(color: Colors.red, fontSize: 16.sp),
          ),
        );
      },
    );
  }
}

class _StatisticTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatisticTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}