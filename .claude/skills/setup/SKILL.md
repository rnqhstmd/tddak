---
name: setup
version: 1.0.0
description: "[tddak/TDD 강제] tddak 플러그인 초기 설정. 필수 도구 확인, GH 인증, Slack 연동. ttutak:setup과 별개로 실행하며, ttutak이 이미 설정되어 있다면 그 설정을 재사용한다."
argument-hint: "없음"
allowed-tools:
  - "Bash(curl *)"
  - "Bash(gh *)"
  - "Bash(git *)"
  - "Bash(which *)"
  - "Bash(command *)"
  - "Bash(uname *)"
  - "Bash(java *)"
  - "Bash(test *)"
  - "Bash(mkdir *)"
  - "Bash(cp *)"
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# tddak:setup

> **플러그인**: tddak (TDD 강제 파이프라인)
> **이 스킬**: setup — 초기 설정
> **혼동 주의**: ttutak:setup과 다른 스킬. tddak 전용 설정을 추가한다.
> **호출 시 주의**: 이 스킬 내에서 다른 스킬을 호출할 때 반드시 `tddak:` 접두사를 사용한다.

tddak 플러그인 초기 설정을 단계별로 수행한다.

---

## 실행 절차

아래 단계를 **순서대로** 실행한다. 각 단계 완료 시 `{항목} : 완료 ✅` 형식으로 출력한다.

### 1단계: 필수 도구 확인

#### gh

1. `which gh` 실행
2. 있으면 → `gh : 완료 ✅` 출력
3. 없으면 → 설치 링크 안내 (https://cli.github.com)

#### JDK (선택)

1. `uname -s`로 OS 감지
2. `java -version`으로 JDK 확인
3. JDK 8 이상이면 → `JDK : 완료 ✅ (버전)` 출력
4. 없거나 버전 낮으면 OS별 설치 안내:
   - **Linux**: `sudo apt install openjdk-17-jdk`
   - **macOS**: `brew install openjdk@17`
   - **Windows**: https://adoptium.net 안내

### 2단계: 설정 파일 초기화

#### 2-1. ttutak 설정 재사용 시도

1. `test -f .claude/config.json` 으로 ttutak 설정 존재 확인
2. **존재 시**: `ttutak 설정 재사용 : 완료 ✅ (기존 .claude/config.json 사용)` 출력
3. **부재 시**:
   - `mkdir -p .claude`
   - 플러그인 번들 템플릿 복사: `cp "${CLAUDE_PLUGIN_ROOT}/.claude/config.json" .claude/config.json`
   - 복사 실패 시: 수동 생성 안내 후 계속 진행
   - 성공 시: `config.json : 생성 완료 ✅` 출력

#### 2-2. tddak 전용 추가 설정 (선택)

`test -f .claude/tddak-config.json`으로 tddak 전용 설정 확인.
부재 시 기본 템플릿 생성:

```json
{
  "tdd": {
    "ironLaw": true,
    "verifyGate": true,
    "givenWhenThen": true,
    "testabilityScore": true
  },
  "routing": {
    "explicitTriggersOnly": true
  }
}
```

### 3단계: GH 인증

1. `gh auth status`로 인증 상태 확인
2. 인증됨 → `GH 인증 : 완료 ✅` 출력
3. 미인증 → device flow 인증 진행 (ttutak setup과 동일):

```bash
gh auth login --hostname github.com --git-protocol https --web 2>&1
```

타임아웃 120000ms (2분). 사용자에게 안내 메시지 표시 후 AskUserQuestion으로 완료 대기.

### 4단계: context/ 안내

`test -d context`로 확인:
- 부재 → "도메인 지식을 관리하려면 `/tddak:context`로 context/ 디렉토리를 생성하세요." 안내
- 존재 → 건너뜀

### 5단계: 충돌 점검

ttutak 동시 설치 여부 확인:
1. plugin manager에서 ttutak 활성화 상태 추정 (사용자에게 질문)
2. 동시 설치 시 안내:
   ```
   ttutak도 함께 설치되어 있는 것 같습니다.

   충돌 회피를 위해:
   1. 슬래시 커맨드 사용 권장: /tddak:dev (TDD), /ttutak:dev (일반)
   2. 자연어 사용 시 명시적 트리거: "TDD로 개발해줘"
   3. 자세한 라우팅: .claude/rules/tddak-routing.md 참조
   ```

### 완료: 퀵스타트

```
=== tddak 퀵스타트 ===
/tddak:dev <요청>      → TDD 파이프라인 (PRD → ship)
/tddak:red             → RED 단계 단독 호출
/tddak:green           → GREEN 단계 단독 호출
/tddak:refactor        → REFACTOR 단계 단독 호출
/tddak:verify          → 완료 전 검증 게이트

💡 도메인 지식이 필요하면:
/tddak:context <도메인>  → Given-When-Then 강제 컨텍스트
```

---

## 다른 스킬 호출 시 절대 규칙 (Iron Law)

✅ 올바름:
- `Skill("tddak:context")` — 도메인 컨텍스트 생성

❌ 금지:
- `Skill("context")` — ttutak:context가 호출될 수 있음

**위반 시**: 즉시 중단하고 fully-qualified 이름으로 재호출한다.

---

## 주의사항

- 각 단계를 **하나씩** 실행하고, 실패하면 원인을 파악하여 사용자에게 안내한다.
- 이미 완료된 항목은 재실행하지 않고 `완료 ✅` 만 출력한다.
- ttutak 설정을 덮어쓰지 않는다. tddak 전용 추가만 한다.
