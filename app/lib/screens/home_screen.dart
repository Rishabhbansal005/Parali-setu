import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models/user_profile.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'field_details_screen.dart';
import 'phone_login_screen.dart';

class HomeScreen extends StatefulWidget {
  final FarmerRepository repository;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLanguage;
  final bool isOffline;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.onLanguageChanged,
    required this.currentLanguage,
    this.isOffline = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await widget.repository.getProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      final cached = await widget.repository.getCachedProfile();
      if (mounted) {
        setState(() {
          _profile = cached;
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await widget.repository.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneLoginScreen(
          repository: widget.repository,
          onLanguageChanged: widget.onLanguageChanged,
          currentLanguage: widget.currentLanguage,
        ),
      ),
      (route) => false,
    );
  }

  void _onLanguageSelected(AppLanguage lang) async {
    widget.onLanguageChanged(lang);
    try {
      await _storage.write(key: AppConstants.keyLanguage, value: lang.code);
    } catch (_) {}
    try {
      await widget.repository.updateProfile(language: lang.code);
    } catch (_) {}
  }

  void _showEditProfileDialog() {
    final strings = AppStrings(widget.currentLanguage);
    final nameController = TextEditingController(text: _profile?.name ?? '');
    final villageController = TextEditingController(text: _profile?.village ?? '');
    final districtController = TextEditingController(text: _profile?.district ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.edit,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: strings.nameLabel,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: villageController,
                decoration: const InputDecoration(
                  labelText: 'Village',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final updated = await widget.repository.updateProfile(
                        name: nameController.text.trim(),
                        village: villageController.text.trim(),
                        district: districtController.text.trim(),
                      );
                      setState(() => _profile = updated);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text(strings.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.currentLanguage);

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Small offline banner if running without network
            if (widget.isOffline)
              Container(
                width: double.infinity,
                color: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.offlineBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _selectedTabIndex == 0 ? _buildHomeTab(strings) : _buildProfileTab(strings),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (idx) => setState(() => _selectedTabIndex = idx),
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: strings.homeTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: strings.profileTab,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(AppStrings strings) {
    final displayName = _profile?.name ?? (_isLoadingProfile ? '...' : 'Farmer');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting with user name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.welcomeFarmer(displayName),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
                child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Primary Hero Card: "Check my stubble value"
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.secondaryGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.wheatGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          strings.tonnesUnit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.currency_rupee, color: Colors.white70, size: 26),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.checkStubbleCardTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.checkStubbleCardSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('check_stubble_btn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.wheatGold,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FieldDetailsScreen(
                              repository: widget.repository,
                              onLanguageChanged: widget.onLanguageChanged,
                              currentLanguage: widget.currentLanguage,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(strings.estimateNowBtn),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // "How it works" Strip
          Text(
            strings.howItWorksHeading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          _buildStepCard(
            stepNumber: '1',
            icon: Icons.edit_location_alt_outlined,
            title: strings.step1Title,
            subtitle: strings.step1Desc,
          ),
          const SizedBox(height: 10),
          _buildStepCard(
            stepNumber: '2',
            icon: Icons.calculate_outlined,
            title: strings.step2Title,
            subtitle: strings.step2Desc,
          ),
          const SizedBox(height: 10),
          _buildStepCard(
            stepNumber: '3',
            icon: Icons.local_shipping_outlined,
            title: strings.step3Title,
            subtitle: strings.step3Desc,
            badge: strings.comingSoon,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.profileHeading,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Name Card (Editable)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
              title: Text(strings.nameLabel, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              subtitle: Text(
                _profile?.name ?? strings.notSpecified,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                onPressed: _showEditProfileDialog,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Phone Card (Read-only)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const Icon(Icons.phone, color: AppTheme.primaryGreen, size: 28),
              title: Text(strings.phoneLabel, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              subtitle: Text(
                _profile?.phone ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Village & District
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 28),
              title: Text(strings.villageDistrictLabel, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              subtitle: Text(
                '${_profile?.village ?? "Bhikhiwind"}, ${_profile?.district ?? "Tarn Taran"}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Language Selector
          Text(
            strings.chooseLanguage,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLangChip(strings.englishLabel, AppLanguage.english),
              const SizedBox(width: 8),
              _buildLangChip('हिंदी', AppLanguage.hindi),
              const SizedBox(width: 8),
              _buildLangChip('ਪੰਜਾਬੀ', AppLanguage.punjabi),
            ],
          ),

          const SizedBox(height: 24),

          // About Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD0DDD0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings.aboutTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  strings.aboutText,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Logout Button
          SizedBox(
            height: 56,
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningRed,
                side: const BorderSide(color: AppTheme.warningRed, width: 1.5),
              ),
              onPressed: _handleLogout,
              child: Text(strings.logout),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLangChip(String label, AppLanguage lang) {
    final isSelected = widget.currentLanguage == lang;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.textDark,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? AppTheme.primaryGreen : const Color(0xFFD0DDD0)),
      onSelected: (_) => _onLanguageSelected(lang),
    );
  }
}
