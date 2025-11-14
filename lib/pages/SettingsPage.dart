import 'package:flutter/material.dart';
import 'package:friendly_chat/pages/Help%20pages/Notification.dart';
import 'package:friendly_chat/pages/Help%20pages/PP.dart';
import 'package:friendly_chat/pages/password.dart';
import 'package:friendly_chat/pages/Help%20pages/Faq.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import '../Widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          "Settings",
          style: AppTheme.headingStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildHelpSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              "Settings",
              style: AppTheme.subheadingStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Noti()),
                  ),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: "Privacy and Security",
                  iconColor: AppTheme.errorColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Faq()),
                  ),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  icon: Icons.password_outlined,
                  title: "Change Password",
                  iconColor: AppTheme.errorColor,
                  onTap: () => goto(context, Password()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              "Help & Support",
              style: AppTheme.subheadingStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  title: "Frequently Asked Questions",
                  iconColor: AppTheme.primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Faq()),
                  ),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  iconColor: AppTheme.accentColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PP()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.primaryTextColor,
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.secondaryTextColor,
      ),
      onTap: onTap,
    );
  }
}
