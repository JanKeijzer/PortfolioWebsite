#!/bin/bash

# Build the image if it doesn't exist
if ! docker image inspect mkdocs-site >/dev/null 2>&1; then
    echo "Building Docker image..."
    docker build -t mkdocs-site .
fi

echo "Starting MkDocs server..."
docker run -d \
    --name mkdocs-server \
    --restart unless-stopped \
    -p 8040:8000 \
    -v "$(pwd)":/docs \
    mkdocs-site

echo "Server running at http://localhost:8040/"
echo "Stop with: docker stop mkdocs-server"
