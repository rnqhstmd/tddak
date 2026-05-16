---
name: using-tddak
version: 1.0.0
description: "[tddak/TDD 강제] 세션 시작 시 자동 로드되는 부트스트랩 스킬. tddak 플러그인의 Iron Law와 3중 식별 메커니즘을 안내한다. ttutak과 동시 설치 시 충돌 회피의 기반."
allowed-tools:
  - Read
---

# tddak:using-tddak

> **플러그인**: tddak (TDD 강제 파이프라인)
> **이 스킬**: using-tddak — 부트스트랩 + 정체성 선언
> **혼동 주의**: ttutak에는 동일 스킬이 없음. tddak 전용.
> **호출 시 주의**: 이 스킬 내에서 다른 스킬을 호출할 때 반드시 `tddak:` 접두사를 사용한다.

세션 시작 시 자동으로 로드되어, tddak 플러그인의 Iron Law와 사용 규칙을 Claude에게 알린다.

---

## Iron Law 선언

tddak의 모든 스킬은 아래 세 가지 Iron Law를 따른다. **문자 위반 = 정신 위반.**

```
1. NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
   (실패 테스트 없이 프로덕션 코드 작성 금지)

2. NO PHASE SKIPPING WITHOUT --hotfix
   (--hotfix 모드 외에 Phase 건너뛰기 금지)

3. NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
   (신선한 검증 증거 없이 완료 주장 금지)
```

위반 시 즉시 중단하고 RED 단계 또는 verify 게이트부터 재시작한다.

---

## 3중 식별 메커니즘 (ttutak 충돌 회피)

tddak은 ttutak과 동일한 스킬 이름을 사용한다 (`dev`, `commit`, `pull-request`, `context`, `lens`, `tech-debt`, `research`). 충돌 회피를 위해 모든 호출에 다음을 적용한다:

### ① 스킬 선택 시: description 마커

모든 tddak 스킬의 description은 `[tddak/TDD 강제]` 접두사로 시작한다.
- 자연어 "TDD로 개발" → `[tddak/TDD 강제]` 마커가 있는 `tddak:dev` 매칭
- 자연어 "개발해줘" (일반) → ttutak으로 위임 (tddak 동작 안 함)

### ② 스킬 실행 진입 시: 본문 헤더

모든 tddak 스킬의 본문은 다음 형식으로 시작한다:
```
# tddak:{skill-name}
> **플러그인**: tddak ...
> **혼동 주의**: ttutak:{skill-name}와 다름 ...
```

### ③ 하위 스킬 호출 시: fully-qualified 강제

스킬 내에서 다른 스킬 호출 시 **반드시** `tddak:` 접두사를 포함한다:

```
✅ 올바름:
  Skill("tddak:commit")
  Skill("tddak:verify")
  Skill("tddak:pull-request")

❌ 금지:
  Skill("commit")        — ttutak:commit이 호출될 수 있음
  Skill("pull-request")  — 동일 위험
  Skill("context")       — 동일 위험
```

위반 시 즉시 중단하고 fully-qualified 이름으로 재호출한다.

---

## 자연어 라우팅 규칙 (Passive)

tddak은 **명시적 트리거**가 있을 때만 동작한다. 일반 자연어는 ttutak이 처리하도록 평화 공존한다.

### tddak 트리거 키워드

| 사용자 표현 | 호출 스킬 |
|------------|----------|
| `TDD로 개발`, `테스트 먼저`, `RED-GREEN`, `tddak으로 개발` | `/tddak:dev` |
| `TDD로 커밋`, `tddak으로 커밋`, `verify 후 커밋` | `/tddak:commit` |
| `tddak으로 PR`, `테스트 결과 첨부 PR` | `/tddak:pull-request` |
| `tddak으로 컨텍스트`, `Given-When-Then으로 AC` | `/tddak:context` |
| `tddak`, `tddak으로` (단독) | `/tddak:dev` (기본) |

### ttutak에 위임하는 표현

다음 자연어는 ttutak으로 라우팅 (tddak 동작 안 함):

| 사용자 표현 | 호출 스킬 |
|------------|----------|
| `개발해줘`, `구현해줘`, `만들어줘` (일반) | `/ttutak:dev` |
| `커밋해줘`, `commit` (일반) | `/ttutak:commit` |
| `PR 올려`, `pull request` (일반) | `/ttutak:pull-request` |

자세한 규칙은 `.claude/rules/tddak-routing.md` 참조.

---

## 스킬 발견 안내

tddak이 제공하는 스킬 (12개):

| 스킬 | 역할 |
|------|------|
| `using-tddak` | (현재 스킬) 부트스트랩 |
| `setup` | 초기 설정 |
| `dev` | TDD 파이프라인 (PRD → ship) |
| `red` | 실패 테스트 작성 강제 |
| `green` | 통과 최소 코드 |
| `refactor` | 안전한 정리 |
| `verify` | 완료 전 검증 게이트 |
| `commit` | verify 통과 후 커밋 |
| `pull-request` | 테스트 결과 첨부 PR |
| `context` | Given-When-Then 강제 컨텍스트 |
| `lens` | 비즈니스 정책 + 테스트 영향도 |
| `tech-debt` | 부채 분석 (테스트 부채 가중치 상향) |
| `research` | 외부 리서치 |

---

## 다음 단계 안내

세션 시작 시 사용자에게 다음과 같이 안내한다 (1회):

```
tddak 플러그인이 활성화되었습니다.

TDD 파이프라인 사용: /tddak:dev <요청>
일반 개발 (ttutak): /ttutak:dev <요청>
초기 설정 (최초 1회): /tddak:setup

ttutak과 동시 설치 시 명시적 슬래시 커맨드 사용을 권장합니다.
```

이후엔 안내하지 않는다 (반복 출력 금지).
