import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/text_constants.dart';

/// Loading Indicator Widget
/// Provides consistent loading states across the app
class LoadingIndicator extends StatelessWidget {
  
  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size = 40,
  }) : super(key: key);
  final String? message;
  final Color? color;
  final double size;
  
  @override
  Widget build(BuildContext context) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? ColorConstants.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
}

/// Small Loading Indicator
class SmallLoadingIndicator extends StatelessWidget {
  
  const SmallLoadingIndicator({
    Key? key,
    this.color,
  }) : super(key: key);
  final Color? color;
  
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? ColorConstants.primaryColor,
        ),
      ),
    );
}

/// Loading Overlay (covers entire screen)
class LoadingOverlay extends StatelessWidget {
  
  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);
  final bool isLoading;
  final Widget child;
  final String? message;
  
  @override
  Widget build(BuildContext context) => Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingIndicator(
              message: message ?? TextConstants.loading,
              color: Colors.white,
            ),
          ),
      ],
    );
}

/// Linear Loading Indicator (for progress)
class LinearLoadingIndicator extends StatelessWidget {
  
  const LinearLoadingIndicator({
    Key? key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 4,
  }) : super(key: key);
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  
  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? ColorConstants.grey200,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? ColorConstants.primaryColor,
        ),
      ),
    );
}

/// Shimmer Loading (for skeleton screens)
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? ColorConstants.shimmerBase,
                widget.highlightColor ?? ColorConstants.shimmerHighlight,
                widget.baseColor ?? ColorConstants.shimmerBase,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        ),
    );
  }
}

/// Skeleton Loading Card
class SkeletonLoadingCard extends StatelessWidget {
  
  const SkeletonLoadingCard({
    Key? key,
    this.height = 100,
    this.width,
    this.borderRadius = 12,
  }) : super(key: key);
  final double height;
  final double? width;
  final double borderRadius;
  
  @override
  Widget build(BuildContext context) => ShimmerLoading(
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: ColorConstants.grey300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
}

/// Skeleton Loading List
class SkeletonLoadingList extends StatelessWidget {
  
  const SkeletonLoadingList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 16,
  }) : super(key: key);
  final int itemCount;
  final double itemHeight;
  final double spacing;
  
  @override
  Widget build(BuildContext context) => ListView.separated(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return SkeletonLoadingCard(height: itemHeight);
      },
    );
}

/// Pulsing Dot Loading Indicator
class PulsingDotIndicator extends StatefulWidget {
  
  const PulsingDotIndicator({
    Key? key,
    this.color,
    this.size = 8,
    this.dotCount = 3,
  }) : super(key: key);
  final Color? color;
  final double size;
  final int dotCount;
  
  @override
  State<PulsingDotIndicator> createState() => _PulsingDotIndicatorState();
}

class _PulsingDotIndicatorState extends State<PulsingDotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size / 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color ?? ColorConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
}

/// Refresh Indicator Wrapper
class CustomRefreshIndicator extends StatelessWidget {
  
  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  
  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? ColorConstants.primaryColor,
      child: child,
    );
}