"""WellPath V2 Backend - FastAPI Application."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import os

from database.models import HealthCheckResponse

# Import routers (will create next)
# from api.routers import scores, patients, recommendations

app = FastAPI(
    title="WellPath V2 API",
    description="Production-ready scoring engine with 14 adherence algorithms",
    version="2.0.0",
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
# app.include_router(scores.router, prefix="/api/v1/scores", tags=["scores"])
# app.include_router(patients.router, prefix="/api/v1/patients", tags=["patients"])
# app.include_router(recommendations.router, prefix="/api/v1/recommendations", tags=["recommendations"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)
