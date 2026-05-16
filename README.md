# tddak

> **TDD 강제 개발 파이프라인 플러그인.** ttutak의 파이프라인 구조 + superpowers의 TDD 방법론을 결합한 Claude Code 플러그인.

PRD → 설계 → **RED → GREEN → REFACTOR** → 리뷰 → **verify 게이트** → 커밋 → PR.

한국어 기본. Iron Law 강제. ttutak과 공존 가능.

---

## Quick Start

```bash
# 1. 플러그인 설치 (Claude Code marketplace 또는 로컬)
/plugin install tddak

# 2. 초기 설정 (최초 1회)
/tddak:setup

# 3. TDD 파이프라인 시작
/tddak:dev 로그인 기능 추가
```

## 핵심 차별점 (vs ttutak)

| 단계 | ttutak | tddak |
|------|--------|-------|
| 요구사항 | 자연어 AC | **Given-When-Then 강제** |
| 설계 | 비판 검토 | **testability score ≥ 7 필수** |
| 구현 | coder 단일 호출 | **RED → GREEN → REFACTOR (격리 3에이전트)** |
| 리뷰 | qa+security 병렬 | **spec → quality 순차 강제** + security 병렬 |
| 완료 | qa 통과 | **verify 게이트 (실행 증거 필수)** |

## Iron Law

```
1. NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
2. NO PHASE SKIPPING WITHOUT --hotfix
3. NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

위반 시 즉시 중단하고 사이클 처음부터 재시작.

## 스킬 목록 (13개)

| 스킬 | 역할 |
|------|------|
| `using-tddak` | 부트스트랩 (세션 시작 시 자동 로드) |
| `setup` | 초기 설정 |
| `dev` | TDD 파이프라인 (PRD → ship) |
| `red` | RED 단계 — 실패 테스트 작성 강제 |
| `green` | GREEN 단계 — 통과 최소 코드 |
| `refactor` | REFACTOR 단계 — 안전한 정리 |
| `verify` | 완료 검증 게이트 |
| `commit` | verify 통과 후 한국어 커밋 |
| `pull-request` | 테스트 결과 첨부 PR 생성 |
| `context` | Given-When-Then 강제 도메인 컨텍스트 |
| `lens` | 비즈니스 정책 + 테스트 영향도 분석 |
| `tech-debt` | 부채 분석 (테스트 부채 가중치 상향) |
| `research` | 외부 도메인 리서치 |

## ttutak과 동시 사용

ttutak과 tddak이 모두 설치된 경우, 자연어 트리거는 **명시적 키워드 기반**으로 분기됩니다.

| 자연어 | 호출 |
|--------|------|
| "TDD로 개발", "테스트 먼저" | `/tddak:dev` |
| "개발해줘", "구현해줘" (일반) | `/ttutak:dev` |
| "tddak으로 커밋", "verify 후 커밋" | `/tddak:commit` |
| "커밋해줘" (일반) | `/ttutak:commit` |

모호함을 피하려면 **슬래시 커맨드 사용 권장**: `/tddak:dev 로그인 추가`.

자세한 라우팅: [.claude/rules/tddak-routing.md](.claude/rules/tddak-routing.md)

## 디렉토리 구조

```
tddak/
├── .claude-plugin/        # plugin.json, marketplace.json
├── .claude/
│   ├── config.json        # 프로젝트 타입/컨벤션/타임아웃
│   ├── hooks/             # pre-tool-guard.sh, skill-load-guard.sh
│   ├── rules/             # identity, tddak-routing, tdd-iron-law, conflict-test-scenarios
│   └── skills/            # 13개 스킬
├── agents/                # 16종 에이전트 (ttutak 9 + 신규 7)
├── CLAUDE.md
├── CHANGELOG.md
├── MIGRATION.md           # ttutak → tddak 마이그레이션 가이드
└── README.md
```

## 사용자 프로젝트에 미치는 영향

tddak 설치 후 프로젝트 루트에 다음 디렉토리가 생성/사용됩니다:

```
프로젝트 루트/
├── .dev/{branch-slug}/    # dev 파이프라인 산출물 (prd, design, trust-ledger, ...)
├── context/               # 도메인 지식 (ttutak과 공유)
├── references/            # 외부 표준 (ttutak과 공유)
└── .claude/
    └── config.json        # tddak/ttutak 공통
```

`.dev/`는 `.gitignore`에 자동 추가됩니다.

## 작업 범위

**PR 생성까지만**. PR 머지(`gh pr merge` 등)는 절대 실행하지 않습니다. 머지는 리뷰어가 직접 수행하세요.

## 개발 / 기여

신규 스킬 추가 시 **3중 식별 메커니즘** 준수가 강제됩니다. 검증:

```bash
bash .claude/hooks/skill-load-guard.sh --strict
```

자세한 규칙: [.claude/rules/identity.md](.claude/rules/identity.md), [.claude/rules/tdd-iron-law.md](.claude/rules/tdd-iron-law.md)

## 라이선스

MIT (ttutak과 동일)

## 참고 자료

- ttutak (기반 플러그인): https://github.com/rnqhstmd/ttutak
- superpowers (TDD 영감): https://github.com/obra/superpowers
- 마이그레이션 가이드: [MIGRATION.md](MIGRATION.md)
- 변경 이력: [CHANGELOG.md](CHANGELOG.md)
