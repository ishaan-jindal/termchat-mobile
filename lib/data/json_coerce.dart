/// Lenient JSON scalar coercion. The wire format occasionally delivers
/// numbers as strings (or bools as 0/1); coerce instead of throwing
/// [TypeError] so one odd field doesn't sink a whole batch.
int? asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Lenient JSON bool coercion: accepts actual bools plus 0/1 and
/// true/false strings.
bool? asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is double) return value != 0;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
    }
  }
  return null;
}
