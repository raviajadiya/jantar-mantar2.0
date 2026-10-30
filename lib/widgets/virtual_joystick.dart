import 'package:flutter/material.dart';

/// Virtual Joystick and Sprint control widget for mobile gameplay
class VirtualJoystick extends StatefulWidget {
  final Function(Offset direction) onDirectionChanged;
  final Function(bool isSprinting) onSprintChanged;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    required this.onSprintChanged,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobOffset = Offset.zero;
  static const double _maxRadius = 38.0;
  bool _isSprinting = false;

  void _updateKnob(Offset localPosition) {
    final distance = localPosition.distance;
    if (distance > _maxRadius) {
      _knobOffset = Offset(
        (localPosition.dx / distance) * _maxRadius,
        (localPosition.dy / distance) * _maxRadius,
      );
    } else {
      _knobOffset = localPosition;
    }

    final normalized = Offset(
      _knobOffset.dx / _maxRadius,
      _knobOffset.dy / _maxRadius,
    );
    widget.onDirectionChanged(normalized);
  }

  void _resetKnob() {
    setState(() {
      _knobOffset = Offset.zero;
    });
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Virtual Joystick Base
          GestureDetector(
            onPanStart: (details) {
              _updateKnob(details.localPosition - const Offset(55, 55));
              setState(() {});
            },
            onPanUpdate: (details) {
              _updateKnob(details.localPosition - const Offset(55, 55));
              setState(() {});
            },
            onPanEnd: (_) => _resetKnob(),
            onPanCancel: () => _resetKnob(),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xB30F172A),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Transform.translate(
                  offset: _knobOffset,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                      ),
                      border: Border.all(color: Colors.white, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Sprint Button
          GestureDetector(
            onTapDown: (_) {
              setState(() => _isSprinting = true);
              widget.onSprintChanged(true);
            },
            onTapUp: (_) {
              setState(() => _isSprinting = false);
              widget.onSprintChanged(false);
            },
            onTapCancel: () {
              setState(() => _isSprinting = false);
              widget.onSprintChanged(false);
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isSprinting
                      ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                      : [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: _isSprinting
                        ? const Color(0x80EF4444)
                        : const Color(0x66F59E0B),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 18)),
                    Text(
                      'RUN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
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
