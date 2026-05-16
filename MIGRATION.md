# ttutak → tddak 마이그레이션 가이드

기존 ttutak 사용자가 tddak으로 옮길 때의 차이점과 적응 방법.

---

## 핵심 변화 요약

tddak은 ttutak의 파이프라인 위에 **TDD 강제**를 적용합니다. 동일한 파이프라인 구조(PRD → 설계 → 구현 → 리뷰 → PR)이지만, 각 단계에 **Iron Law 게이트**가 추가됩니다.

| 변화 | 영향 |
|------|------|
| AC가 Given-When-Then 형식 강제 | PRD 작성에 약간 더 시간 소요. 대신 자동 테스트 변환 가능 |
| 설계에 testability 평가 추가 | 강결합 설계가 차단됨. DI 도입 등 권고됨 |
| 구현이 RED-GREEN-REFACTOR 사이클 | 단일 coder 호출 대신 격리된 3 에이전트 순차 |
| 리뷰가 spec → quality 순차 | qa+security 병렬 대신 spec 우선 검증 |
| commit 전 verify 게이트 | 테스트 미실행 시 commit 차단 |

---

## 명령 매핑 (1:1 대응)

| ttutak 명령 | tddak 대응 | 동작 차이 |
|------------|-----------|----------|
| `/ttutak:setup` | `/tddak:setup` | tddak이 ttutak config 재사용 (동일 환경에서 1회만 실행 가능) |
| `/ttutak:dev <요청>` | `/tddak:dev <요청>` | TDD 사이클 강제 |
| `/ttutak:commit` | `/tddak:commit` | verify 게이트 통과 후 커밋 |
| `/ttutak:pull-request` | `/tddak:pull-request` | PR 본문에 verify 증거 첨부 |
| `/ttutak:context` | `/tddak:context` | AC를 G-W-T로 작성 강제 |
| `/ttutak:lens` | `/tddak:lens` | 영향도에 테스트 영향도 추가 |
| `/ttutak:tech-debt` | `/tddak:tech-debt` | 테스트 부채 가중치 상향 |
| `/ttutak:research` | `/tddak:research` | 동일 동작 |
| `/ttutak:test` | **제거됨** | dev 파이프라인의 RED 단계에 통합 |
| `/ttutak:humanizer` | **미포함** | ttutak에서 직접 사용 |
| `/ttutak:cross-review` | **미포함** | ttutak에서 직접 사용 |

---

## 신규 스킬 (tddak 전용)

| 스킬 | 사용 시점 |
|------|----------|
| `/tddak:red` | RED 단계 단독 실행 (보통 dev 내부 자동 호출) |
| `/tddak:green` | GREEN 단계 단독 (RED 후) |
| `/tddak:refactor` | REFACTOR 단계 단독 (GREEN 후) |
| `/tddak:verify` | 완료 검증 게이트 단독 호출 |

---

## 적응 시나리오

### 시나리오 1: 신규 기능 개발

**기존 (ttutak)**:
```
/ttutak:dev 로그인 기능 추가
→ PRD (자연어 AC) → 설계 → 구현 (coder) → 자기점검 → 테스트 작성 → 리뷰 → 커밋 → PR
```

**신규 (tddak)**:
```
/tddak:dev 로그인 기능 추가
→ PRD (Given-When-Then AC 강제) → 설계 (testability 평가)
→ RGR 사이클 (태스크별 red→green→refactor) → spec 리뷰 → quality+security 리뷰
→ verify 게이트 → 커밋 → PR
```

**적응 포인트**:
- PRD 작성 시 자연어 AC가 거부됨 → Given-When-Then 형식으로 재작성 권고
- 구현 단계가 더 길어 보임 (3개 에이전트 호출) → 실제로는 디버깅이 줄어 총 시간 단축
- "구현 후 테스트" 습관 버리고 "테스트 후 구현" 적응

### 시나리오 2: 핫픽스

**기존 (ttutak)**:
```
/ttutak:dev --hotfix 로그인 버그
→ 경량 PRD → 구현 → 인수 검증 → 커밋 → PR
```

**신규 (tddak)**:
```
/tddak:dev --hotfix 로그인 버그
→ 경량 PRD (G-W-T 강제 유지) → RGR 사이클 (간소화) → 긴급 보안 감사 (H1~H4)
→ verify 게이트 → 인수 검증 → 커밋 → PR
```

**적응 포인트**:
- hotfix여도 RGR 사이클은 강제됨 (단, 단순 버그는 1 태스크로 빠르게 종료)
- design Phase만 건너뜀. verify 게이트는 항상 강제

### 시나리오 3: 기존 코드 테스트 추가

**기존 (ttutak)**:
```
/ttutak:test 결제 도메인
→ test 스킬이 자동으로 단위/통합/E2E 테스트 작성
```

**신규 (tddak)**:
```
/tddak:red 결제 한도 검증 시나리오
→ RED 단계로 실패 테스트 작성
→ 기존 구현이 통과시키면 자동 통과 (회귀 테스트로 동작)
```

또는:
```
/tddak:dev 결제 도메인 테스트 보강
→ dev 파이프라인이 AC 단위로 분해하여 RGR 사이클로 테스트 추가
```

**적응 포인트**:
- 단일 `/test` 명령 대신 dev 또는 red를 사용
- "테스트만 추가"가 아니라 "AC 단위 검증"으로 사고 전환

### 시나리오 4: ttutak 사용자가 tddak 추가 설치 (병행)

```
# 둘 다 설치된 상태

# 일반 빠른 작업: ttutak
/ttutak:dev 간단한 설정 변경

# TDD 필요 작업: tddak
/tddak:dev 결제 한도 정책 (검증 중요)

# 자연어 트리거 시 명시
"TDD로 결제 한도 추가해줘" → /tddak:dev
"결제 한도 추가해줘" → /ttutak:dev
```

**적응 포인트**:
- 두 플러그인이 충돌 없이 공존 (3중 식별 메커니즘)
- 작업 성격에 따라 선택적으로 사용

---

## 자주 묻는 질문

### Q1. test 스킬은 어디 갔나요?

**A**: tddak에서는 테스트가 RED 단계의 산출물입니다. 단일 `/test` 명령 대신 dev 파이프라인 또는 `/tddak:red`를 사용합니다. 기존 코드의 회귀 테스트를 추가하고 싶다면 `/tddak:red <시나리오>`로 직접 호출하세요.

### Q2. PRD를 매번 Given-When-Then으로 써야 하나요?

**A**: 네, 강제됩니다. 단, hotfix 모드에서도 동일합니다. 처음에는 어색하지만 적응되면 자동 테스트 변환과 리뷰 효율이 크게 향상됩니다. 사용자가 직접 G-W-T를 못 쓰면 product-owner 에이전트가 자연어 요구사항에서 변환을 도와줍니다.

### Q3. 구현이 더 느려지지 않나요?

**A**: 단일 사이클로는 약간 느립니다 (3 에이전트 호출). 하지만:
- 디버깅 시간 감소 (RED가 미리 엣지 케이스 강제)
- 리팩토링 안전성 (테스트가 회귀 차단)
- PR 1차 통과율 상승

총 사이클 시간은 단축됩니다.

### Q4. coder 에이전트는 못 쓰나요?

**A**: tddak:dev 내부에서는 deprecated이라 호출 안 됩니다. ttutak에서 직접 호출은 여전히 가능합니다. tddak 환경에서 직접 구현이 필요하면 `/tddak:green <구현 요청>`을 사용하세요 (단, RED 선행 필요).

### Q5. testability 평가에서 자꾸 막힙니다

**A**: testability score < 7이면 architect 재설계가 권고됩니다. 일반적인 해결:
- 전역 상태 의존 → 의존성 주입(DI)으로 전환
- static 메서드 호출 → 인터페이스 추출
- 강결합 → 책임 분리 (단일 책임 원칙)

레거시 코드 위에서 작업한다면 testability 게이트를 일시 우회할 수 있지만 (`AskUserQuestion`의 "위험 수용"), RGR 사이클이 일부 컴포넌트에서 실패할 수 있습니다.

### Q6. verify 게이트가 너무 엄격합니다

**A**: 의도된 동작입니다. "should work" 같은 추측을 차단하는 것이 Iron Law 3입니다. 빌드/테스트 명령이 너무 느린 환경이라면 `.claude/config.json`의 `timeouts.build`를 늘릴 수 있습니다 (기본 5분).

### Q7. ttutak으로 돌아갈 수 있나요?

**A**: 네, 언제든 가능합니다. tddak을 비활성화하거나 제거해도 ttutak은 영향 받지 않습니다. `.dev/{branch}/` 산출물도 호환되므로 그대로 사용 가능합니다.

---

## 마이그레이션 체크리스트

기존 ttutak 사용자가 tddak으로 옮길 때:

- [ ] tddak 플러그인 설치
- [ ] `/tddak:setup` 실행 (ttutak config 재사용 확인)
- [ ] 첫 작업: 작은 기능으로 `/tddak:dev` 테스트
- [ ] G-W-T AC 작성 적응 (3-5회 반복하면 익숙해짐)
- [ ] testability 평가 결과 검토 (설계 개선 기회로 활용)
- [ ] RGR 사이클 1회 완주 (5-15분 / 태스크)
- [ ] verify 게이트 통과 확인
- [ ] PR 본문에 verify 증거 첨부 확인
- [ ] 자연어 트리거 가이드 숙지 ([.claude/rules/tddak-routing.md](.claude/rules/tddak-routing.md))

---

## 문제 보고

- 충돌 시나리오 발견: `.claude/rules/conflict-test-scenarios.md`의 양식으로 기록
- 식별 마커 누락: `bash .claude/hooks/skill-load-guard.sh --strict` 실행 후 위반 보고
- 일반 버그/제안: GitHub Issues
