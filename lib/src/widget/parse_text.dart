part of '../parser.dart';

class UnderlinePainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double underlineOffset;
  final double underlineThickness;
  final Color underlineColor;

  UnderlinePainter({
    required this.text,
    required this.style,
    this.underlineOffset = 0.0,
    this.underlineThickness = 1.0,
    this.underlineColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = underlineColor
      ..strokeWidth = underlineThickness
      ..style = PaintingStyle.stroke;

    // Draw the underline with custom offset
    final y = size.height + underlineOffset;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(UnderlinePainter oldDelegate) {
    return oldDelegate.underlineOffset != underlineOffset ||
        oldDelegate.underlineThickness != underlineThickness ||
        oldDelegate.underlineColor != underlineColor;
  }
}

InlineSpan _parseText(Map<String, dynamic> child, TextStyle textStyle,
    bool useMyStyle, LineType? lineType, BuildContext context) {
  final baseStyle = _textStyle(child['format'], textStyle, useMyStyle);
  final fontSize = baseStyle.fontSize ?? 12;

  InlineSpan mainSpan;

  if (_isSubscript(child['format'])) {
    mainSpan = WidgetSpan(
      child: Transform.translate(
        offset: const Offset(0, 5),
        child: Text(
          child['text'],
          style: baseStyle.copyWith(
            fontSize: fontSize,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  } else if (_isSuperscript(child['format'])) {
    mainSpan = WidgetSpan(
      child: Transform.translate(
        offset: const Offset(0, -5),
        child: Text(
          child['text'],
          style: baseStyle.copyWith(
            fontSize: fontSize,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  } else {
    if (child['text'].startsWith('     ')) {
      mainSpan = TextSpan(
        children: [
          const WidgetSpan(child: SizedBox(width: 25)),
          TextSpan(
              text: child['text'].substring(5)) // Обрезаем первые 5 пробелов
        ],
        style: baseStyle,
      );
    } else {
      final style = lineType == LineType.h1
          ? Theme.of(context).textTheme.headlineLarge
          : lineType == LineType.h2
              ? Theme.of(context).textTheme.headlineMedium
              : lineType == LineType.h3
                  ? Theme.of(context).textTheme.headlineSmall
                  : lineType == LineType.paragraph
                      ? Theme.of(context).textTheme.bodyMedium
                      : baseStyle;

      final span = TextSpan(
        text: child['text'],
        style: style,
      );

      return span;

      // TextStyle linkStyle = TextStyle(
      //     color: Colors.transparent,
      //     decorationColor: style?.color,
      //     decoration: TextDecoration.underline,
      //     decorationThickness: style?.fontWeight == FontWeight.bold ? 2.0 : 1.0,
      //     // height: style?.height,
      //     // height: 2,
      //     // textBaseline: TextBaseline.ideographic,
      //     shadows: [
      //       Shadow(
      //           color: style?.color ?? Colors.black,
      //           offset:
      //               Offset(0, style?.fontWeight == FontWeight.bold ? -3 : -1))
      //     ],
      //     fontSize: 14.0);

      if (style?.decoration == TextDecoration.underline) {
        // mainSpan = WidgetSpan(
        //   baseline: TextBaseline.alphabetic,
        //   child: CustomPaint(
        //     painter: UnderlinePainter(
        //       text: child['text'],
        //       style: style ?? TextStyle(fontSize: 20),
        //       underlineOffset: 10.0, // Adjust this
        //       underlineThickness: 10.0,
        //     ),
        //     child: Text(
        //       child['text'],
        //       style: style,
        //     ),
        //   ),
        // );
        // mainSpan = WidgetSpan(
        //   alignment: PlaceholderAlignment.baseline,
        //   baseline: TextBaseline.alphabetic,
        //   child: Container(
        //     // 1. The Gap (Offset)
        //     padding: const EdgeInsets.only(bottom: 0.0),
        //     decoration: BoxDecoration(
        //       // 2. The Line (Underline)
        //       border: Border(
        //         bottom: BorderSide(
        //           color: style?.color ?? Theme.of(context).colorScheme.primary,
        //           width: style?.decorationThickness ?? 1.0, // Thickness
        //         ),
        //       ),
        //     ),
        //     child: Text(
        //       child['text'].toString().substring(0, child['text'].length - 10),
        //       style: TextStyle(
        //         color: style?.color,
        //         fontSize: style?.fontSize,
        //         fontWeight: style?.fontWeight,
        //         fontStyle: style?.fontStyle,
        //       ),
        //     ),
        //   ),
        // );

        // mainSpan = TextSpan(
        //   text: child['text'],
        //   // style: style?.copyWith(
        //   //     background: underlinePaint, decoration: TextDecoration.none),
        //   // style: TextStyle(
        //   //   // 4. Apply the paint to the background
        //   //   background: underlinePaint,
        //   //   // Ensure text is drawn on top of the background
        //   //   color: style?.color,
        //   // ),
        //   style: linkStyle,
        // );
      } else {
        mainSpan = span;
      }
    }
  }
  return mainSpan;
}

bool _isSuperscript(int? format) {
  return format != null && (format & 64) != 0;
}

bool _isSubscript(int? format) {
  return format != null && (format & 32) != 0;
}

TextStyle _textStyle(int? format, TextStyle style, bool useMyStyle) {
  final textStyle = style;
  FontStyle fontStyle = FontStyle.normal;
  bool isStrikethrough = false;
  bool isUnderline = false;
  Color? boldColor;
  bool isBold = false;

  if (format == null) {
    return style;
  }
  if (format & 1 != 0) {
    isBold = true;
    boldColor = Colors.white;
  }

  if (format & 2 != 0) fontStyle = FontStyle.italic;
  if (format & 4 != 0) isStrikethrough = true;
  if (format & 8 != 0) {
    isUnderline = true;
  }

  return

      //  isUnderline    ?

      textStyle.copyWith(
    color: Colors.transparent,
    decorationColor: boldColor ?? style.color,
    decoration: isUnderline
        ? TextDecoration.underline
        : isStrikethrough
            ? TextDecoration.lineThrough
            : null,
    decorationThickness: isBold ? 2.0 : 1.0,
    shadows: [
      Shadow(
          color: boldColor ?? style.color ?? Colors.black,
          offset: Offset(0, isBold ? -1.5 : -1))
    ],
    fontSize: isBold ? style.fontSize! - 0.5 : style.fontSize,
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    fontStyle: fontStyle,
  );
  // : textStyle.copyWith(
  //     // height: 1.6,
  //     color: boldColor ?? style.color,
  //     fontWeight: useMyStyle
  //         ? null
  //         : isBold
  //             ? FontWeight.bold
  //             : FontWeight.normal,
  //     fontStyle: useMyStyle ? null : fontStyle,
  //     decoration: isStrikethrough
  //         ? TextDecoration.lineThrough
  //         : isUnderline
  //             ? TextDecoration.underline
  //             : null,
  //   );
}
