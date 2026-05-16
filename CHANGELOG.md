# Changelog

모든 주요 변경 사항은 이 파일에 기록됩니다.

형식: [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/) 준수.
버전 규칙: [Semantic Versioning](https://semver.org/lang/ko/).

---

## v1.0.0 — 2026-05-16

### 첫 정식 릴리즈

ttutak의 한국어 개발 파이프라인 + superpowers의 TDD 방법론을 결합한 신규 플러그인.

### Added

#### 핵심 파이프라인 (13개 스킬)
- `using-tddak` — 부트스트랩 (세션 시작 시 자동 로드, Iron Law + 3중 식별 안내)
- `setup` — 초기 설정 (ttutak config 재사용 + tddak 전용 추가)
- `dev` — TDD 파이프라인 오케스트레이터 (PRD → 설계 → RGR → 리뷰 → verify → PR)
- `red` — RED 단계 (실패 테스트 우선 작성, Iron Law 1)
- `green` — GREEN 단계 (통과 최소 코드, YAGNI 강제)
- `refactor` — REFACTOR 단계 (안전한 정리, 동작 변경 금지)
- `verify` — 완료 검증 게이트 (실행 증거 필수, Iron Law 3)
- `commit` — verify 통과 후 한국어 커밋
- `pull-request` — 테스트 결과 첨부 PR 생성
- `context` — Given-When-Then 강제 도메인 컨텍스트
- `lens` — 비즈니스 정책 + 테스트 영향도 분석
- `tech-debt` — 부채 분석 (테스트 부채 가중치 상향)
- `research` — 외부 도메인 리서치

#### 에이전트 (16종)
- ttutak에서 차용 (9종): product-owner, architect, design-critic, qa-manager (deprecated), coder (deprecated), security-auditor, researcher, hacker, simplifier
- 신규 (7종):
  - red-writer (sonnet) — RED 단계 전담
  - green-coder (sonnet) — GREEN 단계 전담
  - refactor-coder (sonnet) — REFACTOR 단계 전담
  - spec-reviewer (sonnet) — AC 충족 검증만
  - quality-reviewer (opus) — 코드 품질 검증만
  - test-architect (opus) — testability 평가
  - verifier (haiku) — verify 게이트

#### 식별 메커니즘 (ttutak 공존)
- 3중 식별: description 마커, 본문 헤더, fully-qualified Skill 호출
- 자연어 라우팅 규칙 (.claude/rules/tddak-routing.md)
- 충돌 시나리오 30개 테스트 가이드 (.claude/rules/conflict-test-scenarios.md)

#### Iron Law 카탈로그
- 23가지 합리화 격파 표 (한국어)
- Red Flags 자가 점검 패턴
- Iron Law 1/2/3 위반 감지 패턴

#### 자동화
- `.claude/hooks/pre-tool-guard.sh` — 보호 브랜치 직접 커밋 차단 (ttutak 차용)
- `.claude/hooks/skill-load-guard.sh` — 식별 마커 자동 검증 (신규)
- `.github/workflows/skill-load-guard.yml` — PR 자동 검증 (신규)

#### 문서
- README.md — 사용 가이드 + 차별점 표
- CLAUDE.md — 플러그인 메타 안내
- MIGRATION.md — ttutak → tddak 마이그레이션 가이드
- CHANGELOG.md — 본 파일

### 차별점 (vs ttutak)
- 요구사항: 자연어 AC → **Given-When-Then 강제 게이트**
- 설계: 비판 검토 → **testability score ≥ 7 게이트**
- 구현: coder 단일 호출 → **RED → GREEN → REFACTOR 격리 3 에이전트 순차**
- 리뷰: qa+security 병렬 → **spec → quality 순차 강제** + security 병렬
- 완료: qa 통과 → **verify 게이트 (실행 증거 필수)**

### 제외 (tddak 범위 밖)
- `humanizer` — ttutak에서 직접 사용
- `cross-review` — ttutak에서 직접 사용
- `test` — dev 파이프라인의 RED 단계에 통합

### 호환
- ttutak과 동시 설치 가능 (3중 식별로 충돌 회피)
- `.dev/`, `context/`, `references/`, `.claude/config.json` 디렉토리 공유
