# Damagochi 캐릭터 도감

이 문서는 앱의 `Species.allSpecies`와 `SpriteSheet`가 **현재 실제로 렌더링하는** 캐릭터를 기준으로 만든 도감이다. 이름·영문명·영구 ID·MBTI 그룹·희귀도는 카탈로그와 같은 순서이며, 저장 데이터는 ID를 기준으로 복원한다.

## 실제 앱 렌더링 프리뷰

아래 이미지는 모든 캐릭터의 `alive / Stage 3 / front / 첫 애니메이션 프레임`을 `SpriteSheet.frames`로 직접 렌더링한 결과다. 카드의 `#번호`는 뒤의 캐릭터 목록 번호와 일치한다. 따라서 문서의 그림은 콘셉트 이미지가 아니라 현재 앱 화면에서 사용하는 실제 픽셀 데이터다.

![80종 캐릭터 실제 Stage 3 front 스프라이트](./docs/assets/character-catalog.png)

## 화면별 노출 방식

| 화면 | 사용하는 방향 | 실제 노출 방식 |
|---|---|---|
| 메뉴바 팝오버의 2×2 펫 슬롯 | `front` | 선택 전에도 각 펫의 작은 정면 프리뷰와 능력치가 보인다. |
| 펫 상태 화면·장비 위치 조정 | `front` | 선택된 펫과 장비 오버레이를 정면으로 표시한다. |
| 배틀 — 내 펫 | `back` | 상대를 바라보는 뒷모습으로 표시한다. |
| 배틀 — 상대 펫 | `front` | 플레이어를 바라보는 정면으로 표시한다. |
| 공원 산책 | `sideLeft` / `sideRight` | 이동 방향에 맞춰 옆모습을 사용한다. |

![상태·배틀·산책에서 실제로 쓰는 방향 프레임](./docs/assets/character-directions.png)

- 모든 캐릭터와 성장 단계는 `front`, `back`, `sideLeft`, `sideRight` 각각 2프레임 애니메이션을 제공한다.
- Reduce Motion이 켜져 있으면 화면은 각 방향의 첫 프레임을 고정해서 사용한다.
- 장비 레이어는 항상 `기본 펫 → head/hand → effect` 순서이며, 장비 위치 오프셋도 방향별 렌더링 스케일에 맞춰 적용된다.
- Stage 1·2·3은 같은 캐릭터 ID를 유지하며 몸통 크기만 성장한다. 도감 프리뷰는 식별이 가장 쉬운 Stage 3로 통일했다.

> 참고: 1~40번은 기존 수제 정면 스프라이트를 24×24 그리드에 맞춰 사용한다. 41~80번은 확장 카탈로그용 방향 시트로 렌더링한다. 두 경우 모두 이 문서의 프리뷰가 현재 앱 출력값이다.

## NT — 분석형 / Theoretical

| # | 이름 | English / ID | 희귀도 | 화면에서 보이는 핵심 실루엣 |
|---:|---|---|---|---|
| 1 | 올빼미 | owl / `owl` | common | 갈색 몸, 뾰족한 귀와 검은 눈가 |
| 2 | 늑대 | wolf / `wolf` | common | 회색 얼굴, 양쪽 귀와 흰 주둥이 |
| 3 | 수정 | crystal / `crystal` | common | 청록색 다면 수정, 흰 반짝임 |
| 4 | 문어 | octopus / `octopus` | rare | 보라색 머리와 여러 다리 |
| 5 | 안드로이드 | android / `android` | rare | 회색 기계 몸, 청록·노랑 표시등 |
| 6 | 불사조 | phoenix / `phoenix` | rare | 주황·빨강 날개형 몸과 노랑 장식 |
| 7 | 드래곤 | dragon / `dragon` | legendary | 붉은 몸, 뿔과 날개형 돌기 |
| 8 | 스핑크스 | sphinx / `sphinx` | legendary | 황토색 석상형 몸과 흰 눈 |
| 9 | 로봇 | robot / `robot` | mythic | 청회색 기계 몸, 노랑 상태등 |
| 10 | 성운 | nebula / `nebula` | mythic | 보라·하늘색 가로 줄무늬 구름 |
| 41 | 큰까마귀 | Raven / `raven` | common | 청록 머리와 연두 몸통의 각진 시트 |
| 42 | 수달 | Otter / `otter` | common | 주황 머리와 연두 몸통 |
| 43 | 카멜레온 | Chameleon / `chameleon` | common | 연두 머리·몸, 작은 측면 돌기 |
| 44 | 장수풍뎅이 | Atlas Beetle / `atlas_beetle` | rare | 분홍 머리와 민트 몸, 촉각 점 |
| 45 | 태엽 인형 | Clockwork Doll / `clockwork` | rare | 연두 머리와 코랄 몸, 양쪽 점 장식 |
| 46 | 지식의 구체 | Knowledge Orb / `orb` | rare | 갈색 머리와 코랄 몸, 작은 흰 중심점 |
| 47 | 그리폰 | Gryphon / `gryphon` | legendary | 보라 머리와 파란 몸, 분홍 중심점 |
| 48 | 레비아탄 | Leviathan / `leviathan` | legendary | 연두 머리와 청록 몸, 날개형 측면 돌기 |
| 49 | 특이점 | Singularity / `singularity` | mythic | 파란 머리와 갈색 몸통, 작은 측면 돌기 |
| 50 | 시간용 | Chrono Dragon / `chrono_dragon` | mythic | 민트 머리와 초록 몸, 촉각 점 |

## NF — 이상형 / Creative

| # | 이름 | English / ID | 희귀도 | 화면에서 보이는 핵심 실루엣 |
|---:|---|---|---|---|
| 11 | 나비 | butterfly / `butterfly` | common | 보라색 양날개와 파란 몸 |
| 12 | 구름 | cloud / `cloud` | common | 흰 구름형 몸, 파란 눈·입 |
| 13 | 연꽃 | lotus / `lotus` | common | 분홍 꽃잎과 민트 받침 |
| 14 | 해파리 | jellyfish / `jellyfish` | rare | 라벤더 종 모양 몸과 촉수 |
| 15 | 여우 | fox / `fox` | rare | 주황 귀·얼굴과 흰 주둥이 |
| 16 | 유니콘 | unicorn / `unicorn` | rare | 흰 몸, 노랑 뿔, 분홍 포인트 |
| 17 | 버섯 | mushroom / `mushroom` | legendary | 빨간 갓과 흰 점·줄무늬 몸 |
| 18 | 요정 | fairy / `fairy` | legendary | 분홍 몸, 노랑 왕관과 날개 |
| 19 | 천상 | celestial / `celestial` | mythic | 금색 별·십자 모양 광원 |
| 20 | 오로라 | aurora / `aurora` | mythic | 청록·보라·하늘색 띠 |
| 51 | 사슴 | Deer / `deer` | common | 코랄 머리와 라벤더 몸통 |
| 52 | 물개 | Seal / `seal` | common | 연두 머리와 갈색 몸통, 촉각 점 |
| 53 | 복숭아 | Peach / `peach` | common | 파란 머리와 민트 몸통, 작은 측면 돌기 |
| 54 | 달나방 | Luna Moth / `luna_moth` | rare | 파란 머리·분홍 몸, 하늘색 날개형 돌기 |
| 55 | 카피바라 | Capybara / `capybara` | rare | 노랑 머리와 갈색 몸통, 측면 손 |
| 56 | 인어 | Mermaid / `mermaid` | rare | 분홍 머리와 민트 몸, 흰 중심점 |
| 57 | 페가수스 | Pegasus / `pegasus` | legendary | 보라 머리와 청록 몸, 촉각 점 |
| 58 | 달꽃 | Moonflower / `moonflower` | legendary | 연두 머리와 황토 몸, 양쪽 잎사귀 돌기 |
| 59 | 세라프 | Seraph / `seraph` | mythic | 보라 머리와 초록 몸, 촉각 점 |
| 60 | 꿈고래 | Dream Whale / `dream_whale` | mythic | 민트 머리와 분홍 몸, 민트 중심점 |

## SJ — 전통형 / Responsible

| # | 이름 | English / ID | 희귀도 | 화면에서 보이는 핵심 실루엣 |
|---:|---|---|---|---|
| 21 | 거북이 | turtle / `turtle` | common | 초록 등딱지와 밝은 머리 |
| 22 | 펭귄 | penguin / `penguin` | common | 검정·흰 몸과 노랑 부리·발 |
| 23 | 곰 | bear / `bear` | common | 갈색 얼굴, 귀와 짧은 팔다리 |
| 24 | 돌 | rock / `rock` | rare | 회색 바위형 덩어리, 검은 점 눈 |
| 25 | 선인장 | cactus / `cactus` | rare | 밝은 초록 선인장 몸과 돌기 |
| 26 | 고슴도치 | hedgehog / `hedgehog` | rare | 갈색 가시 몸과 분홍 얼굴 |
| 27 | 파리지옥 | parrot / `parrot` | legendary | 초록 입 모양 몸, 빨간 띠·노랑 눈 |
| 28 | 골렘 | golem / `golem` | legendary | 회색 기계형 몸과 작은 눈 |
| 29 | 코끼리 | elephant / `elephant` | mythic | 큰 회색 얼굴, 귀·코 실루엣 |
| 30 | 크라켄 | kraken / `kraken` | mythic | 하늘색 촉수형 몸과 흰 머리띠 |
| 61 | 비버 | Beaver / `beaver` | common | 보라 머리와 갈색 몸, 흰 중심점 |
| 62 | 코알라 | Koala / `koala` | common | 분홍 머리와 황토 몸, 흰 중심점 |
| 63 | 도토리 | Acorn / `acorn` | common | 파란 머리와 민트 몸, 촉각 점 |
| 64 | 오소리 | Badger / `badger` | rare | 황토 머리와 민트 몸, 측면 손 |
| 65 | 찻주전자 | Teapot / `teapot` | rare | 주황 머리와 갈색 몸, 측면 손 |
| 66 | 등불 | Lantern / `lantern` | rare | 주황 머리와 청록 몸, 촉각 점 |
| 67 | 매머드 | Mammoth / `mammoth` | legendary | 초록 머리와 코랄 몸, 초록 측면 돌기 |
| 68 | 요새 | Bastion / `bastion` | legendary | 민트 머리와 연두 몸, 민트 중심점 |
| 69 | 세계수 | World Tree / `world_tree` | mythic | 청록 머리와 분홍 몸, 하늘색 양측 돌기 |
| 70 | 타이탄 | Titan / `titan` | mythic | 갈색 머리와 보라 몸, 흰 중심점 |

## SP — 모험형 / Free

| # | 이름 | English / ID | 희귀도 | 화면에서 보이는 핵심 실루엣 |
|---:|---|---|---|---|
| 31 | 고양이 | cat / `cat` | common | 주황 얼굴, 검은 귀, 흰 주둥이 |
| 32 | 강아지 | puppy / `puppy` | common | 회갈색 귀와 얼굴, 흰 주둥이 |
| 33 | 토끼 | rabbit / `rabbit` | common | 긴 흰 귀와 분홍 코 |
| 34 | 불꽃 | flame / `flame` | rare | 노랑·주황 불꽃형 몸 |
| 35 | 박쥐 | bat / `bat` | rare | 짙은 회색 날개와 작은 붉은 눈 |
| 36 | 전갈 | scorpion / `scorpion` | rare | 노랑 갑각과 집게·꼬리형 돌기 |
| 37 | 물고기 | fish / `fish` | legendary | 하늘색 몸, 노랑 지느러미와 꼬리 |
| 38 | 번개 | lightning / `lightning` | legendary | 노랑 번개 지그재그 |
| 39 | 달토끼 | moonrabbit / `moonrabbit` | mythic | 흰 긴 귀와 검정 외곽선 |
| 40 | 혜성 | comet / `comet` | mythic | 하늘색 혜성 몸과 흰 꼬리 |
| 71 | 너구리 | Raccoon / `raccoon` | common | 연두 머리와 코랄 몸, 흰 중심점 |
| 72 | 페럿 | Ferret / `ferret` | common | 코랄 머리와 라벤더 몸, 측면 손 |
| 73 | 도마뱀 | Gecko / `gecko` | common | 보라 머리와 분홍 몸, 분홍 중심점 |
| 74 | 가오리 | Skate / `skate` | rare | 청록 머리와 청록 몸, 흰 중심점 |
| 75 | 앵무새 | Parakeet / `parakeet` | rare | 초록 머리와 갈색 몸, 초록 측면 돌기 |
| 76 | 닌자 | Ninja / `ninja` | rare | 보라 머리와 노랑 몸, 촉각 점 |
| 77 | 와이번 | Wyvern / `wyvern` | legendary | 보라 머리와 갈색 몸, 촉각 점 |
| 78 | 썬더버드 | Thunderbird / `thunderbird` | legendary | 보라 머리와 분홍 몸, 촉각 점 |
| 79 | 별여우 | Star Fox / `starfox` | mythic | 보라 머리와 민트 몸, 촉각 점 |
| 80 | 공허 질주자 | Void Runner / `void_runner` | mythic | 주황 머리와 초록 몸, 촉각 점 |

## 데이터 호환성 및 갱신 방법

- 캐릭터의 영구 식별자는 표의 `ID`다. 기존 저장 데이터의 ID는 변경하지 않는다.
- 종족의 이름·영문명·희귀도·MBTI 그룹은 [Species.swift](./Sources/DamagochiCore/Models/Species.swift)에서, 실제 프레임은 [SpriteSheet.swift](./Sources/DamagochiRenderer/SpriteSheet.swift) 및 [ExpandedSpeciesSprites.swift](./Sources/DamagochiRenderer/ExpandedSpeciesSprites.swift)에서 관리한다.
- 캐릭터를 추가하거나 스프라이트를 바꾸면 이 문서의 프리뷰 이미지도 같은 `SpriteSheet.frames` 출력으로 다시 생성해야 한다.
