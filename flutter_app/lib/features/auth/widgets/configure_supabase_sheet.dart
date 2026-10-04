import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/app_config.dart';
import '../../../data/datasources/auth_remote_ds.dart';
import '../../../shared/theme/app_colors.dart';

/// Shows an in-app setup modal allowing users to enter or paste their Supabase
/// project URL and anon public key without needing terminal rebuilds.
Future<void> showConfigureSupabaseDialog(
  BuildContext context, {
  VoidCallback? onConfigured,
}) {
  final isWide = MediaQuery.of(context).size.width > 600;
  if (isWide) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _ConfigureSupabaseModal(
            onConfigured: onConfigured,
            isDialog: true,
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ConfigureSupabaseModal(
      onConfigured: onConfigured,
      isDialog: false,
    ),
  );
}

class _ConfigureSupabaseModal extends StatefulWidget {
  final VoidCallback? onConfigured;
  final bool isDialog;

  const _ConfigureSupabaseModal({
    this.onConfigured,
    this.isDialog = false,
  });

  @override
  State<_ConfigureSupabaseModal> createState() =>
      _ConfigureSupabaseModalState();
}

class _ConfigureSupabaseModalState extends State<_ConfigureSupabaseModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _keyController;
  bool _isLoading = false;
  bool _showHelp = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: AppConfig.supabaseUrl);
    _keyController = TextEditingController(text: AppConfig.supabaseAnonKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _fillLocal() {
    setState(() {
      _urlController.text = 'http://127.0.0.1:54321';
      _keyController.text =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM0MTI4MDB9.CRX1xYZRswCEvx_mdfNmgXn_vpskIxfFwP8m_Xg_t8w';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = _urlController.text.trim();
      final key = _keyController.text.trim();

      await AuthRemoteDS.configure(url: url, anonKey: key);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.dasGreen,
            content: Text('Supabase authentication configured successfully!'),
          ),
        );
        widget.onConfigured?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: widget.isDialog
            ? BorderRadius.circular(20)
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: widget.isDialog
            ? Border.all(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.dividerLight.withValues(alpha: 0.5),
              )
            : null,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        widget.isDialog ? 24 : 20,
        24,
        24 + (widget.isDialog ? 0 : bottomInset),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar (bottom sheet only)
              if (!widget.isDialog) ...[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Title
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.derBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_outlined,
                      color: AppColors.derBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Supabase Auth',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Required for registration & cloud sync',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.dieRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.dieRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Project URL
              Text(
                'SUPABASE PROJECT URL',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _urlController,
                style: GoogleFonts.nunito(fontSize: 14, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'https://xxxxxxxx.supabase.co',
                  hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dividerLight.withValues(alpha: 0.8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.derBlue,
                      width: 1.6,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your Supabase URL';
                  }
                  if (!v.trim().startsWith('http://') &&
                      !v.trim().startsWith('https://')) {
                    return 'URL must start with https:// or http://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Anon Key
              Text(
                'SUPABASE ANON PUBLIC KEY',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _keyController,
                maxLines: 2,
                minLines: 1,
                style: GoogleFonts.nunito(fontSize: 13, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                  hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.dividerLight.withValues(alpha: 0.8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.derBlue,
                      width: 1.6,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your Supabase Anon Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quick fill buttons & guide
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _fillLocal,
                    icon: const Icon(Icons.computer, size: 16),
                    label: const Text('Local Docker'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.derBlue,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _showHelp = !_showHelp),
                    icon: Icon(
                      _showHelp ? Icons.expand_less : Icons.help_outline,
                      size: 16,
                    ),
                    label: Text(_showHelp ? 'Hide guide' : 'Where to find?'),
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              if (_showHelp) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.derBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.derBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to get your Supabase credentials:',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1. Go to supabase.com and open your project (or click "New project").\n'
                        '2. In the left sidebar, click Project Settings (gear icon) → API.\n'
                        '3. Copy the "Project URL" and the "anon public" key.\n'
                        '4. Paste both above and click "Save & Connect".',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          height: 1.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.derBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save & Connect',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
