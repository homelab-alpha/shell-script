#!/usr/bin/env bash

# Filename:    setup_gpg.sh
# Author:      Homelab-Alpha
# Date:        2026-10-29
# Version:     1.0.0

# Description: Configures signing for automated Git operations in GitHub Actions
#              workflows. Supports two strategies:
#
#              1. API signing (default) — Validates that GH_TOKEN / GITHUB_TOKEN
#                 is available. Commits created via the GitHub Contents API
#                 (gh api --method PUT "repos/$REPO/contents/...") and tags
#                 created via gh release create are automatically signed and
#                 marked as "Verified" by GitHub. No local Git or GPG
#                 configuration is needed.
#
#              2. GPG signing — For workflows that require local git commit or
#                 git tag (e.g., multi-file commits via Git Tree objects).
#                 Imports a GPG private key from secrets and configures Git
#                 accordingly.
#
# Usage:
#   API mode (default — just validates prerequisites):
#     source scripts/setup_gpg.sh --api
#
#   GPG mode (requires GPG_PRIVATE_KEY and optionally GPG_PASSPHRASE):
#     export GPG_PRIVATE_KEY="<base64-encoded-armored-key>"
#     export GPG_PASSPHRASE="<passphrase>"
#     source scripts/setup_gpg.sh --gpg
#
# Environment Variables:
#   GH_TOKEN / GITHUB_TOKEN — Required for API mode.
#   GPG_PRIVATE_KEY          — Base64-encoded, armor-exported GPG private key.
#   GPG_PASSPHRASE           — Passphrase for the GPG key (optional).
#   GITHUB_ACTIONS           — Set automatically by GitHub Actions runners.

set -Eeuo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
readonly SCRIPT_NAME="setup_gpg.sh"

# ── Functions ────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--api|--gpg]

Options:
  --api   Validate that GITHUB_TOKEN / GH_TOKEN is available for API-based
          signing. Commits via the Contents API and tags via gh release create
          are automatically verified. No local Git or GPG setup needed.
          (Default)

  --gpg   Import a GPG private key and configure local Git to sign commits
          and tags. Use only when local git commit / git tag is required.
          Requires GPG_PRIVATE_KEY environment variable.

  --help  Show this help message.
EOF
}

setup_api_signing() {
  echo "::group::🔏 Validating API signing prerequisites"

  local token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

  if [[ -z "$token" ]]; then
    echo "::error title=Signing setup failed::❌ Neither GH_TOKEN nor GITHUB_TOKEN is set."
    echo "::endgroup::"
    return 1
  fi

  # Verify the token has basic access
  local auth_check
  auth_check=$(gh auth status 2>&1 || true)

  if echo "$auth_check" | grep -qi "not logged in\|failed\|error"; then
    echo "::warning title=Token warning::⚠️ gh auth status reported issues. Commits via the API may not be verified."
    echo "$auth_check"
  fi

  echo "Mode:   API signing (Contents API + gh release create)"
  echo "Token:  Present (masked)"
  echo ""
  echo "How it works:"
  echo "  - Commits via gh api --method PUT 'repos/\$REPO/contents/...' are"
  echo "    automatically signed by GitHub and marked as Verified."
  echo "  - Tags via gh release create are automatically annotated and signed."
  echo "  - No local git config, GPG keys, or SSH keys required."

  echo "::notice title=Signing configured::🔏 API signing validated — token is present"
  echo "::endgroup::"
}

setup_gpg_signing() {
  echo "::group::🔏 Configuring GPG signing (local git fallback)"

  # ── Validate prerequisites ──────────────────────────────────────────────
  if [[ -z "${GPG_PRIVATE_KEY:-}" ]]; then
    echo "::error title=GPG setup failed::❌ GPG_PRIVATE_KEY environment variable is not set."
    echo "::endgroup::"
    return 1
  fi

  # ── Import the GPG key ─────────────────────────────────────────────────
  local import_output
  if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
    import_output=$(echo "$GPG_PRIVATE_KEY" | base64 -d \
      | gpg --batch --yes --pinentry-mode loopback \
            --passphrase "$GPG_PASSPHRASE" --import 2>&1) || {
      echo "::error title=GPG import failed::❌ Failed to import GPG key with passphrase."
      echo "$import_output"
      echo "::endgroup::"
      return 1
    }
  else
    import_output=$(echo "$GPG_PRIVATE_KEY" | base64 -d \
      | gpg --batch --yes --import 2>&1) || {
      echo "::error title=GPG import failed::❌ Failed to import GPG key."
      echo "$import_output"
      echo "::endgroup::"
      return 1
    }
  fi

  # ── Extract key ID ─────────────────────────────────────────────────────
  local gpg_key_id
  gpg_key_id=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null \
    | grep '^sec' \
    | head -n1 \
    | awk '{print $2}' \
    | cut -d'/' -f2)

  if [[ -z "$gpg_key_id" ]]; then
    echo "::error title=GPG key not found::❌ No secret key found after import."
    echo "::endgroup::"
    return 1
  fi

  # ── Mask sensitive values ──────────────────────────────────────────────
  echo "::add-mask::$gpg_key_id"

  # ── Configure Git ──────────────────────────────────────────────────────
  git config user.signingkey "$gpg_key_id"
  git config commit.gpgsign true
  git config tag.gpgSign true

  # ── Configure GPG agent for non-interactive use ────────────────────────
  local gnupg_home
  gnupg_home=$(gpgconf --list-dirs homedir 2>/dev/null || echo "$HOME/.gnupg")
  mkdir -p "$gnupg_home"

  if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
    cat > "$gnupg_home/gpg-agent.conf" <<AGENT_EOF
allow-preset-passphrase
default-cache-ttl 7200
max-cache-ttl 7200
AGENT_EOF

    gpgconf --kill gpg-agent 2>/dev/null || true
    gpgconf --launch gpg-agent 2>/dev/null || true

    # Preset the passphrase so git commit/tag won't prompt
    local keygrip
    keygrip=$(gpg --with-keygrip --list-secret-keys "$gpg_key_id" 2>/dev/null \
      | grep -A1 '^sec' \
      | grep 'Keygrip' \
      | awk '{print $3}')

    if [[ -n "$keygrip" ]]; then
      local hex_passphrase
      hex_passphrase=$(echo -n "$GPG_PASSPHRASE" | xxd -p | tr -d '\n')
      gpg-connect-agent "PRESET_PASSPHRASE $keygrip -1 $hex_passphrase" /bye 2>/dev/null || true
    fi
  fi

  echo "Git commit.gpgsign: $(git config commit.gpgsign)"
  echo "Git tag.gpgSign:    $(git config tag.gpgSign)"
  echo "Mode: GPG signing (local git commit/tag)"

  echo "::notice title=Signing configured::🔏 GPG signing configured for local git operations"
  echo "::endgroup::"
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  local mode="${1:---api}"

  case "$mode" in
    --api)
      setup_api_signing
      ;;
    --gpg)
      setup_gpg_signing
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "::error title=Invalid argument::❌ Unknown argument: $mode"
      usage
      exit 1
      ;;
  esac
}

main "$@"
