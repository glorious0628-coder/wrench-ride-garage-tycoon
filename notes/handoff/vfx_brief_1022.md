# VFX 손보기 (공개 전) — wr-vfx 브리프 (메인, 10-22 17:35)

**사용자 결정 (10-22)**: "공개 전에 VFX 2~5번 넣어 줘. Kenney Particle Pack 받아도 돼."
근거 영상 = `유튜브_영상_배울점_10-20.md` 영상 20(fwjelaa VFX). 핵심: 기본 파티클 그대로 쓰면 싸 보임 · 증상은 계속 움직이게 · 작은 시험 판 먼저 · 진짜 사진과 나란히 비교.
**품질이 안 되면 안 넣음**(사용자 규칙) → 전부 스위치 `Config.Features.VfxV2` 뒤에(꺼지면 지금 그대로). 메인이 10/27 밤 스위치 목록에서 켤지 정해요.

## 질감 (메인이 고르고 올림 — 이미 끝, 이 번호만 쓰기)
Kenney Particle Pack 1.1 (**CC0**, `art/vfx/textures/KENNEY_LICENSE_CC0.txt`). 원본 80장 한 장 모음 `notes/research/vfx/kenney_sheet.png`, 후보 비교 `notes/research/vfx/kenney_candidates.png`. 전부 **흰색 + 투명** → 색은 `Color`로 입혀요. 장부 `art/roblox_assets.json`(decal + imageId), 게임 Use 권한 줌.

| 이름 | 파일 | Texture (imageId) | 쓰는 곳 |
|---|---|---|---|
| steam_cloud | `vfx_steam_cloud.png` | `rbxassetid://103788368681944` | 라디에이터 김 덩어리, 시동 직후 얇은 흰 김(나중 겨울) |
| steam_wisp | `vfx_steam_wisp.png` | `rbxassetid://111922041749975` | 보닛 틈에서 실처럼 오르는 김 |
| smoke_cloud | `vfx_smoke_cloud.png` | `rbxassetid://133040601398033` | 시동 배기 한 번 '푸' (`carStart`) |
| smoke_puff | `vfx_smoke_puff.png` | `rbxassetid://92482215163332` | 작은 퍽: 머플러 녹 구멍 배기 새기, 고물 먼지(`puff`) |
| dust_flecks | `vfx_dust_flecks.png` | `rbxassetid://137595598104902` | 녹 가루·흙 부스러기(오래된 볼트 풀 때, 고물) |
| zap | `vfx_zap.png` | `rbxassetid://134873323429835` | 배터리 단자 순서 틀림 '지직' 전기 불꽃 |
| streak | `vfx_streak.png` | `rbxassetid://91154651646281` | 날아가는 불꽃 줄(`Orientation = VelocityParallel`), 떨어지는 냉각수 방울 |
| soot | `vfx_soot.png` | `rbxassetid://139316219214926` | 머플러 구멍 둘레 그을음 **Decal**(Color3 거의 검정) |
| ring | `vfx_ring.png` | `rbxassetid://120639155900790` | 웅덩이에 방울 떨어질 때 물결, 볼트 돌 때 작은 고리(지금 네온 공 대신) |
| dot_soft | `vfx_dot_soft.png` | `rbxassetid://98589754735886` | 방울·작은 빛 |

## 할 일 (순서대로, 하나 끝날 때마다 Play로 보고 다음)
0. **작은 시험 판 먼저**: 빈 곳에 질감 10장을 파티클로 띄워 방향·크기·색 확인(특히 streak 방향, wisp가 위로 흐르게) → 사진 1장.
1. **머플러 고증 (board 17:25 줄 — 원래 wr-dev, 너에게 옮김)**: `FaultService` EMITTERS.Muffler 꼬리관 **검은 연기 → 없앰**. 검은 연기 = 연료 과다(다른 고장). 실제 머플러 고장 = 시끄러움·덜컹·처짐 + **녹 구멍에서 회색 배기가 박자 맞춰 '퍽퍽'**(smoke_puff, 1초에 2~4번, 짧게 사라짐) + **구멍 둘레 그을음**(soot Decal) — 근거 `notes/research/car_knowledge/08_exhaust.md` 201~203줄(소리·걸이·그을음). 글(say·cmp)은 이미 맞음.
2. **질감 바꾸기**: `rbxasset://textures/particles/smoke_main.dds`·`sparkles_main.dds`를 쓰는 곳 전부(`Effects.luau` 49·90·120줄, `FaultService` 19줄) → 위 표. 다른 ParticleEmitter(`CurbService` 물, `Halloween`, World 파일들)는 보기만 하고 이상하면 board에 적기(World = wr-builder 파일).
3. **효과를 한 곳에서**: 이미터를 파일마다 손으로 만들지 말고 `Shared/VfxPresets.luau`(이름 → 질감·색·크기·수명·속도·한 번 개수·지연) + `VFX.burst(이름, 위치, 크기)` / `VFX.loop(이름, Attachment)` 하나로. 영상의 EmitCount/EmitDelay 속성 생각과 같아요: 숫자는 표 한 곳만 고치면 됨. 만든 효과는 크기 인자로 세단·SUV·해치백 맞추기(빛 Range만 따로).
4. **증상이 계속 움직이게**:
   - 라디에이터: 보닛 틈(FX_HoodGap)에서 steam_wisp + steam_cloud가 **흔들리며 오르고 빨리 사라짐**(김은 연기보다 투명하고 금방 없어져요 — 실제 사진 확인). 앞 범퍼 아래로 **냉각수 방울이 '똑'**(1~1.5초마다, 분홍 E7A9C4 — fault_looks §5b) → 웅덩이에 닿으면 ring 물결 작게. 웅덩이 커지는 건 지금 그대로.
   - 머플러: 처진 머플러가 **살짝 흔들림**(±1~2°, 느리게) + 1번의 퍽퍽.
   - 배터리 지직: zap 0.1~0.15초 + streak 불꽃 몇 개(주황·흰). 지금 sparkles 28개보다 **작고 짧게**(실제 단자 불꽃은 작아요).
   - 연기·김은 `LightEmission = 0`(빛나면 'AI 티'), 빛은 zap·불꽃만.
5. **폰 품질 단계**: `UserGameSettings.SavedQualityLevel`이 1~3(직접 낮춤)이면 개수·Rate 절반 이하, 자동(Automatic)이면 값을 못 읽으니 터치 + 작은 화면이면 중간 단계. 한 화면에 도는 loop 효과 상한(예: 8개, 먼 차부터 끔). 단계별 배수는 3번 표에.

## 다 됐다 = 이것들이 있어야 메인이 받아요
- **실제 사진 3장 이상씩과 Play 사진 나란히**(라디에이터 김·냉각수 방울·머플러 배기 새기 + 그을음·배터리 단자 불꽃) — 근거 링크(내장 브라우저 스크린샷 + 주소). 비교 칸 없으면 다시 시켜요(README 규칙).
- 폰 크기 844×390 Play 사진, 품질 낮음일 때 사진 1장.
- `py -I tools/luau_check.py <바꾼 파일>` → new 0, lint·컴파일 0, Play 콘솔 오류 0, 스위치 끄면 지금과 똑같은지 확인.
- board 한 줄 + 메인 보고. 굽기는 wr-release(10/28 시험판).
