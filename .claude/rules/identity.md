# tddak 정체성 규칙 (3중 식별 메커니즘)

tddak과 ttutak이 동시 설치된 환경에서 스킬 충돌을 방지하기 위한 절대 규칙.

---

## 핵심 원칙

tddak은 ttutak과 동일한 스킬 이름을 사용한다 (`dev`, `commit`, `pull-request`, `context`, `lens`, `tech-debt`, `research`). 충돌을 회피하기 위해 **모든 tddak 스킬은 3중 식별 메커니즘**을 따른다.

---

## ① Description 마커 (선택 단계)

모든 tddak 스킬의 `description`은 `[tddak/TDD 강제]` 접두사로 시작한다.

```yaml
---
name: dev
description: "[tddak/TDD 강제] PRD → RED-GREEN-REFACTOR → 리뷰 → PR. TDD 사이클 강제 개발 파이프라인. 일반 개발은 ttutak:dev 사용."
---
```

**규칙**:
- 접두사 `[tddak/TDD 강제]` 절대 누락 금지
- description 본문에 ttutak 대응 스킬 명시 (Claude의 선택 정확도 상승)
- 길이 제한 1024자 이내

**위반 시**:
- 자연어 트리거가 tddak/ttutak 사이에서 오작동
- 사용자가 의도하지 않은 스킬 실행

---

## ② SKILL.md 본문 헤더 (실행 진입 시)

모든 tddak 스킬의 본문은 다음 헤더 블록으로 시작한다.

```markdown
# tddak:{skill-name}

> **플러그인**: tddak (TDD 강제 파이프라인)
> **이 스킬**: {skill-name} — {핵심 책임 한 줄}
> **혼동 주의**: ttutak:{skill-name}와 다른 스킬. {핵심 차이점}
> **호출 시 주의**: 이 스킬 내에서 다른 스킬을 호출할 때 반드시 `tddak:` 접두사를 사용한다.
```

**규칙**:
- 첫 헤더는 반드시 `# tddak:{skill-name}` 형식
- 4줄 정체성 블록은 모두 포함
- ttutak에 동일 스킬이 없는 경우 (예: `using-tddak`, `red`)는 "ttutak에는 동일 스킬이 없음. tddak 전용." 표시

**위반 시**:
- Claude가 본문 진입 후 자기 정체성 확인 못 함
- 잘못된 워크플로우 실행 가능

---

## ③ 하위 스킬 호출 시 fully-qualified 강제

스킬 내에서 다른 스킬을 호출할 때 **반드시** `tddak:` 접두사를 포함한다.

### ✅ 올바른 호출

```
Skill("tddak:commit")
Skill("tddak:pull-request")
Skill("tddak:context")
Skill("tddak:verify")
Skill("tddak:red")
Skill("tddak:green")
Skill("tddak:refactor")
```

### ❌ 금지된 호출

```
Skill("commit")         # ttutak:commit이 호출될 수 있음
Skill("pull-request")   # 동일 위험
Skill("context")        # 동일 위험
Skill("dev")            # 동일 위험
Skill("lens")           # 동일 위험
```

**예외**: tddak에만 있는 신규 스킬은 접두사 없이도 충돌 없음. 하지만 **일관성을 위해 항상 접두사 사용**:

```
Skill("tddak:red")      # 추천 (일관성)
Skill("red")            # 동작은 하지만 비추천
```

**위반 시**:
- ttutak 스킬이 호출되어 TDD 게이트(verify, red 등) 우회
- 합리화 격파 표의 즉시 위반 사유
- "이번 한 번만"은 첫 예외가 규칙이 된다

---

## 자가 점검 체크리스트

새 tddak 스킬 작성 시 또는 기존 스킬 수정 시 다음을 확인한다.

- [ ] frontmatter의 `description`이 `[tddak/TDD 강제]`로 시작하는가?
- [ ] description에 ttutak 대응 스킬을 명시했는가? (충돌 스킬만)
- [ ] 본문 첫 줄이 `# tddak:{skill-name}`인가?
- [ ] 4줄 정체성 블록이 있는가?
- [ ] 모든 `Skill()` 호출에 `tddak:` 접두사를 붙였는가?
- [ ] "다른 스킬 호출 시 절대 규칙" 섹션을 포함했는가?

체크리스트 미통과 시 즉시 수정한다.

---

## Red Flags

다음 표현을 발견하면 즉시 식별 메커니즘 위반이다:

- "`Skill(\"commit\")` 으로 충분함" → 접두사 누락
- "ttutak과 호환되니까 접두사 안 써도 됨" → 합리화
- "이 스킬은 짧으니까 정체성 블록 생략" → 일관성 위반
- "description 마커는 description 본문에 있으면 됨" → 접두사 위치 위반
