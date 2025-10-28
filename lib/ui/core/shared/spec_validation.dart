bool isNum(dynamic v) =>
    v != null && (v is num || num.tryParse(v.toString()) != null);

bool isValidSpec(dynamic v) {
  if (!isNum(v)) return false;
  final numVal = v is num ? v : num.tryParse(v.toString());
  return numVal != null && numVal != 0;
}