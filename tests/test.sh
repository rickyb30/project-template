#!/usr/bin/env bash
# Render the template with defaults and with every option set, then run the generated
# project's own checks. Needs copier and git; uses temp directories only.
# The suite checks the exit status of [ ... ] conditions on purpose.
# shellcheck disable=SC2319
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
command -v copier >/dev/null 2>&1 || {
  echo "tests: copier is not installed (pipx install copier, or brew install copier)." >&2
  exit 1
}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/project-template-tests.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

fail=0
check() {
  if [ "$2" = "$3" ]; then return 0; fi
  printf '  FAIL  %s (expected %s, got %s)\n' "$1" "$2" "$3"
  fail=$((fail + 1))
}
has() {
  if [ -e "$2" ]; then return 0; fi
  printf '  FAIL  %s: missing %s\n' "$1" "${2#"$TMP"/}"
  fail=$((fail + 1))
}

# copier reads the template from git when the folder is a repository, so render a copy.
SRC="$TMP/src"
mkdir -p "$SRC"
(cd "$REPO" && tar cf - --exclude .git .) | (cd "$SRC" && tar xf -)

echo "defaults"
A="$TMP/defaults"
copier copy --defaults --quiet -d project_name="Example Project" "$SRC" "$A" >/dev/null 2>&1
check "copier copy with defaults" 0 $?
for path in CLAUDE.md .copier-answers.yml .claude/pipeline.json .claude/settings.json \
  .claude/skills/project-conventions/SKILL.md docs/requirements.md \
  docs/architecture/000-template.md docs/knowledge/INDEX.md docs/knowledge/CONTRIBUTING.md \
  docs/knowledge/inbox docs/plans docs/reviews docs/research docs/adr \
  scripts/verify.sh .githooks/pre-commit .github/workflows/ci.yml .gitignore; do
  has "defaults" "$A/$path"
done
[ -x "$A/scripts/verify.sh" ] && [ -x "$A/.githooks/pre-commit" ]
check "scripts are executable" 0 $?
jq -e '. == {}' "$A/.claude/pipeline.json" >/dev/null 2>&1
check "pipeline.json gates everything by default" 0 $?
jq -e 'type == "object"' "$A/.claude/settings.json" >/dev/null 2>&1
check "settings.json is valid JSON" 0 $?
grep -q "example-project" "$A/.copier-answers.yml"
check "slug derived from the name" 0 $?
if grep -r -I -l -E '\{\{|\{%' "$A" | grep -v '/.github/' >/dev/null; then
  check "no unrendered template syntax" 0 1
fi
(cd "$A" && git init -q && bash scripts/verify.sh >"$TMP/verify-a.log" 2>&1)
check "generated verify.sh passes on first run" 0 $?

echo "all options"
B="$TMP/full"
copier copy --defaults --quiet \
  -d project_name="Order Sync" -d project_slug="order-sync" \
  -d description="Keeps a fictional order feed in step." -d stack="Python, SQL" \
  -d lint_command="true" -d typecheck_command="true" -d test_command="true" \
  -d source_paths="src, tests,infra/" -d ci_provider="none" "$SRC" "$B" >/dev/null 2>&1
check "copier copy with every option" 0 $?
[ ! -e "$B/.github" ]
check "no CI folder when ci_provider is none" 0 $?
jq -e '.source_paths == ["src","tests","infra"]' "$B/.claude/pipeline.json" >/dev/null 2>&1
check "source_paths rendered as a clean list" 0 $?
grep -q "Python, SQL" "$B/CLAUDE.md"
check "stack reaches CLAUDE.md" 0 $?
(cd "$B" && git init -q && bash scripts/verify.sh >"$TMP/verify-b.log" 2>&1)
check "verify.sh passes with commands configured" 0 $?
grep -q "ok    lint" "$TMP/verify-b.log"
check "configured lint command ran" 0 $?

echo "failing check"
C="$TMP/failing"
copier copy --defaults --quiet -d project_name="Broken" -d test_command="false" "$SRC" "$C" >/dev/null 2>&1
(cd "$C" && git init -q && bash scripts/verify.sh >/dev/null 2>&1)
check "verify.sh fails when a check fails" 1 $?

echo "bad pipeline doc"
printf -- '---\nstatus: aproved\n---\n# x\n' >"$A/docs/plans/001-x.md"
(cd "$A" && bash scripts/verify.sh >/dev/null 2>&1)
check "verify.sh rejects an unknown status value" 1 $?

echo
if [ "$fail" -gt 0 ]; then
  echo "tests: $fail failed."
  sed 's/^/    /' "$TMP/verify-a.log" 2>/dev/null | tail -20
  exit 1
fi
echo "tests: ok."
