import 'dart:math';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReflectIcon extends StatefulWidget {
  final String toolTipNormal;
  final String toolTipTurned;
  bool pressed;
  final VoidCallback onPressed;
  ReflectIcon({this.toolTipNormal, this.toolTipTurned, this.pressed, this.onPressed});
  @override
  _ReflectIconState createState() => _ReflectIconState();
}

class _ReflectIconState extends State<ReflectIcon> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: widget.pressed ? 1 : 0,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    return Container(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform(
          transform: Matrix4.rotationX(_controller.value * pi),
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(Icons.expand_more),
            onPressed: () {
              widget.onPressed();
            },
            iconSize: 30,
            tooltip: widget.pressed ? widget.toolTipTurned : widget.toolTipNormal,
            splashRadius: 23,
          ),
        ),
      ),
    );
  }
}
