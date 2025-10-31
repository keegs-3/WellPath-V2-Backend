"""WellPath V2 Backend - FastAPI Application."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import os

from database.models import HealthCheckResponse

# Import routers
from api.routers import adherence

app = FastAPI(
    title="WellPath V2 API",
    description="AI-powered health platform with intelligent adherence tracking, personalized nudges, and adaptive challenges",
    version="2.1.0",
)

# CORS Configuration
allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:8081").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "name": "WellPath V2 API",
        "version": "2.0.0",
        "status": "operational",
        "docs": "/docs"
    }


@app.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """Health check endpoint."""
    return HealthCheckResponse(
        status="healthy",
        version="2.0.0",
        database="supabase",
        timestamp=datetime.now()
    )


# Include routers
app.include_router(adherence.router, prefix="/api/v1", tags=["adherence"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)
