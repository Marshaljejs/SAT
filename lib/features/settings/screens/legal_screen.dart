import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_top_bar.dart';

class LegalArgs {
  const LegalArgs({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  static const LegalArgs privacy = LegalArgs(
    title: 'Құпиялық саясаты',
    paragraphs: [
      'SÄT тек тапсырысты рәсімдеу және жеткізу үшін қажетті деректерді жинайды: аты-жөні, телефон нөмірі, электрондық пошта және жеткізу мекенжайы.',
      'Деректеріңіз үшінші тұлғаларға тек тапсырысты жеткізу мақсатында ғана беріледі.',
      'Аккаунтыңызды және оған байланысты деректерді кез келген уақытта жоюды сұрай аласыз.',
    ],
  );

  static const LegalArgs terms = LegalArgs(
    title: 'Пайдалану шарттары',
    paragraphs: [
      'Қолданбаны пайдалану арқылы сіз тапсырысты рәсімдеу және жеткізу шарттарымен келісесіз.',
      'Тауарды алған күннен бастап 14 күн ішінде қайтаруға болады, егер ол пайдаланылмаған және қаптамасы сақталған болса.',
      'Жеткізу мерзімі Қазақстан бойынша 1–3 жұмыс күнін құрайды.',
    ],
  );
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.args});

  final LegalArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: args.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 8, AppDimens.pagePadding, 28),
        children: [
          Text(args.title, style: AppText.h1),
          const SizedBox(height: 16),
          for (final paragraph in args.paragraphs) ...[
            Text(paragraph, style: AppText.bodyGrey),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
