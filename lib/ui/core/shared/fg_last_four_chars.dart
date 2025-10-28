String fgNoLast4(String? fgNo) {
  if (fgNo == null || fgNo.isEmpty) return "-";
  return fgNo.length <= 4 ? fgNo : fgNo.substring(fgNo.length - 4);
}
