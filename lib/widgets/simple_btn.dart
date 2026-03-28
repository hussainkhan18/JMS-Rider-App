// import 'package:flutter/material.dart';
// import '../helper/style.dart' as style;

// class SimpleButton extends StatelessWidget {
//   final String btnName;
//   final VoidCallback onPressed;

//   SimpleButton({Key? key, required this.btnName, required this.onPressed})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.only(bottom: 24),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         child: Text(btnName),
//         style: style.simpleButton(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../helper/style.dart' as style;

class SimpleButton extends StatefulWidget {
  final Widget btnName;
  final VoidCallback onPressed;
  final double? width; // 👈 optional width

  const SimpleButton({
    Key? key,
    required this.btnName,
    required this.onPressed,
    this.width, // 👈 allow custom width
  }) : super(key: key);

  @override
  State<SimpleButton> createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(
        begin: 1.0,
        end: _isPressed ? 0.95 : 1.0,
      ),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: widget.width ?? double.infinity, // 👈 fallback full width
              margin: const EdgeInsets.only(bottom: 24),
              child: Material(
                color: style.appColor,
                borderRadius: BorderRadius.circular(14),
                elevation: 6,
                shadowColor: style.appColor.withOpacity(0.4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: widget.onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: widget.btnName,
                      // child: Text(
                      //   widget.btnName,
                      //   style: const TextStyle(
                      //     fontFamily: 'medium',
                      //     fontSize: 18,
                      //     letterSpacing: 0.8,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
