const List<String> _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

const List<String> _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// "jue 19 nov"
String fechaCorta(DateTime f) => '${_dias[f.weekday - 1]} ${f.day} ${_meses[f.month - 1]}';

/// "08:30 AM" a partir de "08:30"
String hora12(String hhmm) {
  final partes = hhmm.split(':');
  var h = int.parse(partes[0]);
  final m = partes[1];
  final ampm = h >= 12 ? 'PM' : 'AM';
  if (h == 0) h = 12;
  if (h > 12) h -= 12;
  return '${h.toString().padLeft(2, '0')}:$m $ampm';
}

/// "jue 19 nov · 08:30 AM"
String fechaHoraCorta(DateTime f) =>
    '${fechaCorta(f)} · ${hora12('${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}')}';
