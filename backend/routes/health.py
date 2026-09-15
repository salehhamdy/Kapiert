"""Health and service metadata endpoints."""

from __future__ import annotations

from fastapi import APIRouter

from config import get_settings
from dataset import dataset_ready, nouns_loaded
from models import HealthResponse

router = APIRouter(tags=["health"])


@router.get("/", response_model=HealthResponse)
@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    settings = get_settings()
    return HealthResponse(
        service=settings.app_name,
        version=settings.app_version,
        status="ok" if dataset_ready() else "degraded",
        nouns_loaded=nouns_loaded(),
        dataset_ready=dataset_ready(),
        supabase_configured=settings.supabase_enabled,
        endpoints=[
            "GET /lookup/{word}",
            "GET /random",
            "GET /random/batch/{count}",
        ],
    )
