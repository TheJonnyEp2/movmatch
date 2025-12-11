import 'package:flutter/material.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() async {
    if (_isAnimating) return;
    
    _isAnimating = true;
    
    if (_isFront) {
      // Переворот с лицевой на обратную сторону
      await _controller.forward();
      setState(() {
        _isFront = false;
      });
    } else {
      // Переворот с обратной на лицевую сторону
      await _controller.reverse();
      setState(() {
        _isFront = true;
      });
    }
    
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Dismissible(
        key: ValueKey(widget.imageUrl + widget.title + widget.description),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (widget.onSwiped != null) {
            widget.onSwiped!();
          }
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        secondaryBackground: Container(
          color: Colors.blue,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Используем value контроллера для анимации
              double angle = _controller.value * 3.14159;
              
              if (!_isFront && _controller.value == 0) {
                angle = 3.14159;
              }
              
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: _controller.value < 0.5 ? _buildFront() : _buildBack(),
              );
            },
          ),
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
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack() {
    // Обратная сторона изначально повернута на 180°
    return Transform(
      transform: Matrix4.rotationY(3.14159),
      alignment: Alignment.center,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromRGBO(43, 43, 43, 1),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 223, 223, 223).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromRGBO(210, 112, 255, 1),
                          fontFamily: 'Onest',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 60,
                        height: 2,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.description,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Onest',
                          fontSize: 14,
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
      ),
    );
  }
}