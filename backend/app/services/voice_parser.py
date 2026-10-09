from __future__ import annotations

import re
from datetime import date, datetime, timedelta
from typing import Any, Dict, Optional, Tuple


# Word-to-number mapping covering Hindi, Punjabi, Hinglish, and English
VERNACULAR_NUMBERS: Dict[str, float] = {
    # English
    "half": 0.5,
    "one": 1.0,
    "two": 2.0,
    "three": 3.0,
    "four": 4.0,
    "five": 5.0,
    "six": 6.0,
    "seven": 7.0,
    "eight": 8.0,
    "nine": 9.0,
    "ten": 10.0,
    "fifteen": 15.0,
    "twenty": 20.0,
    # Hindi / Hinglish
    "aadha": 0.5,
    "adhaa": 0.5,
    "ek": 1.0,
    "do": 2.0,
    "teen": 3.0,
    "char": 4.0,
    "chaar": 4.0,
    "panch": 5.0,
    "paanch": 5.0,
    "chhe": 6.0,
    "che": 6.0,
    "saat": 7.0,
    "aath": 8.0,
    "nau": 9.0,
    "das": 10.0,
    "gyarah": 11.0,
    "barah": 12.0,
    "pandrah": 15.0,
    "bees": 20.0,
    "pachees": 25.0,
    "tees": 30.0,
    "dedh": 1.5,
    "dhai": 2.5,
    # Hindi Devanagari
    "आधा": 0.5,
    "एक": 1.0,
    "दो": 2.0,
    "तीन": 3.0,
    "चार": 4.0,
    "पांच": 5.0,
    "छह": 6.0,
    "सात": 7.0,
    "आठ": 8.0,
    "नौ": 9.0,
    "दस": 10.0,
    "ग्यारह": 11.0,
    "बारह": 12.0,
    "पंद्रह": 15.0,
    "बीस": 20.0,
    "पच्चीस": 25.0,
    "डेढ़": 1.5,
    "ढाई": 2.5,
    # Punjabi Gurmukhi
    "ਅੱਧਾ": 0.5,
    "ਇੱਕ": 1.0,
    "ਦੋ": 2.0,
    "ਤਿੰਨ": 3.0,
    "ਚਾਰ": 4.0,
    "ਪੰਜ": 5.0,
    "ਛੇ": 6.0,
    "ਸੱਤ": 7.0,
    "ਅੱਠ": 8.0,
    "ਨੌਂ": 9.0,
    "ਦਸ": 10.0,
    "ਗਿਆਰਾਂ": 11.0,
    "ਬਾਰਾਂ": 12.0,
    "ਪੰਦਰਾਂ": 15.0,
    "ਵੀਹ": 20.0,
    "ਪੱਚੀ": 25.0,
    "ਡੇਢ": 1.5,
    "ਢਾਈ": 2.5,
}

# Unit multipliers to Acres per PAU & agronomic conventions
UNIT_MULTIPLIERS: Dict[str, float] = {
    # 1 Killa = 1.0 Acre (Punjab & Haryana standard)
    "killa": 1.0,
    "kille": 1.0,
    "killeh": 1.0,
    "kila": 1.0,
    "किल्ला": 1.0,
    "किल्ले": 1.0,
    "ਕਿੱਲਾ": 1.0,
    "ਕਿੱਲੇ": 1.0,
    # Acre
    "acre": 1.0,
    "acres": 1.0,
    "एकड़": 1.0,
    "ਏਕੜ": 1.0,
    # 1 Bigha (Punjab standard) = 0.20 Acre (5 Bigha = 1 Killa)
    "bigha": 0.20,
    "bighas": 0.20,
    "bighe": 0.20,
    "बीघा": 0.20,
    "बीघे": 0.20,
    "ਬੀਘਾ": 0.20,
    "ਬੀਘੇ": 0.20,
    # 1 Hectare = 2.47105 Acres
    "hectare": 2.471,
    "hectares": 2.471,
    "हेक्टेयर": 2.471,
    "ਹੈਕਟੇਅਰ": 2.471,
}

MONTH_MAP: Dict[str, int] = {
    "october": 10,
    "oct": 10,
    "अक्टूबर": 10,
    "ਅਕਤੂਬਰ": 10,
    "november": 11,
    "nov": 11,
    "नवंबर": 11,
    "ਨਵੰਬਰ": 11,
    "december": 12,
    "dec": 12,
    "दिसंबर": 12,
    "ਦਸੰਬਰ": 12,
    "september": 9,
    "sep": 9,
    "सितंबर": 9,
    "ਸਤੰਬਰ": 9,
}


def _extract_area(text: str) -> Tuple[float, str, float]:
    """
    Extracts land area and normalizes to acres.
    Returns: (acres: float, raw_unit: str, confidence_score: float)
    """
    clean = text.lower().strip()

    # Look for numeric patterns next to unit
    # Example: "4 killa", "4.5 acre", "10 bigha", "चार किल्ले", "4 ਕਿੱਲੇ"
    unit_regex = (
        r"(killa|kille|kila|किल्ला|किल्ले|ਕਿੱਲਾ|ਕਿੱਲੇ|"
        r"acre|acres|एकड़|ਏਕੜ|"
        r"bigha|bighas|bighe|बीघा|बीघे|ਬੀਘਾ|ਬੀਘੇ|"
        r"hectare|hectares|हेक्टेयर|ਹੈਕਟੇਅਰ)"
    )

    # 1. Direct regex: Number + Unit
    match = re.search(rf"(\d+(?:\.\d+)?)\s*{unit_regex}", clean)
    if match:
        val = float(match.group(1))
        unit = match.group(2)
        mult = UNIT_MULTIPLIERS.get(unit, 1.0)
        return round(val * mult, 2), unit, 0.95

    # 2. Word Number + Unit
    for word, num in VERNACULAR_NUMBERS.items():
        pattern = rf"\b{re.escape(word)}\s+{unit_regex}"
        m = re.search(pattern, clean)
        if m:
            unit = m.group(1)
            mult = UNIT_MULTIPLIERS.get(unit, 1.0)
            return round(num * mult, 2), unit, 0.92

    # 3. Unit mentioned first, then number (e.g. "killa 4", "acre 5")
    match_rev = re.search(rf"{unit_regex}\s*(\d+(?:\.\d+)?)", clean)
    if match_rev:
        unit = match_rev.group(1)
        val = float(match_rev.group(2))
        mult = UNIT_MULTIPLIERS.get(unit, 1.0)
        return round(val * mult, 2), unit, 0.90

    # 4. Fallback: isolated number between 0.5 and 50
    m_num = re.search(r"\b(\d+(?:\.\d+)?)\b", clean)
    if m_num:
        val = float(m_num.group(1))
        if 0.5 <= val <= 100.0:
            return round(val, 2), "killa", 0.70

    # Default to 4.0 acres (standard Punjab benchmark) with low confidence
    return 4.0, "killa", 0.50


def _extract_variety(text: str) -> Tuple[str, float]:
    """
    Extracts paddy variety and maps to: 'PR-126', 'Pusa-44', 'Basmati', or 'other'.
    Returns: (variety: str, confidence_score: float)
    """
    clean = text.lower()

    # PR-126
    if re.search(r"\b(pr[- ]?126|पी\s*आर\s*126|ਪੀ\s*ਆਰ\s*126)\b", clean) or "126" in clean:
        return "PR-126", 0.95

    # Pusa-44
    if re.search(r"\b(pusa[- ]?44|पूसा\s*44|ਪੂਸਾ\s*44|puza\s*44)\b", clean) or "44" in clean:
        return "Pusa-44", 0.95

    # Basmati
    if re.search(r"\b(basmati|बासमती|ਬਾਸਮਤੀ|1121|1509|pb[- ]?1)\b", clean):
        return "Basmati", 0.95

    # Other paddy mentions
    if re.search(r"\b(dhaan|paddy|jhona|ਝੋਨਾ|धान|chawal)\b", clean):
        return "other", 0.80

    # Default to PR-126 (most common short-duration variety in Punjab)
    return "PR-126", 0.60


def _extract_harvest_date(
    text: str, ref_date: Optional[date] = None
) -> Tuple[str, float]:
    """
    Extracts harvest date relative to reference date or explicitly mentioned.
    Returns: (date_iso: str 'YYYY-MM-DD', confidence_score: float)
    """
    base_date = ref_date or date(2026, 10, 20)
    clean = text.lower()

    # 1. ISO format (YYYY-MM-DD)
    m_iso = re.search(r"\b(\d{4}-\d{2}-\d{2})\b", clean)
    if m_iso:
        return m_iso.group(1), 0.98

    # 2. Relative date terms (using Unicode-safe boundary or substring)
    if re.search(r"(?:^|\s|[^\w])(aaj|आज|ਅੱਜ|today)(?:$|\s|[^\w])", clean):
        return base_date.strftime("%Y-%m-%d"), 0.95

    if re.search(r"(?:^|\s|[^\w])(kal|कल|ਕੱਲ੍ਹ|tomorrow)(?:$|\s|[^\w])", clean):
        target = base_date + timedelta(days=1)
        return target.strftime("%Y-%m-%d"), 0.95

    if re.search(r"(?:^|\s|[^\w])(parso|parson|परसों|ਪਰਸੋਂ|day after tomorrow)(?:$|\s|[^\w])", clean) or "परसों" in clean or "ਪਰਸੋਂ" in clean:
        target = base_date + timedelta(days=2)
        return target.strftime("%Y-%m-%d"), 0.95

    if re.search(r"(?:^|\s|[^\w])(tarso|tarson|नरसों|ਤਰਸੋਂ)(?:$|\s|[^\w])", clean) or "नरसों" in clean or "ਤਰਸੋਂ" in clean:
        target = base_date + timedelta(days=3)
        return target.strftime("%Y-%m-%d"), 0.90

    # 3. Explicit Day of Month (e.g., '25 october', '25 tareek', '25 tarikh', '25 ਅਕਤੂਬਰ', '25 को')
    # Day + Month
    for month_name, m_idx in MONTH_MAP.items():
        pattern = rf"\b(\d{{1,2}})\s*(?:st|nd|rd|th)?\s+{re.escape(month_name)}\b"
        m_day_month = re.search(pattern, clean)
        if m_day_month:
            day = int(m_day_month.group(1))
            year = base_date.year
            try:
                dt = date(year, m_idx, day)
                return dt.strftime("%Y-%m-%d"), 0.95
            except ValueError:
                pass

    # Month + Day (e.g. 'october 25')
    for month_name, m_idx in MONTH_MAP.items():
        pattern = rf"\b{re.escape(month_name)}\s+(\d{{1,2}})\b"
        m_month_day = re.search(pattern, clean)
        if m_month_day:
            day = int(m_month_day.group(1))
            year = base_date.year
            try:
                dt = date(year, m_idx, day)
                return dt.strftime("%Y-%m-%d"), 0.95
            except ValueError:
                pass

    # Day + tareek / tarikh / ko (e.g. '25 tareek', '25 tarikh ko', '25 ਅਕਤੂਬਰ ko')
    m_day = re.search(
        r"\b(\d{1,2})\s*(?:tareek|tarikh|tareekh|तारीख|ਤਾਰੀਖ|ko|को|ਨੂੰ)\b", clean
    )
    if m_day:
        day = int(m_day.group(1))
        # Use base_date month, or next month if day is in past
        month = base_date.month
        year = base_date.year
        try:
            dt = date(year, month, day)
            return dt.strftime("%Y-%m-%d"), 0.90
        except ValueError:
            pass

    # Default to 5 days after base_date
    default_target = base_date + timedelta(days=5)
    return default_target.strftime("%Y-%m-%d"), 0.65


def _generate_confirmation_prompt(
    acres: float, variety: str, harvest_date_str: str, language: str = "hi"
) -> str:
    """
    Enforces AI Directive 1 (Zero-Guess Guardrail):
    Generates unambiguous conversational verification string.
    "Aapne bola: 4 Killa PR-126, 25 October. Sahi hai?"
    """
    try:
        dt = datetime.strptime(harvest_date_str, "%Y-%m-%d").date()
        date_display_en = dt.strftime("%d %B")
        months_hi = {
            9: "सितंबर",
            10: "अक्टूबर",
            11: "नवंबर",
            12: "दिसंबर",
        }
        months_pa = {
            9: "ਸਤੰਬਰ",
            10: "ਅਕਤੂਬਰ",
            11: "ਨਵੰਬਰ",
            12: "ਦਸੰਬਰ",
        }
        date_display_hi = f"{dt.day} {months_hi.get(dt.month, dt.strftime('%B'))}"
        date_display_pa = f"{dt.day} {months_pa.get(dt.month, dt.strftime('%B'))}"
    except Exception:
        date_display_en = harvest_date_str
        date_display_hi = harvest_date_str
        date_display_pa = harvest_date_str

    acres_str = f"{acres:g}"

    if language == "pa":
        return f"ਤੁਸੀਂ ਕਿਹਾ: {acres_str} ਕਿੱਲਾ {variety}, {date_display_pa}। ਕੀ ਇਹ ਸਹੀ ਹੈ?"
    elif language == "en":
        return f"You said: {acres_str} Acres {variety}, {date_display_en}. Is this correct?"
    else:  # Hindi / Hinglish default
        return f"आपने बोला: {acres_str} किल्ला {variety}, {date_display_hi}। सही है?"


def parse_voice_transcript(
    transcript: str,
    language: str = "hi",
    reference_date_str: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Main extraction pipeline:
    Parses speech transcripts in Punjabi, Hindi, or English into structured entities.
    Returns:
        {
            "acres": float,
            "variety": str,
            "harvest_date": str,
            "confidence": float,
            "confirmation_prompt": str,
            "transcript_recognized": str,
            "raw_entities": dict
        }
    """
    if not transcript or not transcript.strip():
        raise ValueError("Transcript cannot be empty")

    ref_date = None
    if reference_date_str:
        try:
            ref_date = datetime.strptime(reference_date_str, "%Y-%m-%d").date()
        except ValueError:
            ref_date = None

    acres, raw_unit, conf_area = _extract_area(transcript)
    variety, conf_variety = _extract_variety(transcript)
    harvest_date, conf_date = _extract_harvest_date(transcript, ref_date)

    # Weighted confidence score
    overall_confidence = round(
        (conf_area * 0.40) + (conf_variety * 0.35) + (conf_date * 0.25),
        2,
    )

    confirmation_prompt = _generate_confirmation_prompt(
        acres=acres,
        variety=variety,
        harvest_date_str=harvest_date,
        language=language,
    )

    return {
        "acres": acres,
        "variety": variety,
        "harvest_date": harvest_date,
        "confidence": overall_confidence,
        "confirmation_prompt": confirmation_prompt,
        "transcript_recognized": transcript.strip(),
        "raw_entities": {
            "raw_unit": raw_unit,
            "conf_area": conf_area,
            "conf_variety": conf_variety,
            "conf_date": conf_date,
        },
    }
