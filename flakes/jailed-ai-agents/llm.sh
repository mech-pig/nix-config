#!/usr/bin/env bash

SOURCE_DIR="$HOME/Developer/nix-config/flakes/jailed-ai-agents"

AGENT_CMD=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
  --claude)
    AGENT_CMD="jailed-claude"
    shift
    ;;
  --gemini)
    AGENT_CMD="jailed-gemini"
    shift
    ;;
  --opencode)
    AGENT_CMD="jailed-opencode"
    shift
    ;;
  -h | --help)
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Options:"
    echo "  --claude    Run Claude agent"
    echo "  -h, --help  Show this help message"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [ -z "$AGENT_CMD" ]; then
  echo "Error: No agent specified. Use --claude, --gemini, or --opencode"
  exit 1
fi

if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR=$(pwd)
fi
export PROJECT_DIR

if [ ! -f "$SOURCE_DIR/flake.nix" ]; then
  echo "Error: Source flake.nix not found in $SOURCE_DIR"
  exit 1
fi

echo "Running $AGENT_CMD on $PROJECT_DIR..."
exec nix --extra-experimental-features flakes --extra-experimental-features nix-command develop "$SOURCE_DIR" -c "$AGENT_CMD"