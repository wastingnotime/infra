#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_FILE="${STACK_FILE:-${ROOT_DIR}/stacks/blog.yml}"
STACK_NAME="${STACK_NAME:-wnt}"

: "${EVENT_QUEUE_URL:?EVENT_QUEUE_URL is required}"
: "${PLAUSIBLE_SHARED_SECRET:?PLAUSIBLE_SHARED_SECRET is required}"

EVENT_QUEUE_URL="${EVENT_QUEUE_URL}" \
PLAUSIBLE_SHARED_SECRET="${PLAUSIBLE_SHARED_SECRET}" \
docker stack deploy -c "${STACK_FILE}" "${STACK_NAME}"
