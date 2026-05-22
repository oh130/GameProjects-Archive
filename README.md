**게임 개발 프로젝트 아카이브**  
게임잼 출품작, 기능 구현 튜토리얼, 인디 프로젝트까지의 기록을 담은 저장소.

> Unity · Godot

---

## 🎮 포함된 프로젝트

### 1. [Zomvester](./Zomvester)
<img width="640" height="360" alt="Image" src="https://github.com/user-attachments/assets/1477f1d6-7ae1-4230-b504-1537773b11bf" />
- 싱글 Survivor 게임, 5인 팀 (클라이언트 개발)
- Ludum Dare 52 출품작
- **개발 기간:** 2023년 1월, 72시간 제한 개발
- **사용 엔진:** Unity
- **핵심 구현 요소:** 
  - 3일이라는 한정된 스코프 안에서 기획안을 구동 가능한 로직으로 빠르게 프로토타이핑
  - 실시간 디버깅 및 예외 상황(Interrupt)에 대한 즉각적인 트러블 슈팅 경험
  - UI 연출 및 인게임 액션 오브젝트 간의 기본적인 싱글턴 패턴 활용
  - 가비지 컬렉션(GC) 부하 최소화를 위한 오브젝트 풀링(Object Pooling) 시스템 구현

### 2. [Cosmos](./Cosmos) (가제)
<img width="640" height="360" alt="Image" src="https://github.com/user-attachments/assets/df0f2fac-bebc-40dd-9f49-f746ce1449ee" />
- 턴제 로그라이트 게임, 1인 개발
- **개발 기간:** 휴학 기간 중 (2024년 말 ~ 2025년 초)
- **사용 엔진:** Godot
- **핵심 구현 요소:** 
  - 계층형 유한 상태 머신(HFSM) 기반의 매끄러운 턴제 전투 루프 제어
  - 다양한 버프/디버프 및 상태 효과를 유기적으로 처리하는 이벤트 큐(Event Queue) 시스템
  - CSV 파일을 활용한 대량의 아이템 및 스킬 정적 데이터 관리 구조 구축

### 3. 기타 장르 프로토타입
<img width="640" height="360" alt="Image" src="https://github.com/user-attachments/assets/2be9de71-0f44-4d25-835b-107b6fed0ffd" />
- 퍼즐, 디펜스, 캐주얼 등
- **개발 기간:** 휴학 기간 중 (2024년 말 ~ 2025년 초)
- **사용 엔진:** Unity / Godot
- **핵심 구현 요소:** 
  - 각 장르의 주요 로직 분석 및 설계
