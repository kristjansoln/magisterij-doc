#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_FILE="${1:-main.tex}"
PODMAN_IMAGE="${LATEX_PODMAN_IMAGE:-docker.io/texlive/texlive:latest}"

usage() {
    cat <<'EOF'
Usage: ./build-podman.sh [root-file]

Builds the LaTeX document with the same latexmk flow used in CI:
  latexmk -pdf -bibtex -file-line-error -halt-on-error -interaction=nonstopmode

Behavior:
  - Uses local latexmk when available.
  - Falls back to Podman otherwise.

Environment:
  LATEX_PODMAN_IMAGE  Override the Podman image used for fallback builds.
EOF
}

if [[ "${ROOT_FILE}" == "-h" || "${ROOT_FILE}" == "--help" ]]; then
    usage
    exit 0
fi

cd "${SCRIPT_DIR}"

if [[ ! -f "${ROOT_FILE}" ]]; then
    echo "Root file not found: ${ROOT_FILE}" >&2
    exit 1
fi

build_with_latexmk() {
    latexmk \
        -pdf \
        -bibtex \
        -file-line-error \
        -halt-on-error \
        -interaction=nonstopmode \
        "${ROOT_FILE}"
}

if command -v latexmk >/dev/null 2>&1; then
    build_with_latexmk
    exit 0
fi

if ! command -v podman >/dev/null 2>&1; then
    echo "Neither latexmk nor podman is available." >&2
    exit 1
fi

podman run --rm \
    --userns keep-id \
    --volume "${SCRIPT_DIR}:/work" \
    --workdir /work \
    "${PODMAN_IMAGE}" \
    latexmk \
    -pdf \
    -bibtex \
    -file-line-error \
    -halt-on-error \
    -interaction=nonstopmode \
    "${ROOT_FILE}"
