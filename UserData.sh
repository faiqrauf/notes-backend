#!/bin/bash
set -e

GIT_REPO_URL="https://github.com/faiqrauf/notes_backend.git"

PROJECT_MAIN_DIR_NAME="notes_backend"

git clone "$GIT_REPO_URL" "/home/ubuntu/$PROJECT_MAIN_DIR_NAME"

cd "/home/ubuntu/$PROJECT_MAIN_DIR_NAME"

chmod +x scripts/*.sh

# Execute scripts for OS dependencies, Python dependencies, Gunicorn, Nginx, and starting the application
./scripts/instance_os_dependencies.sh
./scripts/python_dependencies.sh
./scripts/gunicorn.sh
./scripts/nginx.sh
./scripts/start_app.sh