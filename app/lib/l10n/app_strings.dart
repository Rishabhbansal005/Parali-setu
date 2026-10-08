library;

/// Centralized trilingual strings for ParaliSetu (English, Hindi, Punjabi).
///
/// English is the DEFAULT application language per SPEC.md §13.
/// NOTE: All Punjabi (Gurmukhi) translations are marked with
/// "/* NEEDS NATIVE REVIEW */" per Rule 6 and project instructions.

enum AppLanguage {
  english,
  hindi,
  punjabi;

  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.punjabi:
        return 'pa';
    }
  }

  static AppLanguage fromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'hi':
        return AppLanguage.hindi;
      case 'pa':
        return AppLanguage.punjabi;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }
}

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  bool get isEnglish => language == AppLanguage.english;
  bool get isHindi => language == AppLanguage.hindi;
  bool get isPunjabi => language == AppLanguage.punjabi;

  // ── App Brand ─────────────────────────────────────────────────────────────
  String get appTitle {
    switch (language) {
      case AppLanguage.english:
        return 'ParaliSetu';
      case AppLanguage.hindi:
        return 'पराली सेतु';
      case AppLanguage.punjabi:
        return 'ਪਰਾਲੀ ਸੇਤੂ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get tagline {
    switch (language) {
      case AppLanguage.english:
        return 'Turn stubble into earnings, protect your soil';
      case AppLanguage.hindi:
        return 'पराली बेचें, कमाई करें, खेत बचाएं';
      case AppLanguage.punjabi:
        return 'ਪਰਾਲੀ ਵੇਚੋ, ਕਮਾਈ ਕਰੋ, ਖੇਤ ਬਚਾਓ /* NEEDS NATIVE REVIEW */';
    }
  }

  // ── Language Labels ───────────────────────────────────────────────────────
  String get chooseLanguage {
    switch (language) {
      case AppLanguage.english:
        return 'Choose Language';
      case AppLanguage.hindi:
        return 'अपनी भाषा चुनें';
      case AppLanguage.punjabi:
        return 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get englishLabel => 'English';
  String get hindiLabel => 'हिंदी (Hindi)';
  String get punjabiLabel => 'ਪੰਜਾਬੀ (Punjabi)';

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingSlide1Title {
    switch (language) {
      case AppLanguage.english:
        return 'Do not burn it. Sell it.';
      case AppLanguage.hindi:
        return 'इसे जलाएं नहीं। बेचें।';
      case AppLanguage.punjabi:
        return 'ਇਸਨੂੰ ਸਾੜੋ ਨਾ। ਵੇਚੋ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get onboardingSlide1Desc {
    switch (language) {
      case AppLanguage.english:
        return 'Turn paddy stubble into guaranteed income instead of hazardous smoke and fines.';
      case AppLanguage.hindi:
        return 'पराली को धुएं और जुर्माने के बजाय निश्चित आमदनी में बदलें।';
      case AppLanguage.punjabi:
        return 'ਪਰਾਲੀ ਨੂੰ ਧੂੰਏਂ ਅਤੇ ਜੁਰਮਾਨੇ ਦੀ ਬਜਾਏ ਪੱਕੀ ਕਮਾਈ ਵਿੱਚ ਬਦਲੋ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get onboardingSlide2Title {
    switch (language) {
      case AppLanguage.english:
        return 'We find the machine, truck and buyer for you.';
      case AppLanguage.hindi:
        return 'हम आपके लिए मशीन, ट्रक और खरीदार लाते हैं।';
      case AppLanguage.punjabi:
        return 'ਅਸੀਂ ਤੁਹਾਡੇ ਲਈ ਮਸ਼ੀਨ, ਟਰੱਕ ਅਤੇ ਖਰੀਦਦਾਰ ਲੱਭਦੇ ਹਾਂ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get onboardingSlide2Desc {
    switch (language) {
      case AppLanguage.english:
        return 'One-stop bundling within your harvest window with zero coordination hassle.';
      case AppLanguage.hindi:
        return 'बिना किसी परेशानी के अपनी कटाई के समय में सब कुछ बुक करें।';
      case AppLanguage.punjabi:
        return 'ਬਿਨਾਂ ਕਿਸੇ ਝੰਜਟ ਦੇ ਆਪਣੀ ਕਟਾਈ ਦੇ ਸਮੇਂ ਸਭ ਕੁਝ ਬੁੱਕ ਕਰੋ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get onboardingSlide3Title {
    switch (language) {
      case AppLanguage.english:
        return 'Get paid on the actual weight, safely.';
      case AppLanguage.hindi:
        return 'सही वजन पर सुरक्षित भुगतान पाएं।';
      case AppLanguage.punjabi:
        return 'ਅਸਲ ਵਜ਼ਨ \'ਤੇ ਸੁਰੱਖਿਅਤ ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਕਰੋ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get onboardingSlide3Desc {
    switch (language) {
      case AppLanguage.english:
        return 'Certified weighbridge measurement with escrow-protected bank transfers.';
      case AppLanguage.hindi:
        return 'धर्मकांटा प्रमाणित वजन और सुरक्षित एस्क्रो बैंक भुगतान।';
      case AppLanguage.punjabi:
        return 'ਧਰਮਕੰਡੇ ਦੇ ਪ੍ਰਮਾਣਿਤ ਵਜ਼ਨ ਨਾਲ ਸੁਰੱਖਿਅਤ ਬੈਂਕ ਭੁਗਤਾਨ। /* NEEDS NATIVE REVIEW */';
    }
  }

  String get skip => isEnglish ? 'Skip' : (isHindi ? 'छोड़ें' : 'ਛੱਡੋ /* NEEDS NATIVE REVIEW */');
  String get next => isEnglish ? 'Next' : (isHindi ? 'आगे बढ़ें' : 'ਅੱਗੇ /* NEEDS NATIVE REVIEW */');
  String get getStarted => isEnglish ? 'Get Started' : (isHindi ? 'शुरू करें' : 'ਸ਼ੁਰੂ ਕਰੋ /* NEEDS NATIVE REVIEW */');
  String get continueBtn => isEnglish ? 'Continue' : (isHindi ? 'आगे बढ़ें' : 'ਅੱਗੇ ਵਧੋ /* NEEDS NATIVE REVIEW */');

  // ── Authentication ────────────────────────────────────────────────────────
  String get loginTitle {
    switch (language) {
      case AppLanguage.english:
        return 'Farmer Login';
      case AppLanguage.hindi:
        return 'किसान लॉगिन';
      case AppLanguage.punjabi:
        return 'ਕਿਸਾਨ ਲਾਗਇਨ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get loginSubtitle {
    switch (language) {
      case AppLanguage.english:
        return 'Enter your 10-digit mobile number';
      case AppLanguage.hindi:
        return 'अपना 10 अंकों का मोबाइल नंबर दर्ज करें';
      case AppLanguage.punjabi:
        return 'ਆਪਣਾ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get phoneLabel => isEnglish ? 'Mobile Number' : (isHindi ? 'मोबाइल नंबर' : 'ਮੋਬਾਈਲ ਨੰਬਰ /* NEEDS NATIVE REVIEW */');
  String get getOtpBtn => isEnglish ? 'Get OTP' : (isHindi ? 'ओटीपी प्राप्त करें' : 'ਓਟੀਪੀ ਪ੍ਰਾਪਤ ਕਰੋ /* NEEDS NATIVE REVIEW */');

  String get otpTitle {
    switch (language) {
      case AppLanguage.english:
        return 'Verify OTP';
      case AppLanguage.hindi:
        return 'ओटीपी सत्यापन';
      case AppLanguage.punjabi:
        return 'ਓਟੀਪੀ ਤਸਦੀਕ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get otpSubtitle {
    switch (language) {
      case AppLanguage.english:
        return 'Enter the 6-digit code sent to';
      case AppLanguage.hindi:
        return 'भेजा गया 6-अंकीय कोड दर्ज करें:';
      case AppLanguage.punjabi:
        return 'ਭੇਜਿਆ ਗਿਆ 6-ਅੰਕੀ ਕੋਡ ਦਰਜ ਕਰੋ: /* NEEDS NATIVE REVIEW */';
    }
  }

  String get verifyAndLogin => isEnglish ? 'Verify & Continue' : (isHindi ? 'सत्यापित करें और आगे बढ़ें' : 'ਤਸਦੀਕ ਕਰੋ ਅਤੇ ਅੱਗੇ ਵਧੋ /* NEEDS NATIVE REVIEW */');
  String get resendOtp => isEnglish ? 'Resend OTP' : (isHindi ? 'ओटीपी पुनः भेजें' : 'ਓਟੀਪੀ ਦੁਬਾਰਾ ਭੇਜੋ /* NEEDS NATIVE REVIEW */');
  String get resendIn => isEnglish ? 'Resend in' : (isHindi ? 'पुनः भेजें' : 'ਦੁਬਾਰਾ ਭੇਜੋ /* NEEDS NATIVE REVIEW */');
  String get changeNumber => isEnglish ? 'Change Number' : (isHindi ? 'नंबर बदलें' : 'ਨੰਬਰ ਬਦਲੋ /* NEEDS NATIVE REVIEW */');

  String get demoHint => isEnglish
      ? 'Demo Code: 123456 (test use only)'
      : (isHindi ? 'डेमो कोड: 123456 (केवल परीक्षण हेतु)' : 'ਡੈਮੋ ਕੋਡ: 123456 (ਕੇਵਲ ਟੈਸਟ ਲਈ) /* NEEDS NATIVE REVIEW */');

  String get demoQuickLoginBtn => isEnglish
      ? 'Quick Demo Login (+919810000001)'
      : (isHindi ? 'त्वरित डेमो लॉगिन (+919810000001)' : 'ਤੁਰੰਤ ਡੈਮੋ ਲਾਗਇਨ (+919810000001) /* NEEDS NATIVE REVIEW */');

  String get demoSmsNotice => isEnglish
      ? 'Demo Mode: SMS is simulated (real SMS gateway is PLANNED).'
      : (isHindi
          ? 'डेमो मोड: एसएमएस सिमुलेटेड है (वास्तविक एसएमएस गेटवे योजनाबद्ध है)।'
          : 'ਡੈਮੋ ਮੋਡ: ਐਸਐਮਐਸ ਸਿਮੂਲੇਟਿਡ ਹੈ (ਅਸਲ ਐਸਐਮਐਸ ਯੋਜਨਾਬੱਧ ਹੈ)। /* NEEDS NATIVE REVIEW */');

  String get invalidPhone => isEnglish
      ? 'Please enter a valid 10-digit mobile number'
      : (isHindi ? 'कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें' : 'ਕਿਰਪਾ ਕਰਕੇ ਸਹੀ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */');

  String get invalidOtp => isEnglish
      ? 'Please enter the complete 6-digit OTP'
      : (isHindi ? 'कृपया 6 अंकों का पूरा ओटीपी दर्ज करें' : 'ਕਿਰਪਾ ਕਰਕੇ 6 ਅੰਕਾਂ ਦਾ ਪੂਰਾ ਓਟੀਪੀ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */');

  // ── Home Screen ───────────────────────────────────────────────────────────
  String welcomeFarmer(String name) {
    switch (language) {
      case AppLanguage.english:
        return 'Welcome, $name';
      case AppLanguage.hindi:
        return 'नमस्ते, $name';
      case AppLanguage.punjabi:
        return 'ਜੀ ਆਇਆਂ ਨੂੰ, $name /* NEEDS NATIVE REVIEW */';
    }
  }

  String get offlineBanner => isEnglish
      ? 'Offline mode — using cached profile'
      : (isHindi ? 'ऑफ़लाइन मोड — सहेजा गया प्रोफाइल उपयोग में' : 'ਆਫ਼ਲਾਈਨ ਮੋਡ — ਸੁਰੱਖਿਅਤ ਪ੍ਰੋਫਾਈਲ ਵਰਤ ਰਿਹਾ ਹੈ /* NEEDS NATIVE REVIEW */');

  String get homeTab => isEnglish ? 'Home' : (isHindi ? 'होम' : 'ਹੋਮ /* NEEDS NATIVE REVIEW */');
  String get profileTab => isEnglish ? 'Profile' : (isHindi ? 'प्रोफाइल' : 'ਪ੍ਰੋਫਾਈਲ /* NEEDS NATIVE REVIEW */');

  String get checkStubbleCardTitle {
    switch (language) {
      case AppLanguage.english:
        return 'Check my stubble value';
      case AppLanguage.hindi:
        return 'अपनी पराली का मूल्य जानें';
      case AppLanguage.punjabi:
        return 'ਆਪਣੀ ਪਰਾਲੀ ਦਾ ਮੁੱਲ ਜਾਣੋ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get checkStubbleCardSubtitle {
    switch (language) {
      case AppLanguage.english:
        return 'Calculate expected yield and net income in 3 simple steps';
      case AppLanguage.hindi:
        return '3 सरल चरणों में अपेक्षित उपज और कमाई का हिसाब लगाएं';
      case AppLanguage.punjabi:
        return '3 ਸਧਾਰਨ ਕਦਮਾਂ ਵਿੱਚ ਅਨੁਮਾਨਿਤ ਝਾੜ ਅਤੇ ਕਮਾਈ ਦਾ ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */';
    }
  }

  String get estimateNowBtn => isEnglish ? 'Estimate Now' : (isHindi ? 'हिसाब लगाएं' : 'ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */');

  String get howItWorksHeading => isEnglish ? 'How It Works' : (isHindi ? 'यह कैसे काम करता है' : 'ਇਹ ਕਿਵੇਂ ਕੰਮ ਕਰਦਾ ਹੈ /* NEEDS NATIVE REVIEW */');

  String get step1Title => isEnglish ? '1. Field Details' : (isHindi ? '1. खेत का विवरण' : '1. ਖੇਤ ਦਾ ਵੇਰਵਾ /* NEEDS NATIVE REVIEW */');
  String get step1Desc => isEnglish ? 'Specify acreage and harvest date' : (isHindi ? 'रकबा और कटाई की तारीख बताएं' : 'ਰਕਬਾ ਅਤੇ ਕਟਾਈ ਦੀ ਤਾਰੀਖ ਦੱਸੋ /* NEEDS NATIVE REVIEW */');

  String get step2Title => isEnglish ? '2. Instant Value' : (isHindi ? '2. तुरंत अनुमान' : '2. ਤੁਰੰਤ ਅੰਦਾਜ਼ਾ /* NEEDS NATIVE REVIEW */');
  String get step2Desc => isEnglish ? 'View estimated tonnes and earnings' : (isHindi ? 'अनुमानित टन और कमाई देखें' : 'ਅਨੁਮਾਨਿਤ ਟਨ ਅਤੇ ਕਮਾਈ ਦੇਖੋ /* NEEDS NATIVE REVIEW */');

  String get step3Title => isEnglish ? '3. Book Bundle (Coming soon)' : (isHindi ? '3. बंडल बुक करें (जल्द)' : '3. ਬੰਡਲ ਬੁੱਕ ਕਰੋ (ਜਲਦੀ) /* NEEDS NATIVE REVIEW */');
  String get step3Desc => isEnglish ? 'Machine + truck + buyer in one tap' : (isHindi ? 'मशीन + ट्रक + खरीदार एक टैप में' : 'ਮਸ਼ੀਨ + ਟਰੱਕ + ਖਰੀਦਦਾਰ ਇੱਕ ਟੈਪ ਵਿੱਚ /* NEEDS NATIVE REVIEW */');

  String get comingSoon => isEnglish ? 'Coming soon' : (isHindi ? 'जल्द आ रहा है' : 'ਜਲਦੀ ਆ ਰਿਹਾ ਹੈ /* NEEDS NATIVE REVIEW */');

  // ── Field Details Screen ──────────────────────────────────────────────────
  String get fieldDetailsTitle => isEnglish ? 'Field Details' : (isHindi ? 'खेत का विवरण' : 'ਖੇਤ ਦਾ ਵੇਰਵਾ /* NEEDS NATIVE REVIEW */');
  String get manualFormHeading => isEnglish ? 'Field Information' : (isHindi ? 'खेत का विवरण' : 'ਖੇਤ ਦਾ ਵੇਰਵਾ /* NEEDS NATIVE REVIEW */');
  String get micPrompt => isEnglish ? 'Speak Details (Voice mic)' : (isHindi ? 'बोलकर बताएं (माइक दबाएं)' : 'ਬੋਲ ਕੇ ਦੱਸੋ (ਮਾਈਕ ਦਬਾਓ) /* NEEDS NATIVE REVIEW */');
  String get micComingSoon => isEnglish
      ? 'Voice entry coming soon — please fill below'
      : (isHindi ? 'आवाज से एंट्री जल्द आ रही है — कृपया नीचे भरें' : 'ਆਵਾਜ਼ ਰਾਹੀਂ ਐਂਟਰੀ ਜਲਦੀ ਆ ਰਹੀ ਹੈ — ਕਿਰਪਾ ਕਰਕੇ ਹੇਠਾਂ ਭਰੋ /* NEEDS NATIVE REVIEW */');
  String get acresLabel => isEnglish ? 'Field Area (Acres)' : (isHindi ? 'खेत का रकबा (एकड़)' : 'ਖੇਤ ਦਾ ਰਕਬਾ (ਏਕੜ) /* NEEDS NATIVE REVIEW */');
  String get varietyLabel => isEnglish ? 'Paddy Variety' : (isHindi ? 'धान की किस्म' : 'ਝੋਨੇ ਦੀ ਕਿਸਮ /* NEEDS NATIVE REVIEW */');
  String get harvestMethodLabel => isEnglish ? 'Harvest Method' : (isHindi ? 'कटाई का तरीका' : 'ਕਟਾਈ ਦਾ ਤਰੀਕਾ /* NEEDS NATIVE REVIEW */');
  String get harvestDateLabel => isEnglish ? 'Expected Harvest Date' : (isHindi ? 'संभावित कटाई की तारीख' : 'ਸੰਭਾਵਿਤ ਕਟਾਈ ਦੀ ਤਾਰੀਖ /* NEEDS NATIVE REVIEW */');
  String get selectDate => isEnglish ? 'Select Date' : (isHindi ? 'तारीख चुनें' : 'ਤਾਰੀਖ ਚੁਣੋ /* NEEDS NATIVE REVIEW */');
  String get calculateBtn => isEnglish ? 'Calculate Value' : (isHindi ? 'पराली का हिसाब लगाएं' : 'ਪਰਾਲੀ ਦਾ ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */');

  // Varieties & Methods
  String get varietyPR126 => 'PR-126';
  String get varietyPusa44 => 'Pusa-44';
  String get varietyBasmati => 'Basmati';
  String get varietyOther => isEnglish ? 'Other' : (isHindi ? 'अन्य' : 'ਹੋਰ /* NEEDS NATIVE REVIEW */');
  String get methodCombine => isEnglish ? 'Combine Harvester' : (isHindi ? 'कंबाइन हार्वेस्टर' : 'ਕੰਬਾਈਨ ਹਾਰਵੈਸਟਰ /* NEEDS NATIVE REVIEW */');
  String get methodManual => isEnglish ? 'Manual Cutting' : (isHindi ? 'हाथ से कटाई' : 'ਹੱਥ ਨਾਲ ਕਟਾਈ /* NEEDS NATIVE REVIEW */');

  // ── Estimate Screen ───────────────────────────────────────────────────────
  String get estimateTitle => isEnglish ? 'Stubble & Earnings Estimate' : (isHindi ? 'पराली और कमाई का अनुमान' : 'ਪਰਾਲੀ ਅਤੇ ਕਮਾਈ ਦਾ ਅਨੁਮਾਨ /* NEEDS NATIVE REVIEW */');
  String get stubbleQtyLabel => isEnglish ? 'Estimated Dry Stubble' : (isHindi ? 'अनुमानित सूखी पराली' : 'ਅਨੁਮਾਨਿਤ ਸੁੱਕੀ ਪਰਾਲੀ /* NEEDS NATIVE REVIEW */');
  String get tonnesUnit => isEnglish ? 'Tonnes' : (isHindi ? 'टन' : 'ਟਨ /* NEEDS NATIVE REVIEW */');
  String get midEstimate => isEnglish ? 'Central Estimate' : (isHindi ? 'केंद्रीय अनुमान' : 'ਕੇਂਦਰੀ ਅੰਦਾਜ਼ਾ /* NEEDS NATIVE REVIEW */');
  String get expectedEarningsLabel => isEnglish ? 'Estimated Income' : (isHindi ? 'संभावित आमदनी' : 'ਸੰਭਾਵਿਤ ਕਮਾਈ /* NEEDS NATIVE REVIEW */');
  String assumedPriceNote(double price) => isEnglish
      ? 'assumed price: ₹${price.toStringAsFixed(0)}/tonne'
      : (isHindi ? 'अनुमानित दर: ₹${price.toStringAsFixed(0)}/टन' : 'ਅਨੁਮਾਨਿਤ ਦਰ: ₹${price.toStringAsFixed(0)}/ਟਨ /* NEEDS NATIVE REVIEW */');
  String get disclaimer => isEnglish
      ? 'Note: This is an agronomic estimate. Payout is calculated from certified weighbridge measurement.'
      : (isHindi
          ? 'नोट: यह प्रारंभिक अनुमान है। वास्तविक भुगतान धर्मकांटा (वेब्रिज) पर तौलने के बाद होगा।'
          : 'ਨੋਟ: ਇਹ ਇੱਕ ਅਨੁਮਾਨ ਹੈ। ਅਸਲ ਭੁਗਤਾਨ ਧਰਮਕੰਡੇ ਤੇ ਤੋਲਣ ਤੋਂ ਬਾਅਦ ਹੋਵੇਗਾ। /* NEEDS NATIVE REVIEW */');
  String get nextStepAdvice => isEnglish
      ? 'Do not burn! Stubble baler machine and buyer coordination will open directly from this app.'
      : (isHindi
          ? 'पराली न जलाएं! बेलर मशीन और खरीदार से संपर्क जल्द शुरू होगा।'
          : 'ਪਰਾਲੀ ਨਾ ਸਾੜੋ! ਬੇਲਰ ਮਸ਼ੀਨ ਅਤੇ ਖਰੀਦਦਾਰ ਨਾਲ ਸੰਪਰਕ ਜਲਦੀ ਸ਼ੁਰੂ ਹੋਵੇਗਾ। /* NEEDS NATIVE REVIEW */');
  String get recalculateBtn => isEnglish ? 'Calculate Another Field' : (isHindi ? 'नया हिसाब लगाएं' : 'ਨਵਾਂ ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */');

  // ── Profile Screen ────────────────────────────────────────────────────────
  String get profileHeading => isEnglish ? 'Farmer Profile' : (isHindi ? 'किसान प्रोफाइल' : 'ਕਿਸਾਨ ਪ੍ਰੋਫਾਈਲ /* NEEDS NATIVE REVIEW */');
  String get nameLabel => isEnglish ? 'Farmer Name' : (isHindi ? 'किसान का नाम' : 'ਕਿਸਾਨ ਦਾ ਨਾਂ /* NEEDS NATIVE REVIEW */');
  String get villageDistrictLabel => isEnglish ? 'Village & District' : (isHindi ? 'गाँव और ज़िला' : 'ਪਿੰਡ ਅਤੇ ਜ਼ਿਲ੍ਹਾ /* NEEDS NATIVE REVIEW */');
  String get notSpecified => isEnglish ? 'Not specified' : (isHindi ? 'दर्ज नहीं' : 'ਦਰਜ ਨਹੀਂ /* NEEDS NATIVE REVIEW */');
  String get edit => isEnglish ? 'Edit' : (isHindi ? 'बदलें' : 'ਬਦਲੋ /* NEEDS NATIVE REVIEW */');
  String get save => isEnglish ? 'Save' : (isHindi ? 'सहेजें' : 'ਸੰਭਾਲੋ /* NEEDS NATIVE REVIEW */');
  String get cancel => isEnglish ? 'Cancel' : (isHindi ? 'रद्द करें' : 'ਰੱਦ ਕਰੋ /* NEEDS NATIVE REVIEW */');
  String get logout => isEnglish ? 'Log Out' : (isHindi ? 'लॉग आउट' : 'ਲਾਗ ਆਉਟ /* NEEDS NATIVE REVIEW */');
  String get aboutTitle => isEnglish ? 'About ParaliSetu' : (isHindi ? 'पराली सेतु के बारे में' : 'ਪਰਾਲੀ ਸੇਤੂ ਬਾਰੇ /* NEEDS NATIVE REVIEW */');
  String get aboutText => isEnglish
      ? 'Simulated prototype built for Amazon Environmental Hacks 2026. All farmer and booking data in this demo is simulated.'
      : (isHindi
          ? 'अमेज़न एनवायर्नमेंटल हैक्स 2026 के लिए निर्मित प्रोटोटाइप। इस डेमो में सभी डेटा सिम्युलेटेड हैं।'
          : 'ਐਮਾਜ਼ਾਨ ਐਨਵਾਇਰਨਮੈਂਟਲ ਹੈਕਸ 2026 ਲਈ ਬਣਾਇਆ ਪ੍ਰੋਟੋਟਾਈਪ। ਇਸ ਡੈਮੋ ਵਿੱਚ ਸਾਰਾ ਡਾਟਾ ਸਿਮੂਲੇਟਿਡ ਹੈ। /* NEEDS NATIVE REVIEW */');

  // ── Matching & Options Screen ─────────────────────────────────────────────
  String get selectBundleTitle => isEnglish
      ? 'Choose Stubble Pickup Bundle'
      : (isHindi ? 'पराली उठान विकल्प चुनें' : 'ਪਰਾਲੀ ਚੁਕਾਈ ਵਿਕਲਪ ਚੁਣੋ /* NEEDS NATIVE REVIEW */');
  String get bundlesSubtitle => isEnglish
      ? 'Optimized by AI for fastest pickup and maximum payout'
      : (isHindi ? 'AI द्वारा सबसे तेज उठान और सबसे ज्यादा मुनाफे के लिए तैयार' : 'ਏ.ਆਈ. ਦੁਆਰਾ ਸਭ ਤੋਂ ਤੇਜ਼ ਚੁਕਾਈ ਅਤੇ ਵੱਧ ਮੁਨਾਫੇ ਲਈ ਤਿਆਰ /* NEEDS NATIVE REVIEW */');
  String get bookPickupBtn => isEnglish
      ? 'Book This Pickup'
      : (isHindi ? 'यह विकल्प बुक करें' : 'ਇਹ ਵਿਕਲਪ ਬੁੱਕ ਕਰੋ /* NEEDS NATIVE REVIEW */');
  String get grossIncomeLabel => isEnglish ? 'Factory Rate' : (isHindi ? 'फैक्ट्री का मूल्य' : 'ਫੈਕਟਰੀ ਮੁੱਲ /* NEEDS NATIVE REVIEW */');
  String get machineCostLabel => isEnglish ? 'Baler Machine' : (isHindi ? 'बेलर मशीन खर्च' : 'ਬੇਲਰ ਮਸ਼ੀਨ ਖਰਚ /* NEEDS NATIVE REVIEW */');
  String get transportCostLabel => isEnglish ? 'Truck Transport' : (isHindi ? 'ट्रक ढुलाई' : 'ਟਰੱਕ ਢੁਲਾਈ /* NEEDS NATIVE REVIEW */');
  String get netEarningsLabel => isEnglish ? 'Net In-Hand Earnings' : (isHindi ? 'हाथ में शुद्ध कमाई' : 'ਹੱਥ ਵਿੱਚ ਸ਼ੁੱਧ ਕਮਾਈ /* NEEDS NATIVE REVIEW */');
  String get pickupDateLabel => isEnglish ? 'Pickup Date' : (isHindi ? 'उठान की तारीख' : 'ਚੁਕਾਈ ਦੀ ਮਿਤੀ /* NEEDS NATIVE REVIEW */');
  String get buyerLabel => isEnglish ? 'Delivery To' : (isHindi ? 'कहाँ जाएगा' : 'ਕਿੱਥੇ ਜਾਵੇਗਾ /* NEEDS NATIVE REVIEW */');
  String get bookingConfirmedTitle => isEnglish ? 'Booking Confirmed!' : (isHindi ? 'बुकिंग पक्की हो गई!' : 'ਬੁਕਿੰਗ ਪੱਕੀ ਹੋ ਗਈ! /* NEEDS NATIVE REVIEW */');
  String get escrowHoldNotice => isEnglish
      ? 'Simulated Escrow: ₹{amount} locked by factory. Released on weighbridge receipt.'
      : (isHindi
          ? 'सुरक्षित एस्क्रो: ₹{amount} फैक्ट्री द्वारा लॉक किया गया। धर्मकांटा रसीद पर रिलीज होगा।'
          : 'ਸੁਰੱਖਿਅਤ ਐਸਕਰੋ: ₹{amount} ਫੈਕਟਰੀ ਦੁਆਰਾ ਲਾਕ। ਧਰਮਕੰਡਾ ਪਰਚੀ ਤੇ ਮਿਲੇਗਾ। /* NEEDS NATIVE REVIEW */');
  String get viewBookingDetails => isEnglish ? 'Go to Home' : (isHindi ? 'मुख्य पृष्ठ पर जाएं' : 'ਮੁੱਖ ਪੰਨੇ ਤੇ ਜਾਓ /* NEEDS NATIVE REVIEW */');

  // ── General Errors & Network ──────────────────────────────────────────────
  String get serverWakingUp => isEnglish

      ? 'Server is waking up, please wait... (may take 30-60 seconds on free tier)'
      : (isHindi
          ? 'सर्वर शुरू हो रहा है, कृपया थोड़ा इंतज़ार करें... (30-60 सेकंड लग सकते हैं)'
          : 'ਸਰਵਰ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ, ਕਿਰਪਾ ਕਰਕੇ ਉਡੀਕ ਕਰੋ... (30-60 ਸਕਿੰਟ ਲੱਗ ਸਕਦੇ ਹਨ) /* NEEDS NATIVE REVIEW */');
  String get noInternet => isEnglish
      ? 'No internet connection. Please check your network.'
      : (isHindi ? 'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क चेक करें।' : 'ਇੰਟਰਨੈੱਟ ਕਨੈਕਸ਼ਨ ਨਹੀਂ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਨੈੱਟਵਰਕ ਚੈੱਕ ਕਰੋ। /* NEEDS NATIVE REVIEW */');
  String get requestFailed => isEnglish
      ? 'Could not connect to server. Please try again.'
      : (isHindi ? 'सर्वर से संपर्क नहीं हो सका। कृपया पुनः प्रयास करें।' : 'ਸਰਵਰ ਨਾਲ ਸੰਪਰਕ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ। /* NEEDS NATIVE REVIEW */');
}
