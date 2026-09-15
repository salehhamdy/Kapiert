"""
Kapiert — FastAPI Backend
Serves German noun articles from the german-nouns dataset (~100k words)
with automatic fallback to the Wiktionary REST API.
"""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings
from dataset import load_dataset
from routes.health import router as health_router
from routes.lookup import router as lookup_router
from routes.random import router as random_router


@asynccontextmanager
async def lifespan(_: FastAPI):
    load_dataset()
    yield


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title=settings.app_name,
        description=settings.app_description,
        version=settings.app_version,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health_router)
    app.include_router(lookup_router)
    app.include_router(random_router)

    return app


app = create_app()


if __name__ == "__main__":
    import uvicorn

    settings = get_settings()
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.reload,
    )
