class TerminalLine {
  final String text;
  final bool isCommand;
  bool isAnimated;

  TerminalLine({
    required this.text,
    this.isCommand = false,
    this.isAnimated = false,
  });
}
