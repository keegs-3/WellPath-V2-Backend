#!/bin/bash
# WellPath API Server Startup Script

cd "$(dirname "$0")"

echo "🚀 Starting WellPath API Server..."
echo ""

# Activate virtual environment
source venv/bin/activate

# Add current directory to Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Start the server
python api/main.py
