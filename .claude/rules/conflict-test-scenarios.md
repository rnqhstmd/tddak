# tddak ↔ ttutak 충돌 시나리오 테스트 가이드

> 작성일: 2026-05-16
> 목적: tddak과 ttutak이 동시 설치된 환경에서 자연어 라우팅이 올바르게 동작하는지 검증
> 합격선: 30개 시나리오 중 **28건 이상 (93.3%)** 정확한 플러그인 호출

---

## 테스트 환경 셋업

### 전제 조건

1. ttutak 플러그인 설치 (`/Users/bonseung/projects/ttutak`)
2. tddak 플러그인 설치 (`/Users/bonseung/projects/tddak`)
3. 둘 다 활성화된 상태 (Claude Code `plugin list`로 확인)
4. 테스트 프로젝트 1개 (clean git repo)

### 검증 방법

각 시나리오마다:
1. 새 Claude Code 세션 시작 (이전 컨텍스트 격리)
2. 시나리오 입력
3. Claude의 첫 응답에서 **호출된 스킬 확인** (Skill 도구 호출 또는 슬래시 커맨드 실행)
4. 기대값과 일치하면 ✅, 다르면 ❌

### 기록 양식

```
시나리오 #{N}: {입력}
기대: {ttutak:X | tddak:X | 사용자 확인}
실제: {호출된 스킬}
결과: ✅ / ❌
비고: {오작동 원인 분석}
```

---

## 시나리오 카테고리

### A. tddak 명시적 트리거 (10건) — 모두 tddak으로 라우팅 기대

| # | 입력 | 기대 |
|---|------|------|
| 1 | TDD로 로그인 기능 개발해줘 | `tddak:dev` |
| 2 | 테스트 먼저 작성하면서 결제 모듈 구현해줘 | `tddak:dev` |
| 3 | RED-GREEN-REFACTOR로 회원가입 만들어줘 | `tddak:dev` |
| 4 | tddak으로 개발해줘: 비밀번호 재설정 | `tddak:dev` |
| 5 | verify 후 커밋해줘 | `tddak:commit` |
| 6 | TDD로 커밋해줘 | `tddak:commit` |
| 7 | tddak으로 PR 올려줘 | `tddak:pull-request` |
| 8 | Given-When-Then으로 결제 도메인 컨텍스트 만들어줘 | `tddak:context` |
| 9 | tddak 사용해서 정책 영향도 분석해줘 | `tddak:lens` |
| 10 | TDD 관점으로 코드 부채 분석해줘 | `tddak:tech-debt` |

### B. ttutak 위임 (10건) — 모두 ttutak으로 라우팅 기대

| # | 입력 | 기대 |
|---|------|------|
| 11 | 로그인 기능 개발해줘 | `ttutak:dev` |
| 12 | 결제 모듈 구현해줘 | `ttutak:dev` |
| 13 | 회원가입 만들어줘 | `ttutak:dev` |
| 14 | 비밀번호 재설정 기능 추가해줘 | `ttutak:dev` |
| 15 | 커밋해줘 | `ttutak:commit` |
| 16 | commit 해줘 | `ttutak:commit` |
| 17 | PR 올려줘 | `ttutak:pull-request` |
| 18 | 풀리퀘 만들어줘 | `ttutak:pull-request` |
| 19 | 결제 도메인 컨텍스트 등록 | `ttutak:context` |
| 20 | 정책 영향도 분석해줘 | `ttutak:lens` |

### C. 모호한 표현 (5건) — 사용자 확인 기대

| # | 입력 | 기대 |
|---|------|------|
| 21 | 테스트 추가해줘 | 사용자 확인 ("ttutak:test vs tddak:red?") |
| 22 | 테스트 작성 | 사용자 확인 |
| 23 | 테스트 커버리지 올려줘 | 사용자 확인 ("ttutak:test vs tddak:dev?") |
| 24 | 코드 리뷰 | 사용자 확인 ("ttutak qa vs tddak spec/quality?") |
| 25 | 검증해줘 | 사용자 확인 ("일반 vs tddak:verify?") |

### D. 슬래시 커맨드 (5건) — 명시적이므로 100% 정확 기대

| # | 입력 | 기대 |
|---|------|------|
| 26 | /tddak:dev 결제 한도 추가 | `tddak:dev` |
| 27 | /ttutak:dev 결제 한도 추가 | `ttutak:dev` |
| 28 | /tddak:verify | `tddak:verify` |
| 29 | /tddak:red 비밀번호 검증 | `tddak:red` |
| 30 | /ttutak:commit | `ttutak:commit` |

---

## 합격 기준

| 카테고리 | 합격선 |
|---------|--------|
| A (tddak 명시) | 10/10 (100%) — 명시적 키워드는 누락 없어야 함 |
| B (ttutak 위임) | 9/10 (90%) — 1건 오작동 허용 (Passive 라우팅 한계) |
| C (모호) | 4/5 (80%) — 사용자 확인 또는 합리적 기본값 |
| D (슬래시) | 5/5 (100%) — 슬래시 커맨드는 자동 namespace로 분리 |
| **전체** | **28/30 (93.3%)** |

미달 시 조치:
- A 미달 → description 마커 강화 (`[tddak/TDD 강제]` → 더 구체적인 키워드)
- B 미달 → tddak description에 "TDD 미명시 시 ttutak:X 사용" 명시 강화
- C 미달 → `.claude/rules/tddak-routing.md`의 모호 표현 처리 규칙 추가
- D 미달 → 플러그인 등록 자체 문제. plugin.json 검증 필요

---

## 자동화 도구 (선택 사항)

### 수동 테스트 보조 스크립트

각 시나리오를 한 줄씩 입력하고 결과를 기록하는 헬퍼:

```bash
# /Users/bonseung/projects/tddak/tools/conflict-test-runner.sh (선택 작성)
# 사용자가 각 시나리오를 Claude Code에서 실행 후 결과를 수동 기록
# 결과는 .claude/test-results/conflict-{date}.md에 저장
```

### CI 통합 (향후)

- GitHub Actions 워크플로우로 신규 PR마다 충돌 시나리오 자동 실행
- 합격선 미달 시 PR 차단
- 현재는 베타 단계이므로 수동 테스트로 충분

---

## 테스트 결과 기록 템플릿

새 테스트 라운드 시작 시 다음 양식으로 기록:

```markdown
# 충돌 테스트 결과 — {YYYY-MM-DD}

테스터: {이름}
환경: ttutak {버전}, tddak {버전}
Claude Code 버전: {버전}

## 결과 요약
- A (tddak 명시): N/10
- B (ttutak 위임): N/10
- C (모호): N/5
- D (슬래시): N/5
- 전체: N/30 ({비율}%)

## 합격 여부
- [ ] 합격선 28/30 달성

## 미통과 시나리오
- #N: {입력} → 기대 {X} / 실제 {Y}
  - 원인 분석: ...
  - 조치 제안: ...

## 다음 액션
- [ ] description 마커 강화
- [ ] 라우팅 규칙 추가
- [ ] 재테스트 일정
```

저장 위치: `.claude/test-results/conflict-{YYYY-MM-DD}.md`

---

## 알려진 한계

1. **자동 검증 불가**: Claude의 자연어 해석은 비결정적이므로 동일 시나리오에서도 다른 라우팅 가능. 5회 평균 측정 권장.
2. **버전 의존성**: Claude Code/Claude 모델 버전 변경 시 재테스트 필요.
3. **컨텍스트 영향**: 동일 세션 내 이전 대화가 라우팅에 영향. 매 시나리오마다 새 세션 권장.
4. **사용자 편향**: 테스터가 기대값을 알면 입력 시 무의식적 힌트 가능. 가능하면 블라인드 테스트.

---

## 라우팅 정확도 개선 사이클

```
1. 테스트 실행 (30 시나리오)
2. 미통과 분석
3. 원인 분류:
   - description 마커 약함 → 마커 강화
   - 라우팅 규칙 누락 → tddak-routing.md 보강
   - 자연어 모호 → 사용자 확인 로직 추가
4. 수정 후 재테스트
5. 합격선 도달 시 베타 진입
```

목표: **베타 출시 전 3회 연속 합격선 달성**.
