/// Vernacular strings for ParaliSetu (Hindi & Punjabi).
///
/// NOTE: All Punjabi (Gurmukhi) translations are marked with
/// "NEEDS NATIVE REVIEW" per Rule 6 and project instructions.
enum AppLanguage { hindi, punjabi }

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  bool get isHindi => language == AppLanguage.hindi;

  // App Title
  String get appTitle => isHindi ? 'पराली सेतु' : 'ਪਰਾਲੀ ਸੇਤੂ /* NEEDS NATIVE REVIEW */';
  String get tagline => isHindi
      ? 'पराली बेचें, कमाई करें, खेत बचाएं'
      : 'ਪਰਾਲੀ ਵੇਚੋ, ਕਮਾਈ ਕਰੋ, ਖੇਤ ਬਚਾਓ /* NEEDS NATIVE REVIEW */';

  // Language Selection Screen
  String get chooseLanguage => isHindi ? 'अपनी भाषा चुनें' : 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ /* NEEDS NATIVE REVIEW */';
  String get hindiLabel => 'हिंदी (Hindi)';
  String get punjabiLabel => 'ਪੰਜਾਬੀ (Punjabi)';
  String get continueBtn => isHindi ? 'आगे बढ़ें' : 'ਅੱਗੇ ਵਧੋ /* NEEDS NATIVE REVIEW */';

  // Login Screen
  String get loginTitle => isHindi ? 'किसान लॉगिन' : 'ਕਿਸਾਨ ਲਾਗਇਨ /* NEEDS NATIVE REVIEW */';
  String get loginSubtitle => isHindi
      ? 'अपना 10 अंकों का मोबाइल नंबर दर्ज करें'
      : 'ਆਪਣਾ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */';
  String get phoneLabel => isHindi ? 'मोबाइल नंबर' : 'ਮੋਬਾਈਲ ਨੰਬਰ /* NEEDS NATIVE REVIEW */';
  String get sendOtp => isHindi ? 'ओटीपी प्राप्त करें' : 'ਓਟੀਪੀ ਪ੍ਰਾਪਤ ਕਰੋ /* NEEDS NATIVE REVIEW */';
  String get enterOtp => isHindi ? 'ओटीपी दर्ज करें' : 'ਓਟੀਪੀ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */';
  String get verifyOtp => isHindi ? 'सत्यापित करें' : 'ਤਸਦੀਕ ਕਰੋ /* NEEDS NATIVE REVIEW */';
  String get demoHint => isHindi
      ? 'डेमो कोड: 123456 (केवल टेस्ट के लिए)'
      : 'ਡੈਮੋ ਕੋਡ: 123456 (ਕੇਵਲ ਟੈਸਟ ਲਈ) /* NEEDS NATIVE REVIEW */';
  String get demoLoginBtn => isHindi
      ? 'त्वरित डेमो लॉगिन (+919810000001)'
      : 'ਤੁਰੰਤ ਡੈਮੋ ਲਾਗਇਨ (+919810000001) /* NEEDS NATIVE REVIEW */';
  String get invalidPhone => isHindi
      ? 'कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें'
      : 'ਕਿਰਪਾ ਕਰਕੇ ਸਹੀ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */';
  String get invalidOtp => isHindi
      ? 'कृपया 6 अंकों का ओटीपी दर्ज करें'
      : 'ਕਿਰਪਾ ਕਰਕੇ 6 ਅੰਕਾਂ ਦਾ ਓਟੀਪੀ ਦਰਜ ਕਰੋ /* NEEDS NATIVE REVIEW */';

  // Field Details Screen
  String get fieldDetailsTitle => isHindi ? 'अपने खेत की जानकारी' : 'ਆਪਣੇ ਖੇਤ ਦੀ ਜਾਣਕਾਰੀ /* NEEDS NATIVE REVIEW */';
  String get micPrompt => isHindi
      ? 'बोलकर बताएं (माइक दबाएं)'
      : 'ਬੋਲ ਕੇ ਦੱਸੋ (ਮਾਈਕ ਦਬਾਓ) /* NEEDS NATIVE REVIEW */';
  String get micComingSoon => isHindi
      ? 'आवाज से एंट्री जल्द आ रही है — कृपया नीचे विवरण भरें'
      : 'ਆਵਾਜ਼ ਰਾਹੀਂ ਐਂਟਰੀ ਜਲਦੀ ਆ ਰਹੀ ਹੈ — ਕਿਰਪਾ ਕਰਕੇ ਹੇਠਾਂ ਵੇਰਵੇ ਭਰੋ /* NEEDS NATIVE REVIEW */';
  String get manualFormHeading => isHindi ? 'खेत का विवरण' : 'ਖੇਤ ਦਾ ਵੇਰਵਾ /* NEEDS NATIVE REVIEW */';
  String get acresLabel => isHindi ? 'खेत का रकबा (एकड़)' : 'ਖੇਤ ਦਾ ਰਕਬਾ (ਏਕੜ) /* NEEDS NATIVE REVIEW */';
  String get varietyLabel => isHindi ? 'धान की किस्म' : 'ਝੋਨੇ ਦੀ ਕਿਸਮ /* NEEDS NATIVE REVIEW */';
  String get harvestMethodLabel => isHindi ? 'कटाई का तरीका' : 'ਕਟਾਈ ਦਾ ਤਰੀਕਾ /* NEEDS NATIVE REVIEW */';
  String get harvestDateLabel => isHindi ? 'संभावित कटाई की तारीख' : 'ਸੰਭਾਵਿਤ ਕਟਾਈ ਦੀ ਤਾਰੀਖ /* NEEDS NATIVE REVIEW */';
  String get selectDate => isHindi ? 'तारीख चुनें' : 'ਤਾਰੀਖ ਚੁਣੋ /* NEEDS NATIVE REVIEW */';
  String get calculateBtn => isHindi ? 'पराली का हिसाब लगाएं' : 'ਪਰਾਲੀ ਦਾ ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */';

  // Varieties & Methods
  String get varietyPR126 => 'PR-126';
  String get varietyPusa44 => 'Pusa-44';
  String get varietyBasmati => 'Basmati';
  String get varietyOther => isHindi ? 'अन्य' : 'ਹੋਰ /* NEEDS NATIVE REVIEW */';
  String get methodCombine => isHindi ? 'कंबाइन हार्वेस्टर' : 'ਕੰਬਾਈਨ ਹਾਰਵੈਸਟਰ /* NEEDS NATIVE REVIEW */';
  String get methodManual => isHindi ? 'हाथ से कटाई' : 'ਹੱਥ ਨਾਲ ਕਟਾਈ /* NEEDS NATIVE REVIEW */';

  // Estimate Screen
  String get estimateTitle => isHindi ? 'पराली और कमाई का अनुमान' : 'ਪਰਾਲੀ ਅਤੇ ਕਮਾਈ ਦਾ ਅਨੁਮਾਨ /* NEEDS NATIVE REVIEW */';
  String get stubbleQtyLabel => isHindi ? 'अनुमानित सूखी पराली' : 'ਅਨੁਮਾਨਿਤ ਸੁੱਕੀ ਪਰਾਲੀ /* NEEDS NATIVE REVIEW */';
  String get tonnesUnit => isHindi ? 'टन' : 'ਟਨ /* NEEDS NATIVE REVIEW */';
  String get approxRange => isHindi ? 'अनुमानित सीमा' : 'ਅਨੁਮਾਨਿਤ ਸੀਮਾ /* NEEDS NATIVE REVIEW */';
  String get expectedEarningsLabel => isHindi ? 'संभावित कमाई (₹1,200/टन पर)' : 'ਸੰਭਾਵਿਤ ਕਮਾਈ (₹1,200/ਟਨ ਤੇ) /* NEEDS NATIVE REVIEW */';
  String get disclaimer => isHindi
      ? 'नोट: यह एक प्रारंभिक अनुमान है। वास्तविक वजन धर्मकांटा (वेब्रिज) पर तौला जाएगा।'
      : 'ਨੋਟ: ਇਹ ਇੱਕ ਅਨੁਮਾਨ ਹੈ। ਅਸਲ ਵਜ਼ਨ ਧਰਮਕੰਡੇ ਤੇ ਤੋਲਿਆ ਜਾਵੇਗਾ। /* NEEDS NATIVE REVIEW */';
  String get nextStepAdvice => isHindi
      ? 'पराली न जलाएं! बेलर मशीन और पराली खरीदार से जल्द संपर्क किया जाएगा।'
      : 'ਪਰਾਲੀ ਨਾ ਸਾੜੋ! ਬੇਲਰ ਮਸ਼ੀਨ ਅਤੇ ਖਰੀਦਦਾਰ ਨਾਲ ਜਲਦੀ ਸੰਪਰਕ ਕੀਤਾ ਜਾਵੇਗਾ। /* NEEDS NATIVE REVIEW */';
  String get recalculateBtn => isHindi ? 'नया हिसाब लगाएं' : 'ਨਵਾਂ ਹਿਸਾਬ ਲਗਾਓ /* NEEDS NATIVE REVIEW */';

  // Server & Connection States
  String get serverWakingUp => isHindi
      ? 'सर्वर चालू हो रहा है, कृपया थोड़ा इंतज़ार करें... (30-60 सेकंड लग सकते हैं)'
      : 'ਸਰਵਰ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ, ਕਿਰਪਾ ਕਰਕੇ ਉਡੀਕ ਕਰੋ... (30-60 ਸਕਿੰਟ ਲੱਗ ਸਕਦੇ ਹਨ) /* NEEDS NATIVE REVIEW */';
  String get noInternet => isHindi
      ? 'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क चेक करें।'
      : 'ਇੰਟਰਨੈੱਟ ਕਨੈਕਸ਼ਨ ਨਹੀਂ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਨੈੱਟਵਰਕ ਚੈੱਕ ਕਰੋ। /* NEEDS NATIVE REVIEW */';
  String get requestFailed => isHindi
      ? 'सर्वर से संपर्क नहीं हो सका। कृपया पुनः प्रयास करें।'
      : 'ਸਰਵਰ ਨਾਲ ਸੰਪਰਕ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ। /* NEEDS NATIVE REVIEW */';
}
