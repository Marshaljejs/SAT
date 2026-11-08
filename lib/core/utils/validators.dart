import 'formatters.dart';

class Validators {
  const Validators._();

  static final RegExp _email = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$');
  static final RegExp _letter = RegExp(r'[A-Za-z]');
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _postal = RegExp(r'^\d{6}$');

  static String? required(String? value, [String message = 'Бұл өрісті толтырыңыз']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Электрондық поштаны енгізіңіз';
    }
    if (!_email.hasMatch(value.trim())) {
      return 'Электрондық пошта дұрыс емес. Мысалы: example@mail.kz';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Құпиясөзді енгізіңіз';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Құпиясөзді енгізіңіз';
    }
    if (value.length < 8) {
      return 'Құпиясөз кемінде 8 таңбадан тұруы керек';
    }
    if (!_letter.hasMatch(value) || !_digit.hasMatch(value)) {
      return 'Латын әріптері мен кемінде бір санды қолданыңыз';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Құпиясөзді қайталаңыз';
      }
      if (value != original()) {
        return 'Құпиясөздер сәйкес келмейді';
      }
      return null;
    };
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Аты-жөніңізді енгізіңіз';
    }
    if (value.trim().length < 2) {
      return 'Аты-жөні тым қысқа';
    }
    return null;
  }

  static String? phone(String? value) {
    final digits = Formatters.localPhoneDigits(value ?? '');
    if (digits.isEmpty) {
      return 'Телефон нөмірін енгізіңіз';
    }
    if (digits.length != 10) {
      return 'Телефон нөмірін толық енгізіңіз';
    }
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_postal.hasMatch(value.trim())) {
      return 'Пошта индексі 6 саннан тұруы керек';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Бағаны енгізіңіз';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Бағаны дұрыс енгізіңіз';
    }
    if (parsed > 10000000) {
      return 'Баға тым үлкен';
    }
    return null;
  }

  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      return 'Сілтеме http:// немесе https:// деп басталуы керек';
    }
    return null;
  }

  static String? acceptTerms(bool? value) {
    if (value == true) {
      return null;
    }
    return 'Жалғастыру үшін шарттармен келісіңіз';
  }
}
