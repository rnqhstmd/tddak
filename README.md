<div align="center">

# tddak

**"TDD로 개발해줘" 한마디면 PRD부터 PR까지, RED → GREEN → REFACTOR 사이클 강제.**

테스트 먼저, 실행 증거로 검증하는 Claude Code TDD 개발 자동화 플러그인

[![GitHub release](https://img.shields.io/github/v/release/rnqhstmd/tddak?style=for-the-badge)](https://github.com/rnqhstmd/tddak/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

---

## 설치

```bash
# Claude Code CLI에서 실행
/plugin marketplace add rnqhstmd/tddak
/plugin install tddak@tddak
```

## 시작
```bash
/tddak:setup
```

---

## 사용법

자연어로 말하면 의도에 맞는 스킬이 발동됩니다. **TDD를 명시**해야 tddak이 동작합니다 (일반 자연어는 ttutak으로 위임).

| 이렇게 말하면 | 발동 스킬 |
|--------------|----------|
| "TDD로 로그인 기능 개발해줘" | `tddak:dev` |
| "테스트 먼저 작성하면서 결제 구현해줘" | `tddak:dev` |
| "RED 단계, 실패 테스트 먼저" | `tddak:red` |
| "GREEN 단계, 통과 코드 작성" | `tddak:green` |
| "REFACTOR, 중복 제거" | `tddak:refactor` |
| "verify 게이트 통과 확인해줘" | `tddak:verify` |
| "verify 후 커밋해줘" | `tddak:commit` |
| "tddak으로 PR 올려줘" | `tddak:pull-request` |
| "Given-When-Then으로 컨텍스트 만들어줘" | `tddak:context` |
| "TDD 관점으로 부채 분석해줘" | `tddak:tech-debt` |

### 개발 흐름

`context` → `dev` 두 단계로 개발합니다. `dev`만 단독으로 써도 됩니다.

1. `requirements/` 폴더에 기획서(PDF, 이미지, 텍스트)를 넣습니다
2. `references/` 폴더에 준수해야 할 외부 규격 문서를 넣어두면 설계·구현·리뷰 시 자동 참조합니다
3. "Given-When-Then으로 컨텍스트 만들어줘"로 도메인 지식을 등록합니다 (AC가 시나리오로 강제됩니다)
4. "TDD로 개발해줘"로 PRD → 설계 → **RED → GREEN → REFACTOR** → 리뷰 → **verify 게이트** → 커밋 → PR 까지 실행합니다

각 단계 사이에 사용자 승인이 필요합니다. 승인 없이 다음으로 넘어가지 않습니다.

---

## 핵심 차별점 (vs ttutak)

| 단계 | ttutak | tddak |
|------|--------|-------|
| 요구사항 | 자연어 AC | **Given-When-Then 강제 게이트** |
| 설계 | 비판 검토 | **testability score ≥ 7 필수** |
| 구현 | coder 단일 호출 | **RED → GREEN → REFACTOR 격리 3 에이전트 순차** |
| 리뷰 | qa + security 병렬 | **spec → quality 순차 강제** + security 병렬 |
| 완료 | qa 통과 | **verify 게이트 (실행 증거 필수)** |

---

## Iron Law

```
1. NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
   (실패 테스트 없이 프로덕션 코드 작성 금지)

2. NO PHASE SKIPPING WITHOUT --hotfix
   (--hotfix 모드 외에 Phase 건너뛰기 금지)

3. NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
   (신선한 검증 증거 없이 완료 주장 금지)
```

위반 시 즉시 중단하고 RED 단계부터 재시작합니다. **예외 없음.** "이번 한 번만"은 첫 예외가 규칙이 됩니다.

23가지 합리화 격파 표: [.claude/rules/tdd-iron-law.md](.claude/rules/tdd-iron-law.md)

---

## 스킬 상세

### dev — TDD 파이프라인 오케스트레이터

자연어 요청 하나로 PRD부터 PR까지 **RED → GREEN → REFACTOR** 사이클을 강제 수행합니다.

```
"TDD로 사용량 분석 대시보드 개발해줘"   ← 전체 사이클
"테스트 먼저 결제 모듈 구현해줘"        ← 동일
"이어서 해줘"                          ← 중단 지점부터 재개
"--hotfix 긴급 수정"                  ← Phase 일부 생략 (Iron Law 2 예외)
```

내부 에이전트 분담:

| 에이전트 | 역할 | 단계 |
|---------|------|------|
| product-owner | 요구사항 구체화, PRD 작성, AC를 Given-When-Then으로 강제 | requirements |
| architect | 기술 설계 + testability score 평가 | design |
| test-architect | testability score ≥ 7 게이트 검증 | design |
| red-writer | 실패 테스트만 작성 (구현 금지) | RED |
| green-coder | 테스트 통과 최소 코드만 작성 (YAGNI 강제) | GREEN |
| refactor-coder | 동작 보존 + 중복 제거 (테스트 깨지면 롤백) | REFACTOR |
| spec-reviewer | AC 충족 검증만 | review (선) |
| quality-reviewer | 코드 품질 검증만 | review (후) |
| security-auditor | 보안 정책 교차 검증 | review (병렬) |
| verifier | 실행 증거 수집 → 완료 게이트 | verify |

### red / green / refactor — 단계별 단독 호출

전체 dev 사이클 없이 단계만 분리해 호출할 수 있습니다.

```
"RED 단계, 실패 테스트 작성해줘"   ← 테스트만, 구현 금지
"GREEN 단계, 통과시켜줘"          ← 최소 구현
"REFACTOR, 정리해줘"             ← 안전한 정리
```

### verify — 완료 검증 게이트

테스트 명령을 직접 실행해 0 failures 증거를 수집합니다. "should work" 같은 추측 표현은 차단됩니다. commit / PR 진입 전 자동 호출되며 수동으로도 호출 가능합니다.

```
"verify 게이트 통과 확인해줘"
"완료 검증해줘"
```

### context — Given-When-Then 강제 컨텍스트

`ttutak:context`와 동일한 도메인 컨텍스트 관리이지만, 인수 기준(AC)을 **Given-When-Then 시나리오로 강제**합니다.

```
"Given-When-Then으로 결제 도메인 컨텍스트 만들어줘"
"시나리오로 PRD 보강해줘"
```

### lens / tech-debt / research

ttutak 대응 스킬과 기능은 동일하되 TDD 관점이 가중됩니다.

- `lens`: 정책 변경 시 **테스트 영향도** 추가 분석
- `tech-debt`: 테스트 부채(커버리지, assertion 누락 등) 가중치 상향
- `research`: 외부 도메인 리서치 (ttutak과 동일)

### commit / pull-request

```
"verify 후 커밋해줘"   ← verify 게이트 통과 필수, 미통과 시 차단
"tddak으로 PR 올려줘"  ← PR 본문에 verify 실행 결과 자동 첨부
```

---

## ttutak과 동시 사용

두 플러그인이 모두 설치된 경우 자연어 트리거는 **명시적 키워드 기반**으로 분기됩니다. tddak은 **Passive 라우팅**으로 동작하므로, TDD 키워드가 없으면 ttutak이 처리합니다.

| 자연어 | 호출 플러그인 |
|--------|--------------|
| "TDD로 개발", "테스트 먼저", "RED-GREEN-REFACTOR" | **tddak** |
| "tddak으로 …", "verify 후 …" | **tddak** |
| "개발해줘", "구현해줘", "커밋해줘" (일반) | **ttutak** |
| "테스트 추가" (모호) | 사용자에게 확인 |

모호함을 피하려면 **슬래시 커맨드 사용 권장**:

```
일반 개발: /ttutak:dev 로그인 기능 추가
TDD 개발:  /tddak:dev  로그인 기능 추가
```

내부적으로 **3중 식별 메커니즘**으로 충돌을 회피합니다:

1. `description` 필드의 `[tddak/TDD 강제]` 접두사
2. SKILL.md 본문 첫 줄의 `tddak:{skill}` 정체성 블록
3. 하위 스킬 호출 시 `Skill("tddak:commit")` fully-qualified 강제

자세한 라우팅 규칙: [.claude/rules/tddak-routing.md](.claude/rules/tddak-routing.md)
정체성 규칙: [.claude/rules/identity.md](.claude/rules/identity.md)

---

## 안전장치

- **PR 생성까지만** 자동화합니다. PR 머지(`gh pr merge`)는 절대 수행하지 않습니다.
- 보호 브랜치(main 등)에서 직접 커밋을 차단합니다 (`pre-tool-guard.sh`).
- 커밋 전 민감 파일(`.env`, `*.key`, `*.pem`, `credentials*`, `*secret*`) 감지 시 경고합니다.
- verify 게이트 미통과 시 commit / PR 진입을 차단합니다.
- Iron Law 위반 패턴 감지 시 즉시 중단하고 합리화 격파 표를 인용합니다.

---

## 디렉토리 구조

```
tddak/
├── .claude-plugin/            # plugin.json, marketplace.json
├── .claude/
│   ├── config.json            # 프로젝트 타입/컨벤션/타임아웃
│   ├── hooks/                 # pre-tool-guard.sh, skill-load-guard.sh
│   ├── rules/                 # identity, tddak-routing, tdd-iron-law
│   └── skills/                # 13개 스킬
├── agents/                    # 16종 에이전트
├── CLAUDE.md
├── CHANGELOG.md
├── MIGRATION.md               # ttutak → tddak 마이그레이션
└── README.md
```

사용자 프로젝트 루트에는 다음이 생성/사용됩니다 (ttutak과 공유):

```
프로젝트 루트/
├── .dev/{branch-slug}/        # dev 파이프라인 산출물
├── context/                   # 도메인 지식
├── references/                # 외부 표준
└── .claude/config.json        # tddak/ttutak 공통
```

`.dev/`는 `.gitignore`에 자동 추가됩니다.

---

## FAQ

<details>
<summary><b>ttutak이 이미 있는데 tddak도 설치해야 하나요?</b></summary>

선택 사항입니다. TDD 강제가 필요한 프로젝트에만 tddak을 추가하면 됩니다. 두 플러그인은 충돌 없이 공존하며 `context/`, `references/`, `.claude/config.json` 디렉토리를 공유합니다.
</details>

<details>
<summary><b>RED 단계에서 테스트만 작성한다고요? 실제로 강제되나요?</b></summary>

네. `red-writer` 에이전트는 프로덕션 코드 작성이 차단되며, RED 단계 종료 시 "테스트가 실패하는가"를 실행 증거로 확인합니다. 통과하는 테스트는 RED로 인정되지 않습니다.
</details>

<details>
<summary><b>verify 게이트는 무엇을 검증하나요?</b></summary>

테스트 명령을 **직접 실행**하여 0 failures 증거를 수집합니다. 코드만 읽고 "통과할 것 같다"고 추측하는 것은 차단됩니다. commit / PR 진입 전 필수입니다.
</details>

<details>
<summary><b>긴급 수정인데 RED-GREEN-REFACTOR가 부담스럽습니다.</b></summary>

`--hotfix` 모드를 사용하세요. 설계/리뷰 단계는 생략되지만, **실패 테스트 → 통과 코드** 순서는 유지됩니다. Iron Law 1은 절대 우회되지 않습니다.
</details>

<details>
<summary><b>플러그인 업데이트는?</b></summary>

`/plugin marketplace update tddak`
</details>

---

## 작업 범위

**PR 생성까지만.** PR 머지(`gh pr merge` 등)는 절대 실행하지 않습니다. 머지는 리뷰어가 직접 수행하세요.

## 참고 자료

- ttutak (기반 플러그인): https://github.com/rnqhstmd/ttutak
- superpowers (TDD 영감): https://github.com/obra/superpowers
- 마이그레이션 가이드: [MIGRATION.md](MIGRATION.md)
- 변경 이력: [CHANGELOG.md](CHANGELOG.md)

## 라이선스

MIT (ttutak과 동일)
