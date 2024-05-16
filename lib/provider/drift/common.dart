import 'package:drift/drift.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMicrosecondsSinceEpoch(fromDb);
  }

  @override
  int toSql(DateTime value) {
    return value.microsecondsSinceEpoch;
  }
}
