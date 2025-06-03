#!/bin/bash

set -o allexport
source .env 2>/dev/null
set +o allexport

# Define defaults (used only if not set in .env or environment)
USER="${USER:-defaultuser}"
PASS="${PASS:-defaultpass}"
HOST="${HOST:-127.0.0.1}"
VOLUMENAME="${VOLUMENAME:-/mnt/default-backup}"
DOCKER_IMAGE="${DOCKER_IMAGE:-synopcloud}"
CONTAINER_NAME="${CONTAINER_NAME:-synopcloud-container}"
BACKUP_VOLUME="${BACKUP_VOLUME:-/volume1/backup}"

# Function to log messages with a timestamp
function log() {
    echo "`date '+%Y/%m/%d %H:%M:%S'` INFO  : $*"
}

# Function to log errors with a timestamp
function log_error() {
    echo "`date '+%Y/%m/%d %H:%M:%S'` ERROR : $*" >&2
}

# Check if the Docker image exists
if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
    log "Docker image $DOCKER_IMAGE does not exist. Attempting to build..."

    # Check if Dockerfile exists in the current directory
    if [[ -f "./Dockerfile" ]]; then
        log "Dockerfile found. Building image $DOCKER_IMAGE..."
        if docker build --no-cache -t $DOCKER_IMAGE .; then
            log "Successfully built Docker image $DOCKER_IMAGE."
        else
            log_error "Failed to build Docker image $DOCKER_IMAGE. Exiting."
            exit 1
        fi
    else
        log_error "Dockerfile not found in current directory. Cannot build $DOCKER_IMAGE. Exiting."
        exit 1
    fi
else
    log "Docker image $DOCKER_IMAGE already exists."
fi

# Check if the Docker container is already running
if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    log_error "Docker container $CONTAINER_NAME is already running. Exiting."
    exit 1
fi

for var in HOST USER PASS VOLUMENAME; do
    if [[ -z "${!var}" ]]; then
        log_error "Environment variable $var is not set. Exiting."
        exit 1
    fi
done

# Log the start of the script
log "Starting Docker container for NAS backup..."

# Run the Docker container
docker run --rm --privileged \
    --name "$CONTAINER_NAME" \
    -v "$BACKUP_VOLUME:/mnt/backup:ro" \
    -v /etc/localtime:/etc/localtime:ro \
	-e HOST="$HOST" \
    -e USER="$USER" \
    -e PASS="$PASS" \
    -e VOLUMENAME="$VOLUMENAME" \
    "$DOCKER_IMAGE"

# Log the completion of the script
log "Docker container has finished running."
