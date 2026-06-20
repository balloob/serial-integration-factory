#!/usr/bin/env bash
#
# setup.sh — fetch the reference repositories used when building serial-based
# Home Assistant integrations.
#
# Clones (shallow) into ./reference:
#   - home-assistant/core             -> reference/home-assistant-core (branch: dev)
#       Integration structure, config flow, and existing serial integrations.
#   - home-assistant-libs/denon-rs232 -> reference/denon-rs232         (branch: main)
#       Example serial library — receiver/AVR device.
#   - home-assistant-libs/lg-rs232-tv -> reference/lg-rs232-tv         (branch: main)
#       Example serial library — TV device.
#   - ludeeus/integration_blueprint   -> reference/integration_blueprint (branch: main)
#       HACS-installable custom integration template.
#
# Re-running updates existing clones instead of failing.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="$REPO_ROOT/reference"

mkdir -p "$REF_DIR"

# clone_or_update <git-url> <dest-dir> <branch>
clone_or_update() {
  local url="$1" dest="$2" branch="$3"

  if [ -d "$dest/.git" ]; then
    echo "==> Updating $(basename "$dest") ($branch)"
    git -C "$dest" fetch --depth 1 origin "$branch"
    git -C "$dest" checkout "$branch"
    git -C "$dest" reset --hard "origin/$branch"
  else
    echo "==> Cloning $(basename "$dest") ($branch)"
    git clone --depth 1 --single-branch --branch "$branch" "$url" "$dest"
  fi
}

clone_or_update "https://github.com/home-assistant/core.git" \
  "$REF_DIR/home-assistant-core" "dev"

clone_or_update "https://github.com/home-assistant-libs/denon-rs232.git" \
  "$REF_DIR/denon-rs232" "main"

clone_or_update "https://github.com/home-assistant-libs/lg-rs232-tv.git" \
  "$REF_DIR/lg-rs232-tv" "main"

clone_or_update "https://github.com/ludeeus/integration_blueprint.git" \
  "$REF_DIR/integration_blueprint" "main"

echo
echo "Done. Reference repositories are in: $REF_DIR"
