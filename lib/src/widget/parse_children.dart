part of '../parser.dart';

List<Widget> parseJsonChildrenWidget(List<dynamic> children) {
  return children.map<Widget>(
    (child) {
      switch (child['type']) {
        case 'heading':
          return _ParseParagraph(
            child: child,
            lineType: child['tag'] == 'h1'
                ? LineType.h1
                : child['tag'] == 'h2'
                    ? LineType.h2
                    : child['tag'] == 'h3'
                        ? LineType.h3
                        : LineType.paragraph,
            // lineType: LineType.h1,
          );
        case 'paragraph':
          return _ParseParagraph(child: child);
        case 'quote':
          return _ParseParagraph(child: child);
        case 'table':
          return ParseTable(child: child);
        case 'list':
          return _ParseNumberedList(child: child);
        case 'listitem':
          return _ParseParagraph(child: child);

        default:
          return const SizedBox.shrink();
      }
    },
  ).toList();
}

List<InlineSpan> parseJsonChild(
    List<dynamic> children, BuildContext context, LineType? lineType) {
  final List<InlineSpan> widgets = [];
  final props = _PropsInheritedWidget.of(context)!;

  for (var child in children) {
    switch (child['type']) {
      case 'text':
        widgets.add(_parseText(
            child,
            props.paragraphStyle ?? Theme.of(context).textTheme.bodyMedium!,
            props.useMyTextStyle,
            lineType,
            context));
        break;
      case 'image':
        widgets.add(_parseImage(child, context));
        break;
      case 'equation':
        widgets.add(_parseEquation(child, options: props.mathEquationOptions));
        break;
      case 'linebreak':
        widgets.add(const TextSpan(text: '\n'));
        break;
      default:
        widgets.add(const WidgetSpan(child: SizedBox.shrink()));
        break;
    }
  }
  return widgets;
}
