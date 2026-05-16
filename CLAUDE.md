# CLAUDE.md

## tddak — TDD 강제 개발 파이프라인 플러그인

ttutak의 파이프라인 구조에 TDD 방법론을 강제 적용한 플러그인입니다.
PRD → 설계 → **RED → GREEN → REFACTOR** → 리뷰 → **verify 게이트** → 커밋 → PR.

한국어로 응답하세요. 코드와 커밋 메시지도 한국어를 기본으로 합니다.

---

## ttutak과의 관계

- **ttutak**: 일반 개발 파이프라인 (TDD 강제 없음)
- **tddak**: TDD를 1급 시민으로 강제하는 파이프라인

두 플러그인이 동시 설치된 경우, **3중 식별 메커니즘**으로 충돌을 회피합니다:
1. description 필드의 `[tddak/TDD 강제]` 접두사
2. SKILL.md 본문 첫 줄의 `tddak:{skill}` 정체성 블록
3. 하위 스킬 호출 시 `Skill("tddak:commit")` fully-qualified 강제

---

## 시작하기

1. 프로젝트 루트에서 `plugin add` 후 사용
2. `/tddak:setup` 실행하여 초기 설정
3. `/tddak:dev` 로 TDD 파이프라인 시작
4. 프로젝트의 CLAUDE.md에 아키텍처/패턴/컨벤션을 정의하세요

## 핵심 차별점 (vs ttutak)

| 단계 | ttutak | tddak |
|------|--------|-------|
| 요구사항 | 자연어 AC | **Given-When-Then 강제** |
| 설계 | 비판 검토 | **testability 평가 필수** |
| 구현 | coder가 직접 구현 | **RED → GREEN → REFACTOR 격리 에이전트** |
| 리뷰 | qa/security 병렬 | **spec → quality 순차 강제 (Iron Law)** |
| 완료 | qa 통과 | **verify 게이트 (실행 증거 필수)** |

## Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
NO PHASE SKIPPING WITHOUT --hotfix
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

위반 시 즉시 중단하고 RED 단계부터 재시작합니다.

## 자연어 라우팅 (ttutak과 공존 시)

tddak은 **명시적 트리거**가 있을 때만 동작합니다:

| 사용자 표현 | 호출 스킬 |
|-----------|----------|
| "TDD로 개발", "tddak으로 개발", "테스트 먼저" | `/tddak:dev` |
| "TDD로 커밋", "verify 후 커밋" | `/tddak:commit` |
| "개발해줘" (일반) | `/ttutak:dev` (tddak 동작 안 함) |

자세한 라우팅은 `.claude/rules/tddak-routing.md` 참조.

## 작업 범위

- **PR 생성까지만.** PR 머지(`gh pr merge` 등)는 절대 실행하지 마세요.
- 사용자가 직접 머지를 요청하더라도 거절하고, PR 링크를 제공하여 직접 머지하도록 안내하세요.
