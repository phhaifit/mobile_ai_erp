enum UnitGroup {
  weight('WEIGHT', 'Weight'),
  length('LENGTH', 'Length');

  const UnitGroup(this.code, this.name);

  // Stable unit group code.
  final String code;

  // Human-readable UI label.
  final String name;
}
