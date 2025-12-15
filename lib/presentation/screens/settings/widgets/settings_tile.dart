// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

/// SettingsTile
/// Reusable list tile widget for settings screen.
/// Supports various tile types: navigation, switch, selection, info.
///
/// Features:
/// - Icon with customizable color
/// - Title and optional subtitle
/// - Multiple tile types (navigation, switch, value)
/// - Trailing icons/widgets
/// - Dividers
/// - Disabled state
class SettingsTile extends StatelessWidget {

  const SettingsTile({
    required this.title, super.key,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showDivider = true,
  });
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        ListTile(
          enabled: enabled,
          leading: icon != null
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).primaryColor)
                        .withValues (alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                )
              : null,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: enabled ? null : Colors.grey,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: enabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                )
              : null,
          trailing: trailing ??
              (onTap != null
                  ? Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    )
                  : null),
          onTap: enabled ? onTap : null,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
          ),
      ],
    );
}

/// SettingsSwitchTile
/// Settings tile with a switch control
class SettingsSwitchTile extends StatelessWidget {

  const SettingsSwitchTile({
    required this.title, required this.value, required this.onChanged, super.key,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.enabled = true,
    this.showDivider = true,
  });
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function({required bool value}) onChanged;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      showDivider: showDivider,
      trailing: Switch(
        value: value,
        onChanged: enabled ? (newValue) => onChanged(value: newValue) : null,
        activeThumbColor: iconColor ?? Theme.of(context).primaryColor,
      ),
      onTap: enabled ? () => onChanged(value: !value) : null,
    );
}

/// SettingsValueTile
/// Settings tile displaying a value
class SettingsValueTile extends StatelessWidget {

  const SettingsValueTile({
    required this.title, required this.value, super.key,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.showDivider = true,
  });
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      showDivider: showDivider,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
      onTap: onTap,
    );
}

/// SettingsActionTile
/// Settings tile for destructive actions
class SettingsActionTile extends StatelessWidget {

  const SettingsActionTile({
    required this.icon, required this.title, required this.onTap, super.key,
    this.subtitle,
    this.color = Colors.red,
    this.showDivider = true,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsTile(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      onTap: onTap,
    );
}

/// SettingsSectionHeader
/// Section header for grouping settings
class SettingsSectionHeader extends StatelessWidget {

  const SettingsSectionHeader({
    required this.title, super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
  });
  final String title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
}

/// SettingsCard
/// Card container for settings sections
class SettingsCard extends StatelessWidget {

  const SettingsCard({
    required this.children, super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
  final List<Widget> children;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) => Card(
      margin: margin,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
}

/// SettingsInfoTile
/// Informational tile without interaction
class SettingsInfoTile extends StatelessWidget {

  const SettingsInfoTile({
    required this.icon, required this.title, required this.value, super.key,
    this.iconColor,
    this.showDivider = true,
  });
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      showDivider: showDivider,
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
      ),
    );
}

/// SettingsSliderTile
/// Settings tile with slider control
class SettingsSliderTile extends StatelessWidget {

  const SettingsSliderTile({
    required this.title, required this.value, required this.onChanged, super.key,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.valueLabel,
    this.enabled = true,
  });
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueLabel;
  final void Function(double) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        ListTile(
          enabled: enabled,
          leading: icon != null
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).primaryColor)
                        .withValues (alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                )
              : null,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: enabled ? null : Colors.grey,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: enabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: valueLabel?.call(value) ?? value.toString(),
                onChanged: enabled ? onChanged : null,
                activeColor: iconColor ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ],
    );
}

/// SettingsCheckboxTile
/// Settings tile with checkbox
class SettingsCheckboxTile extends StatelessWidget {

  const SettingsCheckboxTile({
    required this.title, required this.value, required this.onChanged, super.key,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.enabled = true,
    this.showDivider = true,
  });
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function({required bool value}) onChanged;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => SettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      showDivider: showDivider,
      trailing: Checkbox(
        value: value,
        onChanged: enabled ? (newValue) => onChanged(value: newValue ?? false) : null,
        activeColor: iconColor ?? Theme.of(context).primaryColor,
      ),
      onTap: enabled ? () => onChanged(value: !value) : null,
    );
}