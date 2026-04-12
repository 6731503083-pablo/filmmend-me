import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Diagonal clipped movie poster mosaic — shared across Splash, Login, Register.
class MovieMosaicHeader extends StatelessWidget {
  final double heightFactor;

  const MovieMosaicHeader({super.key, this.heightFactor = 0.48});

  static const _mosaicColors = [
    [Color(0xFF8B2020), Color(0xFFD44000)],
    [Color(0xFF1A3A8B), Color(0xFF2E6ECC)],
    [Color(0xFF2A5C2A), Color(0xFF4ABD4A)],
    [Color(0xFF5C2A8B), Color(0xFF9B5ECC)],
    [Color(0xFF8B4A1A), Color(0xFFD48C3D)],
    [Color(0xFF1A5C5C), Color(0xFF3DCCCC)],
    [Color(0xFF8B1A4A), Color(0xFFCC3D7A)],
    [Color(0xFF1A4A5C), Color(0xFF3D8FCC)],
    [Color(0xFF4A5C1A), Color(0xFF8FCC3D)],
    [Color(0xFF5C1A1A), Color(0xFFCC5C3D)],
    [Color(0xFF1A1A5C), Color(0xFF5C5ECC)],
    [Color(0xFF3A5C1A), Color(0xFF7ACC3D)],
  ];

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).size.height * heightFactor;
    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          // Clipped mosaic grid
          ClipPath(
            clipper: _DiagonalClipper(),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 0.65,
              children: _mosaicColors
                  .map((pair) => _PosterTile(colors: pair))
                  .toList(),
            ),
          ),
          // Bottom gradient fade into dark background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: headerHeight * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.65),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterTile extends StatelessWidget {
  final List<Color> colors;
  const _PosterTile({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          color: Colors.white.withValues(alpha: 0.07),
          size: 42,
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.80);
    path.lineTo(size.width, size.height * 0.55);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Three brand dots + rounded logo image + "Filmmend Me" text
class FilmmendBrandLogo extends StatelessWidget {
  final double imageSize;
  final double fontSize;

  const FilmmendBrandLogo({super.key, this.imageSize = 32, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(imageSize * 0.28),
          child: Image.asset(
            'assets/logo/app_icon.png',
            width: imageSize,
            height: imageSize,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Filmmend Me',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// App-branded accent button used on Splash, Login, Register.
class AccentButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const AccentButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic-free auth text field matching the mosaic screen style.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252840),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.35),
            size: 20,
          ),
          suffixIcon: onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
