# tddak 자연어 라우팅 규칙

tddak과 ttutak이 동시 설치된 환경에서 자연어 트리거를 어느 플러그인으로 라우팅할지 명시.

---

## 핵심 원칙: Passive 라우팅

tddak은 **명시적 트리거**가 있을 때만 동작한다. 일반 자연어는 ttutak이 처리하도록 평화 공존한다.

이유:
- TDD는 적극적 선택이지 기본값이 아님
- ttutak 기존 사용자의 머슬 메모리 보존
- 충돌 시 사용자 의도와 다른 동작 방지

---

## tddak 트리거 키워드

다음 키워드가 사용자 메시지에 포함되면 tddak으로 라우팅한다.

### 강한 트리거 (단독으로 tddak 매칭)

| 키워드 | 호출 스킬 |
|--------|----------|
| `tddak`, `tddak으로` | `/tddak:dev` (기본) |
| `TDD`, `TDD로`, `TDD 방식`, `TDD 사이클` | `/tddak:dev` |
| `테스트 먼저`, `test first` | `/tddak:dev` |
| `RED-GREEN`, `red-green-refactor`, `레드그린` | `/tddak:dev` |
| `verify 후`, `verify 게이트` | `/tddak:commit` |
| `Given-When-Then`, `G-W-T` | `/tddak:context` |

### 조합 트리거 (다른 키워드와 결합)

| 사용자 표현 | 호출 스킬 |
|------------|----------|
| `TDD로 개발`, `TDD로 구현`, `테스트 먼저 개발` | `/tddak:dev` |
| `TDD로 커밋`, `tddak으로 커밋`, `verify 후 커밋` | `/tddak:commit` |
| `tddak으로 PR`, `테스트 결과 첨부 PR`, `TDD PR` | `/tddak:pull-request` |
| `tddak으로 컨텍스트`, `Given-When-Then으로 AC`, `시나리오로 PRD` | `/tddak:context` |
| `tddak으로 lens`, `TDD 정책 분석` | `/tddak:lens` |
| `tddak으로 부채`, `TDD 관점 부채 분석` | `/tddak:tech-debt` |
| `tddak으로 리서치`, `TDD 리서치` | `/tddak:research` |

### 단계별 단독 호출

| 사용자 표현 | 호출 스킬 |
|------------|----------|
| `실패 테스트 먼저`, `RED 단계`, `테스트 작성` | `/tddak:red` |
| `통과 코드 작성`, `GREEN 단계` | `/tddak:green` |
| `리팩토링`, `REFACTOR 단계`, `정리` | `/tddak:refactor` |
| `검증 게이트`, `완료 검증`, `verify` | `/tddak:verify` |

---

## ttutak으로 위임하는 표현

다음 자연어는 ttutak으로 라우팅한다 (tddak 동작 안 함).

| 사용자 표현 | 호출 스킬 |
|------------|----------|
| `개발해줘`, `구현해줘`, `만들어줘` (일반) | `/ttutak:dev` |
| `기능 추가`, `버그 수정`, `핫픽스` (일반) | `/ttutak:dev` |
| `커밋해줘`, `commit` (일반) | `/ttutak:commit` |
| `PR 올려`, `pull request`, `풀리퀘` (일반) | `/ttutak:pull-request` |
| `컨텍스트`, `도메인 등록`, `용어 등록` (일반) | `/ttutak:context` |
| `lens`, `정책 확인`, `영향도` (일반) | `/ttutak:lens` |
| `부채`, `tech-debt`, `코드 건강` (일반) | `/ttutak:tech-debt` |
| `리서치`, `research` (일반) | `/ttutak:research` |

---

## 모호한 표현 처리

다음 표현은 모호할 수 있다. 사용자에게 명시적 확인을 요청한다.

| 사용자 표현 | 처리 |
|------------|------|
| `테스트 추가`, `테스트 작성` | "단순 테스트 작성이면 ttutak:test, TDD RED 단계면 tddak:red. 어느 쪽인가요?" |
| `테스트 커버` | "기존 코드의 테스트 보강이면 ttutak, 새 기능의 TDD라면 tddak. 어느 쪽인가요?" |
| `리뷰`, `code review` | "일반 리뷰면 ttutak:dev review phase, TDD 2단계 리뷰면 tddak:dev. 어느 쪽인가요?" |

---

## 슬래시 커맨드 권장

모호함을 피하기 위해 **슬래시 커맨드 사용을 강력 권장**한다:

```
일반 개발: /ttutak:dev 로그인 기능 추가
TDD 개발:  /tddak:dev 로그인 기능 추가
```

자연어 트리거는 명시적 키워드를 사용한다:
- ❌ "개발해줘" (모호)
- ✅ "TDD로 개발해줘" (명시)
- ✅ "tddak으로 개발해줘" (명시)

---

## 라우팅 결정 트리

```
사용자 메시지 수신
    ↓
tddak 키워드 포함?
    ├─ Yes → tddak으로 라우팅
    └─ No  ↓
       슬래시 커맨드 사용?
           ├─ /tddak:* → tddak 실행
           ├─ /ttutak:* → ttutak 실행
           └─ 없음 ↓
              모호한 표현?
                  ├─ Yes → 사용자에게 확인
                  └─ No  → ttutak으로 라우팅 (기본)
```

---

## 자가 점검

라우팅 결정 후 다음을 확인:

- [ ] 사용자 의도와 호출된 플러그인이 일치하는가?
- [ ] tddak으로 라우팅했다면 사용자가 TDD 명시했는가?
- [ ] ttutak으로 라우팅했다면 사용자가 일반 개발 의도였는가?
- [ ] 모호함이 있었다면 사용자에게 확인했는가?

위반 시 사용자에게 사과하고 올바른 플러그인으로 재실행을 제안한다.
