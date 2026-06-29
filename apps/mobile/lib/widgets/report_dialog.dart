import 'package:flutter/material.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';

/// 回報 Dialog（prd §F05 / §4.3）：回報類型 3 選 1 + 備註。
class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportType _type = ReportType.wrongLocation;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('回報錯誤'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...ReportType.values.map(
            (t) => RadioListTile<ReportType>(
              value: t,
              groupValue: _type,
              title: Text(t.label, style: AppTextStyles.addressPhone),
              onChanged: (v) => setState(() => _type = v!),
            ),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: '備註（選填）'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            (type: _type, note: _noteController.text),
          ),
          child: const Text('送出'),
        ),
      ],
    );
  }
}
