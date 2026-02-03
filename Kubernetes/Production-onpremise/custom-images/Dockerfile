# Use the already-built image as base
FROM git.mcf.co.id:5050/moofi/moofi-production-kube/ocr-app/account:0.0.3

# Install curl and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
