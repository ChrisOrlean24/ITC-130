import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/outline_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      context.read<UserProvider>().clearUser();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.user == null) {
            return const LoadingIndicator();
          }
          if (provider.error != null && provider.user == null) {
            return ErrorMessage(
              message: provider.error!,
              onRetry: provider.fetchProfile,
            );
          }
          final user = provider.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(Icons.person,
                          size: 50, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? '—',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '—',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                // Info tiles
                _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user?.phone ?? 'Not set'),
                const Divider(),
                _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member since',
                    value: user?.createdAt != null
                        ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                        : '—'),
                const SizedBox(height: 32),
                AppOutlineButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Sign Out',
                  backgroundColor: theme.colorScheme.error,
                  icon: Icons.logout,
                  onPressed: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
