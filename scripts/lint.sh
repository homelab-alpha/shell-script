#!/usr/bin/env bash

# Filename:    lint.sh
# Author:      Homelab-Alpha
# Date:        2026-10-25
# Version:     1.1.0

# Description: Fast, local-first lint that follows the same rules as the Super
#              Linter run on `main`: Prettier (JS, JSON, Markdown, YAML),
#              textlint terminology (Markdown, text), and merge conflict
#              markers. It does not replace Super Linter: actionlint,
#              gitleaks, Checkov, and the other linters run only there.
#
#              Every problem is printed with its file and line. In GitHub
#              Actions each one also becomes an annotation on the pull request.
#              With --fix the simple problems (formatting, wrapping, and
#              terminology that textlint can fix) are repaired in place; check
#              the result with `git diff` before you commit.
#
# Usage:
#   # Lint every tracked file
#   npm run lint
#
#   # Lint only the files changed since a base ref (used for pull requests)
#   npm run lint -- origin/main
#
#   # Fix what can be fixed, then lint again
#   npm run lint:fix
#   npm run lint:fix -- origin/main

set -Eeuo pipefail

cd "$(git rev-parse --show-toplevel)"

fix=0
if [ "${1:-}" = "--fix" ]; then
  fix=1
  shift
fi
base="${1:-}"

failed=0
problems=()
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

group() { if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::group::$1"; else echo "== $1"; fi; }
endgroup() { if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::endgroup::"; fi; }

# problem <file> <line> <tool> <message>: one problem, as text and as a pull request annotation.
problem() {
  local file="$1" line="${2:-1}" tool="$3" msg="$4"
  failed=1
  problems+=("| \`${file}\` | ${line} | ${tool} | ${msg//|/\\|} |")
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "::error file=${file},line=${line},title=${tool}::${msg}"
  else
    echo "${file}:${line}: [${tool}] ${msg}"
  fi
}

if [ -n "$base" ]; then
  mapfile -t candidates < <(git diff --name-only --diff-filter=ACMR "${base}...HEAD")
else
  mapfile -t candidates < <(git ls-files)
fi

files=()
for f in "${candidates[@]}"; do
  [ -f "$f" ] && files+=("$f")
done

pick() {
  local pattern="$1" f
  for f in "${files[@]}"; do
    [[ "$f" =~ $pattern ]] && printf '%s\n' "$f"
  done
}

mapfile -t pretty < <(pick '\.(js|cjs|mjs|json|md|yml|yaml)$')
mapfile -t prose < <(pick '\.(md|txt)$')

echo "Files to check: ${#files[@]} (Prettier: ${#pretty[@]}, textlint: ${#prose[@]})"
[ "$fix" -eq 1 ] && echo "Fix mode: simple problems are repaired in place."

group "Prettier"
if [ "${#pretty[@]}" -gt 0 ]; then
  if [ "$fix" -eq 1 ]; then
    npx --no-install prettier --write --ignore-unknown --log-level warn -- "${pretty[@]}" || true
  fi
  set +e
  listed=$(npx --no-install prettier --list-different --ignore-unknown -- "${pretty[@]}" 2>"$tmp")
  code=$?
  set -e
  if [ -n "$listed" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      first=$(diff <(npx --no-install prettier "$f" 2>/dev/null) "$f" | grep -m1 -oE '^[0-9]+' || true)
      problem "$f" "${first:-1}" "Prettier" "The file is not formatted. Run 'npm run lint:fix'."
      echo "--- what Prettier would change in $f (first lines):"
      diff <(npx --no-install prettier "$f" 2>/dev/null) "$f" | head -n 12 || true
    done <<<"$listed"
  fi
  # Prettier prints `[error] <file>: SyntaxError: ...` for a file it cannot parse (for example invalid YAML).
  if grep -q '^\[error\]' "$tmp"; then
    cat "$tmp"
    while IFS= read -r line; do
      if [[ "$line" =~ ^\[error\]\ ([^:\ ]+):\ ([A-Za-z]*Error:\ .*)$ ]]; then
        bad="${BASH_REMATCH[1]}"
        msg="${BASH_REMATCH[2]}"
        at=1
        [[ "$msg" =~ \(([0-9]+):[0-9]+\)$ ]] && at="${BASH_REMATCH[1]}"
        problem "$bad" "$at" "Prettier" "$msg"
      fi
    done < <(grep '^\[error\]' "$tmp")
  elif [ "$code" -ne 0 ] && [ -z "$listed" ]; then
    cat "$tmp"
    problem "${pretty[0]}" 1 "Prettier" "Prettier failed. See the log for the error."
  elif [ -z "$listed" ]; then
    echo "All files are formatted."
  fi
else
  echo "No files to check."
fi
endgroup

group "textlint"
if [ "${#prose[@]}" -gt 0 ]; then
  if [ "$fix" -eq 1 ]; then
    npx --no-install textlint --config .github/linters/.textlintrc --fix -- "${prose[@]}" >/dev/null 2>&1 || true
  fi
  set +e
  out=$(npx --no-install textlint --config .github/linters/.textlintrc --format unix -- "${prose[@]}" 2>&1)
  code=$?
  set -e
  if [ "$code" -ne 0 ]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^(.+):([0-9]+):([0-9]+):\ (.*)\ \[(Error|Warning)/(.*)\]$ ]]; then
        problem "${BASH_REMATCH[1]#"$PWD/"}" "${BASH_REMATCH[2]}" "textlint" "${BASH_REMATCH[4]}"
      elif [ -n "$line" ] && ! [[ "$line" =~ ^[0-9]+\ problems?$ ]]; then
        echo "$line"
      fi
    done <<<"$out"
    [ "$failed" -eq 1 ] || problem "${prose[0]}" 1 "textlint" "textlint failed. See the log for the error."
  else
    echo "No terminology problems."
  fi
else
  echo "No files to check."
fi
endgroup

group "Merge conflict markers"
if [ "${#files[@]}" -gt 0 ]; then
  found=0
  while IFS=: read -r f n _; do
    [ -n "$f" ] || continue
    found=1
    problem "$f" "$n" "Merge conflict" "Unresolved merge conflict marker."
  done < <(grep -InE '^(<{7}|>{7})( |$)' -- "${files[@]}" || true)
  [ "$found" -eq 1 ] || echo "No markers found."
fi
endgroup

if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && [ "${#problems[@]}" -gt 0 ]; then
  {
    echo "## 🧹 Lint problems"
    echo ""
    echo "| File | Line | Check | Problem |"
    echo "| :--- | :--- | :---- | :------ |"
    printf '%s\n' "${problems[@]}"
    echo ""
    echo "Run \`npm run lint:fix -- origin/main\` locally to repair formatting and terminology."
  } >>"$GITHUB_STEP_SUMMARY"
fi

if [ "$failed" -ne 0 ]; then
  echo ""
  echo "Lint failed with ${#problems[@]} problem(s)."
  echo "Run 'npm run lint:fix' to repair formatting and terminology, then check 'git diff'."
  exit 1
fi
echo "Lint passed."
