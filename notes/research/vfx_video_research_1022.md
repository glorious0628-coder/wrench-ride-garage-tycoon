검색 도구 사용 한도가 중간에 끝나서 일부만 확인했습니다. 확인한 것과 못 한 것을 나눠서 적습니다.

## 1. 플러그인 제작자·가격·라이선스

- **"VFX Studio"**
  - Creator Store에 같은 이름의 플러그인이 있습니다. 제작자는 @XxOmqxXNerd이고, 설명은 "AIO (soon to be) vfx tool" 한 줄뿐입니다. https://create.roblox.com/store/asset/135581141962270/VFX-Studio
  - 질문하신 텍스처·메시 라이브러리, Emit 패널, EmitCount 속성이 이 플러그인의 기능인지는 확인하지 못했습니다.
  - 가격과 에셋 라이선스도 확인하지 못했습니다.
  - EmitCount/EmitDelay/EmitDuration은 다른 플러그인에도 있습니다. 예로 [Bezier의 VFX 플러그인](https://devforum.roblox.com/t/beziers-advanced-modular-vfx-plugin-10000-assets-add-ons/4180222)이 있습니다. 같은 이름의 다른 플러그인과 혼동했을 수 있으니, 설치 페이지의 제작자를 직접 확인하세요.
- **VFX Forge**
  - 제작자는 zilibobi입니다. https://devforum.roblox.com/t/plugin-vfx-forge-an-advanced-custom-vfx-system/3867553
  - 가격은 공식 페이지에서 확인하지 못했습니다. 이 DevForum 글의 한 사용자 리뷰에 "$15"라는 언급이 있을 뿐이라 불확실합니다.
  - 라이선스는 확인하지 못했습니다.
- **VFX Editor**
  - 제작자는 @VirtualButFake입니다. https://create.roblox.com/store/asset/18800449515/VFX-Editor
  - 이 plugin은 텍스처를 저장하는 기능을 제공합니다. 공식 라이브러리를 번들로 주는지는 확인하지 못했습니다.
  - 가격과 라이선스도 확인하지 못했습니다.
- **상업 사용 여부:** 세 플러그인 모두 확인하지 못했습니다. 유료 게임 패스가 있는 게임에 쓰기 전에, 각 제작자에게 직접 문의하거나 Roblox Creator Store 약관과 에셋 설명란을 직접 읽으세요.

## 2. 공식 문서 (일부만 확인)

- **FlipbookLayout:** 문서에 따르면 Grid2x2는 4프레임, Grid4x4는 16프레임, Grid8x8은 64프레임입니다. Custom은 FlipbookSizeX/Y로 격자 크기를 직접 정합니다. https://create.roblox.com/docs/effects/particle-emitters
- **FlipbookMode:** 속성이 있다는 것만 확인했습니다. 각 모드의 동작은 확인하지 못했습니다. https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter
- **Beam:** 빔은 두 Attachment 사이에 텍스처를 그립니다. 큐빅 베지어 곡선이라 CurveSize0/1로 휘어집니다. 텍스처는 Segments로 나뉜 구간에 그려집니다. https://create.roblox.com/docs/effects/beams
- **Emit() 버스트 패턴:** ParticleEmitter 레퍼런스에 "ParticleEmitter Burst" 예제가 있다는 것까지만 확인했습니다. https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter
- **확인하지 못한 것:** 아래 항목은 검색을 못 해서 자료가 없습니다.
  - Trail 문서
  - 폰 성능 기준의 개수·Rate (공식 수치는 찾지 못했습니다)
  - SavedQualityLevel로 효과를 줄이는 방법. UserGameSettings 문서 https://create.roblox.com/docs/reference/engine/classes/UserGameSettings 는 검색 결과에 나왔지만 내용은 읽지 않았습니다.
- **참고:** 한 버그 리포트는 Rate 50 이상에서 파티클이 비정상 동작하고 성능 문제가 생겼다고 보고했습니다. 공식 권장치가 아니라 개별 사례입니다. https://devforum.roblox.com/t/particles-beams-and-trails-all-disappearing-not-disappearing-when-supposed-to-and-causing-performance-issues/1584372

## 3. 정비·차 게임 VFX 사례

검색하지 못했습니다. 근거 없이 쓰면 지어낼 위험이 있어서 비워 둡니다.

## 4. 배기 연기 색 (정비 출처 4곳)

여러 출처가 같은 내용을 말합니다.

- 파란색은 엔진 오일이 타는 것입니다.
- 검은색은 연료 과다입니다. 공기 부족이나 막힘일 수도 있습니다.
- 흰색은 냉각수입니다.

단, 흰 연기는 시동 직후 얇게 나오는 응결 수증기라면 대개 무해합니다. 두껍고 계속 나오며 단내가 날 때만 냉각수 누출을 의심합니다. 디젤 쪽 출처는 흰 연기를 미연소 연료로 보기도 합니다.

출처:
- https://www.wynns.eu/consumer/exhaust-smoke-colours-explained-what-white-blue-or-black-smoke-means-for-your-engin/
- https://jerry.ai/car-repair/exhaust-smoke/
- https://www.flexautofl.com/post/exhaust-smoke-colors-meaning
- https://highwayandheavyparts.com/blog/diesel-engine-smoke-colors/ (디젤 기준)

검색 한도가 다시 열리면 가격·라이선스, 2번의 Trail·성능·품질 설정, 3번을 이어서 조사할 수 있습니다.

---
## 인용한 출처
- (인용 표시가 없어요)

## 검색에서 본 다른 자료
- [FlipbookMode](https://roblox.fandom.com/wiki/Class:ParticleEmitter/FlipbookMode)
- [ParticleEmitter](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter)
- [ParticleEmitter](https://robloxapi.github.io/ref/class/ParticleEmitter.html)
- [ParticleFlipbookMode](https://robloxapi.github.io/ref/enum/ParticleFlipbookMode.html)
- [creator-docs/content/en-us/effects/particle-emitters.md at main · Roblox/creator-docs · GitHub](https://github.com/Roblox/creator-docs/blob/main/content/en-us/effects/particle-emitters.md)
- [Particle emitters](https://create.roblox.com/docs/effects/particle-emitters)
- [Having some problems creating particles and using Flipbook stuff - Scripting Support - Developer Forum](https://devforum.roblox.com/t/having-some-problems-creating-particles-and-using-flipbook-stuff/2979491)
- [[Client Beta] Optimize your particle animations with custom flipbook layouts - Announcements - Developer Forum](https://devforum.roblox.com/t/client-beta-optimize-your-particle-animations-with-custom-flipbook-layouts/4005128)
- [Roblox Particle Flipbook Maker](https://robloxtutor.net/flipbook-maker)
- [List of properties by category](https://roblox.fandom.com/wiki/List_of_properties_by_category)
- [Particles, beams, and trails all disappearing, not disappearing when supposed to, and causing performance issues - Engine Bugs - Developer Forum](https://devforum.roblox.com/t/particles-beams-and-trails-all-disappearing-not-disappearing-when-supposed-to-and-causing-performance-issues/1584372)
- [Roblox Vfx Skill for Claude Code - Skillselion](https://skillselion.com/skills/nonlooped/roblox-suite/roblox-vfx)
- [Collideable Particles FX [V4.02 cleanup] - Page 5 - Community Resources - Developer Forum](https://devforum.roblox.com/t/collideable-particles-module-self-collisions-update-v32/2279402?page=5)
- [Trail](https://roblox.fandom.com/wiki/Class:Trail)
- [Roblox Particle System Deep Dive: Pro VFX Techniques](https://kitsblox.com/blog/roblox-particle-system-deep-dive)
- [Trail](https://www.qwinkleparticles2.com/guide/particiliary/trail/)
- [UserGameSettings](https://create.roblox.com/docs/reference/engine/classes/UserGameSettings)
- [How to get current graphics level when user uses automatic graphics mode? - Engine Features - Developer Forum](https://devforum.roblox.com/t/how-to-get-current-graphics-level-when-user-uses-automatic-graphics-mode/29170)
- [How do you read what quality settings a player has set if they have automatic on? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-do-you-read-what-quality-settings-a-player-has-set-if-they-have-automatic-on/101291)
- [Reading Graphic Quality - Scripting Support - Developer Forum](https://devforum.roblox.com/t/reading-graphic-quality/1051261)
- [How do i check if a player's graphics quality is lower than 5? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-do-i-check-if-a-players-graphics-quality-is-lower-than-5/2388543)
- [UserGameSettings Reference - Anaminus](https://anaminus.github.io/api/class/UserGameSettings.html)
- [Is this possible to do? - Scripting Support - Developer Forum](https://devforum.roblox.com/t/is-this-possible-to-do/4070950)
- [Checking a user's graphic settings - Scripting Support - Developer Forum](https://devforum.roblox.com/t/checking-a-users-graphic-settings/853989)
- [How to detect a players graphics level then send a notification if lower than 2 - Scripting Support - Developer Forum](https://devforum.roblox.com/t/how-to-detect-a-players-graphics-level-then-send-a-notification-if-lower-than-2/2534448)
- [List of Roblox games](https://en.wikipedia.org/wiki/List_of_Roblox_games)
- [[Plugin] VFX Forge](https://devforum.roblox.com/t/plugin-vfx-forge-an-advanced-custom-vfx-system/3867553)
- [[Plugin] Sine VFX](https://devforum.roblox.com/t/plugin-sine-vfx-a-vfx-plugin-for-roblox-studio-and-library-with-14k-assets/4803771)
- [Advanced VFX Plugin (+library of 10,000+ assets, & add-ons) - Community Resources - Developer Forum](https://devforum.roblox.com/t/advanced-vfx-plugin-library-of-10000-assets-add-ons/3547230)
- [Roblox VFX Forge](https://www.youtube.com/watch?v=mz9wyhawm_c)
- [plugins that i use for roblox vfx - YouTube](https://www.youtube.com/watch?v=JvsytfiY7tU)
- [Roblox VFX Plugin](https://vfxer.pages.dev/plugin)
- [vfx forge](https://zilibobi.itch.io/vfx-forge)
- [nexus motor6d creator](https://thenexusavenger.itch.io/nexus-motor6d-creator)
- [ui tools](https://zilibobi.itch.io/ui-tools)
- [tabbycatleo.itch.io](https://tabbycatleo.itch.io/romixamo)
- [GitHub - VuxSussy/EasyVFX: VFX plugin for Roblox Studio: 42 sharp effects (combat, magic, dark fantasy), a block-based effect creator, and a lightweight client-side runtime. · GitHub](https://github.com/VuxSussy/EasyVFX)
- [Shifty's Particle Emitter Plugin - Community Resources - Developer Forum](https://devforum.roblox.com/t/shiftys-particle-emitter-plugin/2661214)
- [VFX Editor - all your VFX needs, in one - Community Resources - Developer Forum](https://devforum.roblox.com/t/vfx-editor-all-your-vfx-needs-in-one/3103467)
- [🦖 VFX Suite - Creator Store](https://create.roblox.com/store/asset/14328968969/VFX-Suite)

_모델 claude-sonnet-5-5 · effort medium · 검색 8회 · 약 $0.328 · 끝 end_turn_
