import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy', 'es_AR');
final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'es_AR');
final _numberFormat = NumberFormat.decimalPattern('es_AR');

String formatDate(DateTime date) => _dateFormat.format(date);

String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

String formatNumber(num value) => _numberFormat.format(value);
