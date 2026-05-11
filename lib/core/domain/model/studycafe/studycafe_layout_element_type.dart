import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum StudyCafeLayoutElementType {
  partition('파티션'),
  door('문'),
  fixture('구조물')
  ;

  final String label;

  const StudyCafeLayoutElementType(this.label);
}
