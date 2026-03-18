enum DrowsinessLevel {
  normal,
  tired,
  drowsy,
  critical,
}

class DrowsinessState {
  final DrowsinessLevel level;
  final double eyeClosureDuration;

  const DrowsinessState({
    required this.level,
    required this.eyeClosureDuration,
  });
}

