import 'package:flutter/material.dart';
import 'dart:math';

class FlipCardWidget extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback? onSwiped;
  final double width;
  final double height;

  const FlipCardWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.onSwiped,
    this.width = 326,
    this.height = 437,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _swipeController;

  bool _isFront = true;
  bool _isAnimating = false;

  Offset _dragOffset = Offset.zero;
  static const double _swipeThreshold = 120;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _toggleCard() async {
    if (_isAnimating) return;
    _isAnimating = true;

    if (_isFront) {
      await _flipController.forward();
      _isFront = false;
    } else {
      await _flipController.reverse();
      _isFront = true;
    }

    _isAnimating = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > _swipeThreshold) {
      _swipeController.forward().then((_) {
        widget.onSwiped?.call();
        _swipeController.reset();
        _dragOffset = Offset.zero;
      });
    } else {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _swipeController,
        builder: (context, child) {
          final slideX = _dragOffset.dx +
              _swipeController.value *
                  800 *
                  (_dragOffset.dx >= 0 ? 1 : -1);

          final rotate = _dragOffset.dx / 500;

          return Transform.translate(
            offset: Offset(slideX, 0),
            child: Transform.rotate(
              angle: rotate,
              child: child,
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _flipController,
          builder: (context, child) {
            double angle = _flipController.value * pi;
            if (!_isFront && _flipController.value == 0) {
              angle = pi;
            }

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: _flipController.value < 0.5
                  ? _buildFront()
                  : _buildBack(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.asset(
          widget.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image,
                    size: 60, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Transform(
      transform: Matrix4.rotationY(pi),
      alignment: Alignment.center,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromRGBO(43, 43, 43, 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromRGBO(210, 112, 255, 1),
                        fontFamily: 'Onest',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 60,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Onest',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
