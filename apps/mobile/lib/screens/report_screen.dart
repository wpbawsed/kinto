import 'package:flutter/material.dart';
import '../models/report.dart';
import '../models/resource.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'thank_you_screen.dart';

/// 回報錯誤（prd §F05 / §4.3，設計稿 2026-07-04 畫面④，全螢幕頁面取代原本的 AlertDialog）。
///
/// TODO: `userLat`/`userLng` 目前用固定假座標，待 GPS 定位套件（geolocator）
/// 串接後改為使用者當下位置。
class ReportScreen extends StatefulWidget {
  final Resource resource;
  final double userLat;
  final double userLng;

  const ReportScreen({
    super.key,
    required this.resource,
    this.userLat = 25.0375,
    this.userLng = 121.5637,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportType _type = ReportType.wrongLocation;
  final _noteController = TextEditingController();
  final _apiClient = ApiClient();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _apiClient.submitReport(ReportPayload(
        resourceId: widget.resource.id,
        reportType: _type,
        userLat: widget.userLat,
        userLng: widget.userLng,
        note: _noteController.text,
      ));
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThankYouScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送出失敗，請稍後再試')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('回報錯誤', style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3, offset: const Offset(0, 1))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: resource.type.lightBg, borderRadius: BorderRadius.circular(13)),
                            child: Icon(resource.type.icon, color: resource.type.pinColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resource.name, style: AppTextStyles.placeName.copyWith(fontSize: 17)),
                                if (resource.address != null) ...[
                                  const SizedBox(height: 2),
                                  Text(resource.address!, style: AppTextStyles.caption),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('這個資源有什麼問題？', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 12),
                    ...ReportType.values.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReasonCard(
                            type: t,
                            selected: _type == t,
                            onTap: () => setState(() => _type = t),
                          ),
                        )),
                    const SizedBox(height: 12),
                    const Text('補充說明（選填）', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '例如：實際位置在捷運站隔壁的市府轉運站一樓…',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border, width: 2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryCta, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 20, color: AppColors.successIcon),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              '將附上您目前的 GPS 座標（${widget.userLat.toStringAsFixed(4)}, ${widget.userLng.toStringAsFixed(4)}）作為修正建議',
                              style: const TextStyle(fontSize: 14, color: AppColors.successText, height: 1.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryCta,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('送出回報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  final ReportType type;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.aedBg : Colors.white,
            border: Border.all(color: selected ? AppColors.primaryCta : AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primaryCta : AppColors.borderStrong,
                size: 24,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF1565C0) : AppColors.textBody),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: TextStyle(fontSize: 13, color: selected ? AppColors.textSecondary : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
