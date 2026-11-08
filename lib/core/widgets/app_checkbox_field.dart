import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class AppCheckboxField extends FormField<bool> {
  AppCheckboxField({
    super.key,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (state) {
            void toggle() {
              final next = !(state.value ?? false);
              state.didChange(next);
              onChanged(next);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: toggle,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: state.value ?? false,
                          visualDensity: VisualDensity.compact,
                          onChanged: (_) => toggle(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(label, style: AppText.caption),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 34, top: 6),
                    child: Text(
                      state.errorText!,
                      style: AppText.caption.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
            );
          },
        );
}
