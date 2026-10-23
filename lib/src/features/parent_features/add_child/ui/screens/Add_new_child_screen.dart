// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/app_screen_template.dart';
import 'package:elfulk/src/core/widgets/custom_text_field.dart';
import 'package:elfulk/src/core/widgets/primary_button.dart';

class AddNewChildScreen extends StatefulWidget {
  const AddNewChildScreen({super.key});

  @override
  State<AddNewChildScreen> createState() => _AddNewChildScreenState();
}

class _AddNewChildScreenState extends State<AddNewChildScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _childInfoController = TextEditingController(
    text: 'محمد منشي - ذكر / 21 سنة',
  );
  final TextEditingController _childNameController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _showDemoChildRow = true;

  @override
  void dispose() {
    _childInfoController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _selectedBirthDate ?? DateTime(now.year - 5, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        final ThemeData theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: theme.colorScheme.surface,
              headerForegroundColor: theme.colorScheme.onSurface,
              dayForegroundColor: WidgetStatePropertyAll(
                theme.colorScheme.onSurface,
              ),
              dayOverlayColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              todayForegroundColor: WidgetStatePropertyAll(
                theme.colorScheme.primary,
              ),
              todayBorder: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
      });
    }
  }

  String _formatBirthDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _removeDemoChildRow() {
    setState(() {
      _showDemoChildRow = false;
      _childInfoController.clear();
    });
    _showMessage('تم حذف بيانات الطفل.');
  }

  void _addAnotherChild() {
    setState(() {
      _showDemoChildRow = true;
      _childInfoController.clear();
      _childNameController.clear();
      _selectedGender = null;
      _selectedBirthDate = null;
    });
    _formKey.currentState?.reset();
    _showMessage('أدخل بيانات الطفل الجديد.');
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_childNameController.text.trim().isEmpty) {
      _showMessage('أدخل اسم طفلك.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _showMessage('تمت إضافة الطفل.');
    context.go(Routes.homeScreen);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppScreenTemplate(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'أضف طفلك وخصص تجربته',
              style:
                  theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ) ??
                  TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: context.spacing.s.h),
            Text(
              'أدخل اسم طفلك وعمره لنهيئ له محتوى يناسبه تمامًا.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                  ) ??
                  TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                  ),
            ),
            SizedBox(height: context.spacing.lg.h),
            Text(
              'الطفل الأول',
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ) ??
                  TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: 8.h),
            if (_showDemoChildRow)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('add-child-info-row'),
                        controller: _childInfoController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(context.spacing.m.r),
                            child: SvgPicture.asset(AssetsPathHelper.profile),
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.all(context.spacing.m.r),
                            child: SvgPicture.asset(
                              AssetsPathHelper.edit,
                              width: 18.w,
                              height: 18.h,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          hintText: 'الطفل الأول',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: context.spacing.md.h,
                            horizontal: context.spacing.md.w,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(context.radius.xl.r),
                            ),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(context.radius.xl.r),
                            ),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.spacing.sm.w),
                    SizedBox(
                      width: 48.w,
                      child: OutlinedButton(
                        key: const ValueKey('add-child-delete-row'),
                        onPressed: _removeDemoChildRow,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: theme.colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(context.radius.xl.r),
                            ),
                          ),
                        ),
                        child: SvgPicture.asset(
                          AssetsPathHelper.trash,
                          width: 18.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.error,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: context.spacing.md.h),
            CustomTextField(
              controller: _childNameController,
              hintText: 'اسم طفلك',
              prefixIcon: SvgPicture.asset(AssetsPathHelper.profile),
            ),
            SizedBox(height: context.spacing.md.h),
            _buildDropdownField(
              hintText: 'الجنس',
              iconPath: AssetsPathHelper.gender,
              value: _selectedGender,
              items: const <String>['ذكر', 'أنثى'],
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار الجنس';
                }
                return null;
              },
            ),
            SizedBox(height: context.spacing.md.h),
            _buildDateField(),
            SizedBox(height: context.spacing.lg.h),
            PrimaryButton(
              text: 'الانتقال إلى لوحة التحكم',
              icon: SvgPicture.asset(AssetsPathHelper.login),
              rtlIcon: false,
              onPressed: _submit,
            ),
            SizedBox(height: context.spacing.md.h),
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: OutlinedButton(
                key: const ValueKey('add-child-another'),
                onPressed: _addAnotherChild,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.radius.xxl.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetsPathHelper.profileAdd,
                      width: 18.w,
                      height: 18.h,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.spacing.sm.w),
                    Text(
                      'إضافة طفل آخر',
                      style:
                          theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ) ??
                          TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String iconPath,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?) validator,
  }) {
    final ThemeData theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: const SizedBox.shrink(),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 13.sp,
            ) ??
            TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 13.sp,
            ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(context.spacing.m.r),
          child: SvgPicture.asset(iconPath),
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          size: 22.sp,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          vertical: context.spacing.md.h,
          horizontal: context.spacing.md.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.xl.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.xl.r),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.xl.r),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
      items: items
          .map(
            (String item) =>
                DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
    );
  }

  Widget _buildDateField() {
    final ThemeData theme = Theme.of(context);
    final String displayText = _selectedBirthDate == null
        ? 'تاريخ الميلاد'
        : _formatBirthDate(_selectedBirthDate!);

    return FormField<String>(
      validator: (_) {
        if (_selectedBirthDate == null) {
          return 'الرجاء اختيار تاريخ الميلاد';
        }
        return null;
      },
      builder: (FormFieldState<String> fieldState) {
        return GestureDetector(
          onTap: () async {
            await _pickBirthDate();
            fieldState.validate();
          },
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'تاريخ الميلاد',
              hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 13.sp,
                  ) ??
                  TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 13.sp,
                  ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(context.spacing.m.r),
                child: SvgPicture.asset(AssetsPathHelper.calendar),
              ),
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                size: 20.sp,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: EdgeInsets.symmetric(
                vertical: context.spacing.md.h,
                horizontal: context.spacing.md.w,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.xl.r),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.xl.r),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.xl.r),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
            ),
            isEmpty: _selectedBirthDate == null,
            child: Text(
              displayText,
              style:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedBirthDate == null
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    color: _selectedBirthDate == null
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface,
                  ),
            ),
          ),
        );
      },
    );
  }
}
