#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but not installed." >&2
    exit 1
fi

current_name="$(git config --global --get user.name || true)"
current_email="$(git config --global --get user.email || true)"

if [ -n "$current_name" ]; then
    printf 'Current global user.name: %s\n' "$current_name"
fi

if [ -n "$current_email" ]; then
    printf 'Current global user.email: %s\n' "$current_email"
fi

printf 'GitHub username: '
read -r github_username

printf 'GitHub email: '
read -r github_email

if [ -z "$github_username" ]; then
    echo "Error: GitHub username cannot be empty." >&2
    exit 1
fi

if [ -z "$github_email" ]; then
    echo "Error: GitHub email cannot be empty." >&2
    exit 1
fi

git config --global user.name "$github_username"
git config --global user.email "$github_email"

printf 'Configured git user.name=%s and user.email=%s\n' "$github_username" "$github_email"
