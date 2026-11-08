import 'package:flutter_test/flutter_test.dart';
import 'package:sat_store_app/core/utils/formatters.dart';
import 'package:sat_store_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('aidana@'), isNotNull);
      expect(Validators.email('aidana@mail.kz'), isNull);
    });

    test('password', () {
      expect(Validators.loginPassword(''), isNotNull);
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('onlyletters'), isNotNull);
      expect(Validators.newPassword('Sat12345'), isNull);
    });

    test('phone', () {
      expect(Validators.phone('+7 (701) 234'), isNotNull);
      expect(Validators.phone('+7 (701) 234 56 78'), isNull);
    });

    test('postal code', () {
      expect(Validators.postalCode(''), isNull);
      expect(Validators.postalCode('0500'), isNotNull);
      expect(Validators.postalCode('050000'), isNull);
    });
  });

  group('Formatters', () {
    test('price', () {
      expect(Formatters.price(24900), '24\u00A0900\u00A0₸');
    });

    test('phone', () {
      expect(Formatters.formatPhone('7012345678'), '+7 (701) 234 56 78');
    });
  });
}
