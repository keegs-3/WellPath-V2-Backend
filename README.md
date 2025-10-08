# WellPath V2 Backend

FastAPI-based scoring engine with Supabase integration.

## Architecture

- **FastAPI** - Modern Python web framework
- **Supabase** - PostgreSQL database with superior schema
- **14 Adherence Algorithms** - Production-ready scoring system
- **HealthKit Integration** - Metric types mirror Apple HealthKit

## Project Structure

```
WellPath-V2-Backend/
├── api/                    # FastAPI application
│   ├── main.py            # Entry point
│   ├── routers/           # API endpoints
│   └── dependencies.py    # Shared dependencies
├── scoring_engine/        # Core scoring logic
│   ├── algorithms/        # 14 adherence algorithms
│   ├── runners/           # WellPath score runners
│   └── utils/             # Shared utilities
├── database/              # Database layer
│   ├── supabase_client.py
│   └── models.py
├── supabase/              # Database migrations & sync
│   ├── migrations/
│   └── sync_scripts/
├── scripts/               # Utility scripts
└── tests/                 # Test suite
```

## Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn api.main:app --reload --port 8000
```

## API Endpoints

- `GET /health` - Health check
- `POST /api/v1/scores/calculate` - Calculate patient scores
- `GET /api/v1/scores/patient/{patient_id}` - Get patient scores
- `GET /api/v1/scores/pillar/{pillar_id}` - Get pillar breakdown

## Environment Variables

Create `.env` file:

```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
DATABASE_URL=your_database_connection_string
```

## Development

This is the V2 backend - a complete rewrite with:
- Superior Supabase schema (vs legacy RDS)
- Config-driven adherence algorithms
- HealthKit-mirrored metric types
- Proper many-to-many relationships via junction tables

## License

Proprietary - WellPath Inc.
