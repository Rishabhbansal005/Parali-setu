from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from app.schemas.voice import VoiceParseRequest, VoiceParseResponse
from app.services.voice_parser import parse_voice_transcript

router = APIRouter(prefix="/voice", tags=["voice"])


@router.post(
    "/parse",
    response_model=VoiceParseResponse,
    status_code=status.HTTP_200_OK,
    summary="Parse vernacular voice speech into structured land & crop entities",
    description=(
        "Converts voice transcripts in Punjabi, Hindi, Hinglish, or English into "
        "normalized land area (acres), variety, harvest date, and generates "
        "the mandatory AI Directive 1 conversational confirmation prompt."
    ),
)
def parse_voice(payload: VoiceParseRequest) -> VoiceParseResponse:
    if not payload.transcript or not payload.transcript.strip():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Transcript cannot be empty",
        )

    try:
        result = parse_voice_transcript(
            transcript=payload.transcript,
            language=payload.language or "hi",
            reference_date_str=payload.reference_date,
        )
        return VoiceParseResponse(**result)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error parsing voice input: {str(e)}",
        )
