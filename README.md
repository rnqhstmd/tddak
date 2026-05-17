<div align="center">

# tddak 띠닥

**"TDD로 개발해줘" 한마디면 PRD, 설계, RED→GREEN→REFACTOR, 리뷰, verify까지 띠닥.**

테스트 먼저, 실행 증거로 완료를 증명하는 Claude Code TDD 개발 자동화 플러그인

[![GitHub release](https://img.shields.io/github/v/release/rnqhstmd/tddak?style=for-the-badge)](https://github.com/rnqhstmd/tddak/releases)

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

자연어로 말하면 의도에 맞는 스킬이 발동됩니다. **TDD를 명시**해야 tddak이 동작합니다.

| 이렇게 말하면 | 발동 스킬 |
|--------------|----------|
| "TDD로 로그인 기능 개발해줘" | dev |
| "테스트 먼저 결제 모듈 구현해줘" | dev |
| "RED 단계, 실패 테스트 작성해줘" | red |
| "GREEN 단계, 통과 코드 작성" | green |
| "REFACTOR, 중복 제거해줘" | refactor |
| "verify 게이트 통과 확인해줘" | verify |
| "verify 후 커밋해줘" | commit |
| "tddak으로 PR 올려줘" | pull-request |
| "Given-When-Then으로 컨텍스트 만들어줘" | context |
| "TDD 관점으로 부채 분석해줘" | tech-debt |

### 개발 흐름

`context` → `dev` 두 단계로 개발합니다. `dev`만 단독으로 써도 됩니다.

1. `requirements/` 폴더에 기획서(PDF, 이미지, 텍스트)를 넣습니다
2. `references/` 폴더에 준수해야 할 외부 규격 문서를 넣어두면 설계·구현·리뷰 시 자동으로 참조합니다
3. "Given-When-Then으로 컨텍스트 만들어줘"로 도메인 지식을 등록합니다 (AC가 시나리오로 강제됩니다)
4. "TDD로 개발해줘"로 PRD → 설계 → **RED → GREEN → REFACTOR** → 리뷰 → **verify 게이트** → 커밋 → PR까지 실행합니다

각 단계 사이에 사용자 승인이 필요합니다. 승인 없이 다음으로 넘어가지 않습니다.

### 외부 규격 참조

프로젝트가 준수해야 할 외부 규격이 있다면 `references/` 디렉토리에 문서를 넣어둡니다:

```
references/
├── 시큐어코딩-가이드.md
├── API-설계-표준.md
└── 테스트-작성-컨벤션.md
```

`/tddak:dev` 실행 시 설계·구현·리뷰 에이전트가 자동으로 참조합니다. 없어도 동작하지만, 등록하면 규격 준수를 자동 검증합니다.

---

## 스킬 상세

### context

기획서, 요구사항 문서, 코드베이스를 분석하여 도메인 지식을 `context/{도메인}/`에 등록합니다. **인수 기준(AC)을 Given-When-Then 시나리오로 강제**합니다.

```
"requirements 폴더에 있는 기획서 보고 context 만들어줘"   ← 문서 기반 생성
"결제 도메인 등록해줘"                                  ← Q&A 기반 생성
"코드베이스 분석해서 context 자동 생성해줘"               ← 코드 스캔
"결제 도메인 동기화해줘"                               ← git 히스토리 기반 진행도 갱신
```

### lens

코드에서 비즈니스 정책을 찾아 PO/PD가 읽을 수 있는 보고서로 출력합니다. 코드를 수정하지 않습니다. 변경 아이디어를 이어서 입력하면 복잡도·리스크 분석과 **테스트 영향도**까지 수행합니다.

```
"현재 결제 정책이 어떻게 되어 있는지 정리해줘"
"결제 한도를 50만원으로 늘리면 어디에 영향이 가?"
```

### dev

자연어 요청 하나로 PRD 작성부터 PR 생성까지 **RED → GREEN → REFACTOR** TDD 사이클을 수행합니다.

```
"TDD로 사용량 분석 대시보드 개발해줘"    ← 전체 사이클
"테스트 먼저 결제 모듈 구현해줘"         ← 동일
"긴급 수정해줘 --hotfix"              ← hotfix 모드 (RED→GREEN 유지, 일부 단계 생략)
"PRD만 작성해줘"                     ← 특정 단계만
"이어서 해줘"                        ← 중단 지점부터 재개
```

내부적으로 에이전트 팀이 단계를 나눠 처리합니다:

| 에이전트 | 역할 | 단계 |
|---------|------|------|
| 제품책임자(PO) | 요구사항 구체화, PRD 작성, AC를 Given-When-Then으로 강제 | requirements |
| 설계자 | 기술 설계 (변경 범위, API, 구현 순서) | design |
| test-architect | testability score ≥ 7 게이트 검증 | design |
| red-writer | 실패 테스트만 작성 (구현 절대 금지) | RED |
| green-coder | 테스트 통과 최소 코드만 (YAGNI 강제) | GREEN |
| refactor-coder | 동작 보존 + 중복 제거 (테스트 깨지면 롤백) | REFACTOR |
| spec-reviewer | AC 충족 검증만 (먼저) | review |
| quality-reviewer | 코드 품질 검증만 (다음) | review |
| security-auditor | 보안 정책 교차 검증 (병렬) | review |
| verifier | 실행 증거 수집 → 완료 게이트 | verify |

### research

웹 검색과 문서 분석을 병행하여 도메인 리서치를 수행합니다. 결과물은 `/context --from`으로 context 문서에 반영할 수 있습니다.

```
"클라우드 네이티브 트렌드 조사해줘"
"결제 시스템 비교 분석해줘 --format comparison"
"인증 방식 핵심만 정리해줘 --format summary"
```

조사 결과는 `.research/` 디렉토리에 저장되며, 모든 발견에 출처 URL이 명시됩니다.

### tech-debt

코드베이스의 기술 부채를 유형별로 분석하고 우선순위 로드맵을 제공합니다. **테스트 부채(커버리지, assertion 누락 등) 가중치가 상향**됩니다. 코드를 수정하지 않는 읽기 전용 스킬입니다.

```
"기술 부채 분석해줘"                    ← 프로젝트 전체 분석
"결제 도메인 부채 분석해줘"              ← 특정 도메인만
"테스트 부채만 확인해줘 --type test"    ← 유형 선택 (code, arch, deps, test)
"아키텍처 부채 점검해줘 --type arch"
```

분석 유형:
- **코드 부채**: 중복 코드, 복잡도(God 클래스), dead code, 네이밍 불일치
- **아키텍처 부채**: 순환 의존성, 레이어 위반, 책임 분리 위반
- **의존성 부채**: EOL 프레임워크, 보안 취약점, 미고정 버전
- **테스트 부채**: 커버리지 부족, 핵심 로직 미검증, assertion 없는 테스트 ← 가중치 상향

결과는 Health Score(A~F 등급)와 우선순위 로드맵으로 제공됩니다.

### commit / pull-request

```
"verify 후 커밋해줘"   ← verify 게이트 통과 필수, 미통과 시 차단. 브랜치명에서 타입 파싱, 한국어 커밋 메시지 생성
"tddak으로 PR 올려줘"  ← 커밋 히스토리 분석, PR 본문에 verify 실행 결과 자동 첨부
```

---

## 안전장치

- PR 생성까지만 자동화합니다. **PR 머지는 사용자가 직접** 수행합니다.
- `git push --force`, `gh pr merge`는 설정 수준에서 차단됩니다.
- 보호 브랜치(main)에서 직접 커밋을 차단합니다.
- 커밋 전 민감 파일(`.env`, `*.key`, `*.pem`, `credentials*`, `*secret*`) 감지 시 경고합니다.
- **verify 게이트 미통과 시 commit / PR 진입을 차단**합니다.
- Iron Law 위반 패턴 감지 시 즉시 중단하고 합리화 격파 표를 인용합니다.

---

## FAQ

<details>
<summary><b>context 없이도 dev를 실행할 수 있나요?</b></summary>

네. 없어도 동작합니다. 다만 context를 등록하면 AI가 도메인 용어를 정확히 이해하여 더 정확한 테스트와 코드를 생성합니다.
</details>

<details>
<summary><b>RED 단계에서 테스트만 작성한다고요? 실제로 강제되나요?</b></summary>

네. `red-writer` 에이전트는 프로덕션 코드 작성이 차단됩니다. RED 단계 종료 시 테스트가 **실제로 실패**하는지 실행 증거로 확인합니다. 통과하는 테스트는 RED로 인정되지 않습니다.
</details>

<details>
<summary><b>dev 도중에 멈추면 처음부터 다시 해야 하나요?</b></summary>

아닙니다. "이어서 해줘"라고 말하면 `.dev/{branch-slug}/state.md`에 저장된 진행 상태를 기반으로 중단된 단계부터 재개합니다.
</details>

<details>
<summary><b>PR이 자동으로 머지되나요?</b></summary>

아닙니다. PR 생성까지만 자동화합니다. `gh pr merge`는 설정 수준에서 차단되어 있습니다.
</details>

<details>
<summary><b>ttutak과 동시에 사용할 수 있나요?</b></summary>

네. 3중 식별 메커니즘으로 충돌을 회피합니다. TDD 키워드("TDD로", "테스트 먼저", "tddak으로")가 있으면 tddak이, 없으면 ttutak이 처리합니다. 자세한 라우팅: [.claude/rules/tddak-routing.md](.claude/rules/tddak-routing.md)
</details>

<details>
<summary><b>플러그인 업데이트는?</b></summary>

`/plugin marketplace update tddak`
</details>
