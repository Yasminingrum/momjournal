import 'package:flutter/material.dart';
import '/core/constants/color_constants.dart';

/// Custom Button Widget
/// Provides consistent button styling across the app
class CustomButton extends StatelessWidget {
  
  const CustomButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius = 8.0,
    this.type = ButtonType.elevated,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final ButtonType type;
  
  @override
  Widget build(BuildContext context) {
    final buttonPadding = padding ?? 
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    
    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );
    
    switch (type) {
      case ButtonType.elevated:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: elevation,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: backgroundColor ?? ColorConstants.primaryColor,
              side: BorderSide(
                color: backgroundColor ?? ColorConstants.primaryColor,
                width: 1.5,
              ),
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: backgroundColor ?? ColorConstants.primaryColor,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}

/// Button types
enum ButtonType {
  elevated,
  outlined,
  text,
}

/// Primary Button - Purple filled
class PrimaryButton extends StatelessWidget {
  
  const PrimaryButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  
  @override
  Widget build(BuildContext context) => CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: ColorConstants.primaryColor,
      textColor: ColorConstants.white,
      type: ButtonType.elevated,
    );
}

/// Secondary Button - Pink filled
class SecondaryButton extends StatelessWidget {
  
  const SecondaryButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  
  @override
  Widget build(BuildContext context) => CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: ColorConstants.secondaryColor,
      textColor: ColorConstants.white,
      type: ButtonType.elevated,
    );
}

/// Outline Button - Transparent with border
class OutlineButton extends StatelessWidget {
  
  const OutlineButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  
  @override
  Widget build(BuildContext context) => CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: color ?? ColorConstants.primaryColor,
      type: ButtonType.outlined,
    );
}

/// Danger Button - Red for destructive actions
class DangerButton extends StatelessWidget {
  
  const DangerButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;
  
  @override
  Widget build(BuildContext context) => CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: ColorConstants.error,
      textColor: outlined ? ColorConstants.error : ColorConstants.white,
      type: outlined ? ButtonType.outlined : ButtonType.elevated,
    );
}

/// Icon Button with background
class IconButtonWithBackground extends StatelessWidget {
  
  const IconButtonWithBackground({
    required this.icon, super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  
  @override
  Widget build(BuildContext context) => Material(
      color: backgroundColor ?? ColorConstants.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? ColorConstants.primaryColor,
          ),
        ),
      ),
    );
}