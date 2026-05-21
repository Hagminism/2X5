#!/bin/bash
# Move to project root
cd "$(dirname "$0")/.."

# Check if .venv exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment (.venv) not found at project root."
    echo "Please make sure you have run venv setup or execute run_proxy.sh in the project directory."
    exit 1
fi

echo "Starting Naver Local Proxy Server..."
# Run local uvicorn fastapi application
.venv/bin/python3 scripts/local_naver_proxy.py
