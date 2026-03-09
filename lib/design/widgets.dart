import 'dart:io';

import 'package:flutter/material.dart';

import 'ds.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [DsColors.paper, Color(0xFFFCF9F2)],
            ),
          ),
          child: body,
        ),
      ),
    );
  }
}

class PaperCard extends StatelessWidget {
  const PaperCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: DsRadius.lg,
        color: const Color(0xCCFFFFFF),
        border: Border.all(color: DsColors.line),
        boxShadow: const [
          BoxShadow(color: DsColors.shadow, blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(DsSpace.md),
      child: child,
    );
  }
}

class CopperButton extends StatelessWidget {
  const CopperButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    if (hasIcon) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: DsColors.copper,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: DsRadius.md),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: DsColors.copper,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: DsRadius.md),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        trailingWidget ?? const SizedBox.shrink(),
      ],
    );
  }
}

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = DsRadius.md,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty || !File(path).existsSync()) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: DsColors.paperDeep,
          border: Border.all(color: DsColors.line),
        ),
        child: const Center(
          child: Icon(Icons.photo_outlined, color: DsColors.mutedInk),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: DsColors.paperDeep,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: DsColors.mutedInk),
          const SizedBox(height: DsSpace.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
