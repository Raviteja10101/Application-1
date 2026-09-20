import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            100,
          ),
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Customize your Knot Habits experience.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('PREFERENCES'),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _SettingsSwitchTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Receive habit reminders',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('ABOUT'),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Knot Habits',
                  subtitle: 'About the app',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),

                _buildDivider(),

                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How your data is handled',
                  onTap: () {
                    _showComingSoon('Privacy Policy');
                  },
                ),

                _buildDivider(),

                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Use',
                  subtitle: 'Terms and conditions',
                  onTap: () {
                    _showComingSoon('Terms of Use');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('APP'),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.tag,
                  title: 'Version',
                  subtitle: '1.0.0',
                  showArrow: false,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                'Knot Habits',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),

            const SizedBox(height: 4),

            const Center(
              child: Text(
                'Build better habits. One link at a time.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDDE3F8),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Color(0xFFE5E7EB),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Knot Habits',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Knot Habits is a simple habit tracker '
            'designed to help you build consistent '
            'daily routines.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title will be added later.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================
// SETTINGS TILE
// ============================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EBFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 21,
                color: const Color(0xFF515BE8),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SWITCH TILE
// ============================================================

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EBFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 21,
              color: const Color(0xFF515BE8),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF00865A),
          ),
        ],
      ),
    );
  }
}