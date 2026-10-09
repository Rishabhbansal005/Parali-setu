from __future__ import annotations
from typing import Optional, Dict, Any
from pydantic import BaseModel, ConfigDict, Field


class VoiceParseRequest(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    transcript: str = Field(
        ...,
        description="Spoken transcript in Punjabi, Hindi, Hinglish, or English e.g. '4 killa PR-126, 25 October'",
    )
    language: Optional[str] = Field(
        "hi",
        description="Language code: 'hi' (Hindi), 'pa' (Punjabi), or 'en' (English)",
    )
    reference_date: Optional[str] = Field(
        None,
        description="Optional reference date (YYYY-MM-DD) for resolving relative dates like 'kal' or 'parso'",
    )


class VoiceParseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    acres: float = Field(..., description="Extracted land area normalized to acres")
    variety: str = Field(..., description="Paddy variety: PR-126, Pusa-44, Basmati, or other")
    harvest_date: str = Field(..., description="Estimated harvest date (YYYY-MM-DD)")
    confidence: float = Field(..., description="Parsing confidence score between 0.0 and 1.0")
    confirmation_prompt: str = Field(
        ...,
        description="Conversational prompt to speak back to the farmer for verification",
    )
    transcript_recognized: str = Field(
        ...,
        description="Original speech transcript received",
    )
    raw_entities: Dict[str, Any] = Field(
        default_factory=dict,
        description="Extracted intermediate entity tokens and units",
    )
