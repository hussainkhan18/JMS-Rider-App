import 'package:flutter/material.dart';

// const appColor = Color(0xff00C0C8);
const appColor = Color(0xff073f6f);

// inputTextFieldDecoration(val, icn) {
//   return InputDecoration(
//     contentPadding: EdgeInsets.all(10),
//     labelText: '$val',
//     hint: Text('$val'),
//     floatingLabelStyle: TextStyle(color: Colors.grey),
//     suffixIcon: icn != '' ? Icon(icn, color: appColor) : null,
//     floatingLabelBehavior: FloatingLabelBehavior.auto,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//     enabledBorder: UnderlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(width: 2, color: (Colors.grey[300])!)),
//     focusedBorder:
//         UnderlineInputBorder(borderSide: BorderSide(width: 2, color: appColor)),
//   );
// }

InputDecoration inputTextFieldDecoration(
  String val,
  IconData? icn, {
  IconData? suffixIcn,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(14),
    labelText: val,
    floatingLabelStyle: const TextStyle(color: Colors.grey),
    prefixIcon: icn != null ? Icon(icn) : null,
    prefixIconColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return appColor;
      }
      return Colors.grey;
    }),
    suffixIcon: suffixIcn != null ? Icon(suffixIcn) : null,
    suffixIconColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return appColor;
      }
      return Colors.grey;
    }),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.grey,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 2,
        color: appColor,
      ),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  );
}

simpleButton() {
  return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: appColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      elevation: 0,
      textStyle: const TextStyle(
          fontFamily: 'medium', letterSpacing: 0.5, fontSize: 16));
}

outlineButton() {
  return OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      elevation: 0,
      textStyle: const TextStyle(
        fontFamily: 'medium',
        letterSpacing: 0.5,
        fontSize: 16,
      ));
}

BoxDecoration shadowContainer({
  required Color startColor,
  required Color endColor,
}) {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
    gradient: LinearGradient(
      colors: [
        startColor,
        endColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    color: Colors.white,
  );
}

pageTitle() {
  return TextStyle(color: Colors.black, fontFamily: 'semi-bold', fontSize: 20);
}

roundImage(val) {
  return BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.all(Radius.circular(16)),
      image: DecorationImage(image: AssetImage('$val'), fit: BoxFit.cover));
}

bottomBorder() {
  return BoxDecoration(
      border: Border(bottom: BorderSide(width: 1, color: (Colors.grey[300])!)));
}

offContainer() {
  return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      color: Color.fromARGB(255, 255, 185, 48));
}

offLabel() {
  return TextStyle(color: Colors.white, fontFamily: 'medium');
}
