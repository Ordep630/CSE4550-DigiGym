/// A workload prescription with explicit timing assumptions for the prototype.
class Exercise {
  final String name;
  final String description;
  final String sets;
  final int setCount;
  final int? repetitions;
  final int? secondsPerSet;
  final bool eachSide;
  final int secondsPerRepetition;
  final int restSeconds;
  final int transitionSeconds;

  const Exercise._({
    required this.name,
    required this.description,
    required this.sets,
    required this.setCount,
    this.repetitions,
    this.secondsPerSet,
    this.eachSide = false,
    this.secondsPerRepetition = 3,
    required this.restSeconds,
    this.transitionSeconds = 30,
  });

  /// Parses only the controlled catalogue, failing loudly for unknown formats.
  /// Timed ranges use their upper bound, so estimates do not undercount them.
  factory Exercise({
    required String name,
    required String sets,
    required String description,
    int restSeconds = 60,
  }) {
    final minutes = RegExp(r'^(\d+)(?:-(\d+))? minutes$').firstMatch(sets);
    if (minutes != null) {
      return Exercise._(
        name: name,
        description: description,
        sets: sets,
        setCount: 1,
        secondsPerSet: int.parse(minutes[2] ?? minutes[1]!) * 60,
        restSeconds: restSeconds,
      );
    }
    final prescription = RegExp(
      r'^(\d+) x (\d+)( seconds| each leg| each side)?$',
    ).firstMatch(sets);
    if (prescription == null) {
      throw ArgumentError('Unsupported exercise prescription: $sets');
    }
    final timed = prescription[3] == ' seconds';
    return Exercise._(
      name: name,
      description: description,
      sets: sets,
      setCount: int.parse(prescription[1]!),
      repetitions: timed ? null : int.parse(prescription[2]!),
      secondsPerSet: timed ? int.parse(prescription[2]!) : null,
      eachSide:
          prescription[3] == ' each leg' || prescription[3] == ' each side',
      restSeconds: restSeconds,
    );
  }

  int get workSeconds =>
      setCount *
      (secondsPerSet ??
          repetitions! * secondsPerRepetition * (eachSide ? 2 : 1));
  int get estimatedSeconds => workSeconds + (setCount - 1) * restSeconds;

  Exercise withVolume({required int count, int? timedSeconds}) {
    assert(count > 0);
    final seconds = timedSeconds ?? secondsPerSet;
    final String prescription;
    if (seconds != null &&
        secondsPerSet != null &&
        secondsPerSet! >= 120 &&
        count == 1) {
      prescription = seconds % 60 == 0
          ? '${seconds ~/ 60} minutes'
          : '$seconds seconds';
    } else if (seconds != null) {
      prescription = '$count x $seconds seconds';
    } else {
      final suffix = eachSide
          ? (sets.endsWith('each leg') ? ' each leg' : ' each side')
          : '';
      prescription = '$count x $repetitions$suffix';
    }
    return Exercise._(
      name: name,
      description: description,
      sets: prescription,
      setCount: count,
      repetitions: repetitions,
      secondsPerSet: seconds,
      eachSide: eachSide,
      secondsPerRepetition: secondsPerRepetition,
      restSeconds: restSeconds,
      transitionSeconds: transitionSeconds,
    );
  }
}
