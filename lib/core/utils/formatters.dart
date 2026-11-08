import 'package:flutter/services.dart';

class Formatters {
  const Formatters._();

  static const List<String> _months = [
    'қаңтар',
    'ақпан',
    'наурыз',
    'сәуір',
    'мамыр',
    'маусым',
    'шілде',
    'тамыз',
    'қыркүйек',
    'қазан',
    'қараша',
    'желтоқсан',
  ];

  static const List<String> _monthsShort = [
    'қаң.',
    'ақп.',
    'нау.',
    'сәу.',
    'мам.',
    'мау.',
    'шіл.',
    'там.',
    'қыр.',
    'қаз.',
    'қар.',
    'жел.',
  ];

  static String price(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('\u00A0');
      }
      buffer.write(digits[i]);
    }
    final sign = value < 0 ? '−' : '';
    return '$sign$buffer\u00A0₸';
  }

  static String rating(double value) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String itemsCount(int count) => '$count тауар';

  static String localPhoneDigits(String text) {
    var digits = text.replaceAll(RegExp(r'\D'), '');
    if (text.trim().startsWith('+7') && digits.isNotEmpty) {
      digits = digits.substring(1);
    } else if (digits.length == 11 && (digits.startsWith('7') || digits.startsWith('8'))) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    return digits;
  }

  static String formatPhone(String text) {
    final digits = localPhoneDigits(text);
    if (digits.isEmpty) {
      return '';
    }
    final buffer = StringBuffer('+7 (');
    for (var i = 0; i < digits.length; i++) {
      if (i == 3) {
        buffer.write(') ');
      }
      if (i == 6 || i == 8) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String prettyPhone(String text) {
    final d = localPhoneDigits(text);
    if (d.length != 10) {
      return text;
    }
    return '+7 ${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, 8)} ${d.substring(8)}';
  }

  static String day(DateTime date) => '${date.day} ${_months[date.month - 1]}';

  static String dayYear(DateTime date) => '${day(date)} ${date.year}';

  static String dayShort(DateTime date) => '${date.day} ${_monthsShort[date.month - 1]}';

  static String range(DateTime from, DateTime to) => '${day(from)} – ${day(to)}';

  static String rangeShort(DateTime from, DateTime to) => '${dayShort(from)} – ${dayShort(to)}';

  static String time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = Formatters.formatPhone(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
