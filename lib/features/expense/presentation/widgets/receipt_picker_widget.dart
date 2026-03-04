import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/receipt_helper.dart';

class ReceiptPickerWidget extends StatelessWidget {
  final String? receiptPath;
  final ValueChanged<String?> onReceiptPicked;

  const ReceiptPickerWidget({
    super.key,
    this.receiptPath,
    required this.onReceiptPicked,
  });

  @override
  Widget build(BuildContext context) {
    if (receiptPath != null) {
      return _ReceiptPreview(
        path: receiptPath!,
        onRemove: () => onReceiptPicked(null),
      );
    }

    return _AttachButton(onReceiptPicked: onReceiptPicked);
  }
}

class _AttachButton extends StatelessWidget {
  final ValueChanged<String?> onReceiptPicked;

  const _AttachButton({required this.onReceiptPicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Attach receipt or bill',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Photo or PDF',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _OptionTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await ReceiptHelper.pickFromCamera();
                  if (file != null) onReceiptPicked(file.path);
                },
              ),
              _OptionTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await ReceiptHelper.pickFromGallery();
                  if (file != null) onReceiptPicked(file.path);
                },
              ),
              _OptionTile(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Pick a PDF',
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await ReceiptHelper.pickPdf();
                  if (file != null) onReceiptPicked(file.path);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _ReceiptPreview({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isPdf = path.toLowerCase().endsWith('.pdf');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: isPdf
                  ? Container(
                      color: Colors.red.shade50,
                      child: Icon(Icons.picture_as_pdf,
                          color: Colors.red.shade400, size: 28),
                    )
                  : Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPdf ? 'PDF Document' : 'Receipt Photo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Attached',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
