enum WeekDay {
  monday('monday', '월'),
  tuesday('tuesday', '화'),
  wednesday('wednesday', '수'),
  thursday('thursday', '목'),
  friday('friday', '금'),
  saturday('saturday', '토'),
  sunday('sunday', '일')
  ;

  final String dbKey;
  final String label;

  const WeekDay(this.dbKey, this.label);
}
