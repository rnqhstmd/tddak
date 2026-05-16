#!/bin/bash
# tddak skill-load-guard.sh
# 식별 마커 자동 검증 hook
#
# 목적: tddak 스킬이 3중 식별 메커니즘(.claude/rules/identity.md)을 준수하는지 검증한다.
# 검증 실패 시 경고만 출력하고 차단하지 않는다 (개발 편의성).
#
# 실행 시점:
#   - 개발자가 새 스킬 추가 시 수동 실행
#   - CI에서 PR 검증 시 자동 실행
#
# 사용법:
#   bash skill-load-guard.sh                   # tddak 전체 스킬 검증
#   bash skill-load-guard.sh <스킬명>           # 특정 스킬만 검증
#   bash skill-load-guard.sh --strict          # 위반 1건이라도 있으면 exit 1
#
# 검증 항목 (identity.md 3중 메커니즘):
#   ① description 필드 [tddak/TDD 강제] 접두사 (충돌 스킬만)
#   ② SKILL.md 본문 헤더 # tddak:{skill-name}
#   ③ Skill() 호출 fully-qualified (tddak: 접두사)

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-/Users/bonseung/projects/tddak}"
SKILLS_DIR="$PLUGIN_ROOT/.claude/skills"
STRICT_MODE=0
TARGET_SKILL=""

# 인자 파싱
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT_MODE=1 ;;
    -*) echo "[WARN] 알 수 없는 옵션: $arg (무시)" >&2 ;;
    *) TARGET_SKILL="$arg" ;;
  esac
done

# ttutak과 이름이 충돌하는 스킬 (description 마커 필수)
COLLISION_SKILLS=("setup" "dev" "commit" "pull-request" "context" "lens" "tech-debt" "research")

# tddak 전용 스킬 (description 마커 강제 안 함, 본문 헤더만)
TDDAK_ONLY_SKILLS=("using-tddak" "red" "green" "refactor" "verify")

is_collision_skill() {
  local skill="$1"
  for s in "${COLLISION_SKILLS[@]}"; do
    [ "$s" = "$skill" ] && return 0
  done
  return 1
}

is_known_skill() {
  local skill="$1"
  for s in "${COLLISION_SKILLS[@]}" "${TDDAK_ONLY_SKILLS[@]}"; do
    [ "$s" = "$skill" ] && return 0
  done
  return 1
}

TOTAL_VIOLATIONS=0
TOTAL_CHECKED=0

check_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name=$(basename "$skill_dir")
  local skill_md="$skill_dir/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "[SKIP] $skill_name — SKILL.md 없음"
    return 0
  fi

  if ! is_known_skill "$skill_name"; then
    echo "[SKIP] $skill_name — 등록되지 않은 스킬"
    return 0
  fi

  TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
  local violations=0

  # ① description 마커 검증 (충돌 스킬만)
  if is_collision_skill "$skill_name"; then
    if ! grep -qE '^description:.*\[tddak/TDD 강제\]' "$skill_md"; then
      echo "[FAIL ①] $skill_name — description에 '[tddak/TDD 강제]' 접두사 누락"
      violations=$((violations + 1))
    fi
  fi

  # ② 본문 헤더 검증 (모든 스킬)
  if ! grep -qE "^# tddak:${skill_name}\$" "$skill_md"; then
    echo "[FAIL ②] $skill_name — 본문 헤더 '# tddak:${skill_name}' 누락"
    violations=$((violations + 1))
  fi

  # ② 보조 검증: 정체성 블록 4줄
  local identity_block_lines
  identity_block_lines=$(grep -cE '^> \*\*(플러그인|이 스킬|혼동 주의|호출 시 주의)\*\*' "$skill_md" || true)
  if [ "$identity_block_lines" -lt 4 ]; then
    echo "[WARN ②] $skill_name — 정체성 블록 4줄 중 ${identity_block_lines}줄만 발견 (플러그인/이 스킬/혼동 주의/호출 시 주의)"
    # WARN은 위반 카운트 안 함
  fi

  # ③ Skill() 호출 fully-qualified 검증
  # 의도된 "금지 예시"(ttutak:* 호출)는 제외하고, 접두사 없는 Skill("xxx") 호출만 검출
  # 패턴: Skill("XXX") where XXX does not start with tddak:, ttutak:, codex:, oh-my-claudecode:
  local bare_calls
  # 제외 패턴:
  #   - backtick으로 감싼 라인(`Skill(...)`): 코드 인용/금지 예시
  #   - 들여쓰기 라인(코드 블록 fence 안의 예시): 진짜 호출은 좌측 정렬이거나 backtick 인용
  #   - fully-qualified 호출(tddak:/ttutak:/codex: 등)
  bare_calls=$(grep -nE 'Skill\("[a-z][a-z0-9-]*"' "$skill_md" 2>/dev/null \
    | grep -v '`Skill' \
    | grep -vE '^[0-9]+:[[:space:]]+Skill\(' \
    | grep -vE 'Skill\("(tddak|ttutak|codex|oh-my-claudecode|claude-hud):[a-z-]+"' \
    || true)
  if [ -n "$bare_calls" ]; then
    echo "[FAIL ③] $skill_name — fully-qualified 아닌 Skill() 호출 발견:"
    echo "$bare_calls" | sed 's/^/        /'
    local count
    count=$(echo "$bare_calls" | wc -l | tr -d ' ')
    violations=$((violations + count))
  fi

  # phase 파일도 검증 (있으면)
  local phases_dir="$skill_dir/phases"
  if [ -d "$phases_dir" ]; then
    local phase_bare_calls
    # backtick 라인/들여쓰기 라인/fully-qualified 호출 제외
    phase_bare_calls=$(grep -nrE 'Skill\("[a-z][a-z0-9-]*"' "$phases_dir" 2>/dev/null \
      | grep -v '`Skill' \
      | grep -vE '^[^:]+:[0-9]+:[[:space:]]+Skill\(' \
      | grep -vE 'Skill\("(tddak|ttutak|codex|oh-my-claudecode|claude-hud):[a-z-]+"' \
      || true)
    if [ -n "$phase_bare_calls" ]; then
      echo "[FAIL ③/phases] $skill_name — phase 파일에 fully-qualified 아닌 Skill() 호출:"
      echo "$phase_bare_calls" | sed 's/^/        /'
      local pcount
      pcount=$(echo "$phase_bare_calls" | wc -l | tr -d ' ')
      violations=$((violations + pcount))
    fi
  fi

  if [ "$violations" -eq 0 ]; then
    echo "[OK]   $skill_name"
  fi

  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + violations))
}

echo "===== tddak skill-load-guard ====="
echo "검증 디렉토리: $SKILLS_DIR"
echo "Strict 모드: $([ "$STRICT_MODE" = "1" ] && echo "ON" || echo "OFF")"
echo ""

if [ -n "$TARGET_SKILL" ]; then
  # 특정 스킬만 검증
  if [ -d "$SKILLS_DIR/$TARGET_SKILL" ]; then
    check_skill "$SKILLS_DIR/$TARGET_SKILL"
  else
    echo "[ERROR] 스킬 디렉토리 없음: $SKILLS_DIR/$TARGET_SKILL"
    exit 1
  fi
else
  # 전체 스킬 검증
  for skill_dir in "$SKILLS_DIR"/*/; do
    check_skill "$skill_dir"
  done
fi

echo ""
echo "===== 검증 요약 ====="
echo "검증 스킬: $TOTAL_CHECKED"
echo "위반 항목: $TOTAL_VIOLATIONS"

if [ "$TOTAL_VIOLATIONS" -gt 0 ] && [ "$STRICT_MODE" = "1" ]; then
  echo ""
  echo "[FAIL] strict 모드에서 위반 발견. exit 1."
  exit 1
fi

exit 0
