#!/usr/bin/env bash

# Filename:    verify_signatures.sh
# Author:      Homelab-Alpha
# Date:        2026-10-29
# Version:     1.0.0

# Description: Verifies that recent commits and/or tags in a GitHub repository
#              carry a verified signature. Uses the GitHub API exclusively via
#              GitHub CLI (gh).
#
#              For tags, verification checks the UNDERLYING COMMIT that the tag
#              points to, because GitHub's "Verified" badge on tags is derived
#              from the commit's signature, not from the tag object itself.
#
# Usage:
#   # Verify the last 10 commits (default)
#   ./scripts/verify_signatures.sh
#
#   # Verify a specific number of commits
#   ./scripts/verify_signatures.sh --commits 25
#
#   # Verify tags only
#   ./scripts/verify_signatures.sh --tags-only
#
#   # Verify both commits and tags
#   ./scripts/verify_signatures.sh --commits 10 --tags 5
#
#   # Strict mode: exit 1 on first unverified object
#   ./scripts/verify_signatures.sh --strict
#
# Environment Variables:
#   GH_TOKEN          — GitHub token for API access (set automatically in CI).
#   GITHUB_REPOSITORY — Owner/repo (set automatically in CI, or pass --repo).

set -Eeuo pipefail

# ── Defaults ─────────────────────────────────────────────────────────────────
COMMIT_COUNT=10
TAG_COUNT=0
CHECK_COMMITS=true
CHECK_TAGS=false
STRICT=false
REPO="${GITHUB_REPOSITORY:-}"
EXIT_CODE=0

# ── Parse arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --commits)
      COMMIT_COUNT="${2:?'--commits requires a number'}"
      CHECK_COMMITS=true
      shift 2
      ;;
    --tags)
      TAG_COUNT="${2:?'--tags requires a number'}"
      CHECK_TAGS=true
      shift 2
      ;;
    --tags-only)
      CHECK_COMMITS=false
      CHECK_TAGS=true
      [[ "$TAG_COUNT" -eq 0 ]] && TAG_COUNT=10
      shift
      ;;
    --strict)
      STRICT=true
      shift
      ;;
    --repo)
      REPO="${2:?'--repo requires owner/repo'}"
      shift 2
      ;;
    --help|-h)
      head -n 30 "$0" | tail -n +3 | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "::error title=Unknown argument::❌ Unknown argument: $1"
      exit 1
      ;;
  esac
done

# ── Validate ─────────────────────────────────────────────────────────────────
if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true)
  if [[ -z "$REPO" ]]; then
    echo "::error title=Repository unknown::❌ Could not determine repository. Set GITHUB_REPOSITORY or use --repo."
    exit 1
  fi
fi

if ! command -v gh &>/dev/null; then
  echo "::error title=Missing dependency::❌ GitHub CLI (gh) is required but not installed."
  exit 1
fi

# ── Verify commits ───────────────────────────────────────────────────────────
VERIFIED_COUNT=0
UNVERIFIED_COUNT=0
TOTAL_COUNT=0

if [[ "$CHECK_COMMITS" == "true" ]]; then
  echo "::group::🔍 Verifying last $COMMIT_COUNT commit(s) in $REPO"

  COMMITS_RAW=$(gh api "repos/$REPO/commits?per_page=$COMMIT_COUNT" \
    --jq '.[] | [
      .sha[0:7],
      (.commit.verification.verified | tostring),
      (.commit.verification.reason // "unknown"),
      (.author.login // .commit.author.name // "unknown"),
      (.commit.message | split("\n") | .[0] | .[0:72])
    ] | @tsv' 2>/dev/null) || {
    echo "::error title=API error::❌ Failed to fetch commits from GitHub API."
    echo "::endgroup::"
    exit 1
  }

  while IFS=$'\t' read -r sha verified reason author message; do
    [[ -z "$sha" ]] && continue

    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    if [[ "$verified" == "true" ]]; then
      VERIFIED_COUNT=$((VERIFIED_COUNT + 1))
      echo "  ✅ $sha — $message (@$author)"
    else
      UNVERIFIED_COUNT=$((UNVERIFIED_COUNT + 1))
      echo "  ❌ $sha — $message (@$author) [reason: $reason]"

      if [[ "$STRICT" == "true" ]]; then
        echo "::error title=Unverified commit::❌ Commit $sha by @$author is not verified (reason: $reason)"
        EXIT_CODE=1
      fi
    fi
  done <<< "$COMMITS_RAW"

  echo ""
  echo "  Summary: $VERIFIED_COUNT/$TOTAL_COUNT verified, $UNVERIFIED_COUNT unverified"

  if [[ "$UNVERIFIED_COUNT" -gt 0 ]]; then
    echo "::warning title=Unverified commits::⚠️ $UNVERIFIED_COUNT of $TOTAL_COUNT commit(s) are not verified."
  else
    echo "::notice title=All commits verified::✅ All $TOTAL_COUNT commit(s) are verified."
  fi

  echo "::endgroup::"
fi

# ── Verify tags ──────────────────────────────────────────────────────────────
TAG_VERIFIED_COUNT=0
TAG_UNVERIFIED_COUNT=0
TAG_TOTAL_COUNT=0

if [[ "$CHECK_TAGS" == "true" ]]; then
  echo "::group::🔍 Verifying last $TAG_COUNT tag(s) in $REPO"

  TAG_NAMES=$(gh api "repos/$REPO/tags?per_page=$TAG_COUNT" \
    --jq '.[].name' 2>/dev/null) || {
    echo "::error title=API error::❌ Failed to fetch tags from GitHub API."
    echo "::endgroup::"
    exit 1
  }

  if [[ -z "$TAG_NAMES" ]]; then
    echo "  ℹ️ No tags found in repository."
    echo "::notice title=No tags::ℹ️ No tags found to verify."
    echo "::endgroup::"
  else
    while IFS= read -r tag_name; do
      [[ -z "$tag_name" ]] && continue

      TAG_TOTAL_COUNT=$((TAG_TOTAL_COUNT + 1))

      # Resolve the tag ref to determine type and SHA
      REF_DATA=$(gh api "repos/$REPO/git/ref/tags/$tag_name" \
        --jq '[.object.type, .object.sha] | @tsv' 2>/dev/null || echo "unknown	unknown")

      OBJ_TYPE=$(echo "$REF_DATA" | cut -f1)
      OBJ_SHA=$(echo "$REF_DATA" | cut -f2)

      # Resolve to the underlying commit SHA
      if [[ "$OBJ_TYPE" == "tag" ]]; then
        # Annotated tag — resolve the tag object to get the commit SHA
        COMMIT_SHA=$(gh api "repos/$REPO/git/tags/$OBJ_SHA" \
          --jq '.object.sha' 2>/dev/null || echo "unknown")
        TAG_TYPE_LABEL="annotated"
      elif [[ "$OBJ_TYPE" == "commit" ]]; then
        # Lightweight tag — points directly to the commit
        COMMIT_SHA="$OBJ_SHA"
        TAG_TYPE_LABEL="lightweight"
      else
        echo "  ⚠️ $tag_name (unknown type: $OBJ_TYPE)"
        TAG_UNVERIFIED_COUNT=$((TAG_UNVERIFIED_COUNT + 1))
        continue
      fi

      # Verify the COMMIT the tag points to (this is what GitHub UI shows)
      COMMIT_VERIFY=$(gh api "repos/$REPO/commits/$COMMIT_SHA" \
        --jq '[(.commit.verification.verified | tostring), (.commit.verification.reason // "unknown")] | @tsv' \
        2>/dev/null || echo "false	api_error")

      COMMIT_VERIFIED=$(echo "$COMMIT_VERIFY" | cut -f1)
      COMMIT_REASON=$(echo "$COMMIT_VERIFY" | cut -f2)

      if [[ "$COMMIT_VERIFIED" == "true" ]]; then
        TAG_VERIFIED_COUNT=$((TAG_VERIFIED_COUNT + 1))
        echo "  ✅ $tag_name ($TAG_TYPE_LABEL → ${COMMIT_SHA:0:7} verified)"
      else
        TAG_UNVERIFIED_COUNT=$((TAG_UNVERIFIED_COUNT + 1))
        echo "  ❌ $tag_name ($TAG_TYPE_LABEL → ${COMMIT_SHA:0:7} NOT verified) [reason: $COMMIT_REASON]"

        if [[ "$STRICT" == "true" ]]; then
          echo "::error title=Unverified tag::❌ Tag $tag_name points to unverified commit ${COMMIT_SHA:0:7} (reason: $COMMIT_REASON)"
          EXIT_CODE=1
        fi
      fi
    done <<< "$TAG_NAMES"

    echo ""
    echo "  Summary: $TAG_VERIFIED_COUNT/$TAG_TOTAL_COUNT verified, $TAG_UNVERIFIED_COUNT unverified"

    if [[ "$TAG_UNVERIFIED_COUNT" -gt 0 ]]; then
      echo "::warning title=Unverified tags::⚠️ $TAG_UNVERIFIED_COUNT of $TAG_TOTAL_COUNT tag(s) point to unverified commits."
    else
      echo "::notice title=All tags verified::✅ All $TAG_TOTAL_COUNT tag(s) point to verified commits."
    fi

    echo "::endgroup::"
  fi
fi

# ── Job summary (if running in CI) ──────────────────────────────────────────
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## 🔏 Signature Verification Report"
    echo ""
    echo "Repository: \`$REPO\`"
    echo "Verified at: $(date -u)"
    echo ""

    if [[ "$CHECK_COMMITS" == "true" ]]; then
      echo "### Commits (last $COMMIT_COUNT)"
      echo ""
      echo "| Status | Verified | Unverified |"
      echo "| :----- | :------: | :--------: |"
      echo "| Result | $VERIFIED_COUNT | $UNVERIFIED_COUNT |"
      echo ""
    fi

    if [[ "$CHECK_TAGS" == "true" ]]; then
      echo "### Tags (last $TAG_COUNT)"
      echo ""
      echo "| Status | Verified | Unverified |"
      echo "| :----- | :------: | :--------: |"
      echo "| Result | $TAG_VERIFIED_COUNT | $TAG_UNVERIFIED_COUNT |"
      echo ""
    fi

    echo "### How Tag Verification Works"
    echo ""
    echo "Tags inherit their \"Verified\" status from the **commit** they point to."
    echo "A tag is considered verified if its underlying commit has a valid signature."
    echo ""
  } >> "$GITHUB_STEP_SUMMARY"
fi

exit $EXIT_CODE
