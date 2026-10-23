--!strict
-- Garage-name blocklist (our extra layer on top of Roblox's TextService filter — docs/design/name_filter.md).
-- Server-only: this ModuleScript lives in ServerScriptService, which never replicates to clients.
-- Every entry is compared AFTER normalize() (name_filter.md §3): lower-case, spaces / symbols / emoji removed,
-- leet digits mapped (1->i, 0->o, 3->e, 4->a, 5->s, 7->t, 8->b, $->s, @->a), repeated letters squashed to one,
-- digits / latin letters stuck between Hangul removed. Write entries already normalized (no spaces, one letter per run).
-- substring: blocked if it appears anywhere (long enough not to hit normal words).
-- word:      blocked only as a whole latin token in the raw name (short words that live inside normal words).
-- jamo:      blocked if the raw name's typed bare jamo (ㄱ~ㅣ, not full syllables) contain it in order.
-- allow:     normal phrases removed before checking (false-positive guards). Add to this list when a real name trips.
-- Keep the list in this file only — never paste it into docs or board.md (name_filter.md).

return {
	substring = {
		-- Korean profanity (variants)
		"시발", "씨발", "씨빨", "씨팔", "시팔", "쓰발", "씌발", "시벌", "씨벌", "싸발", "ㅆ발",
		"개새", "개색", "개세끼", "새끼", "색히", "섀끼",
		"병신", "븅신", "빙신", "벙신", "등신",
		"좆", "존나", "졸라", "지랄", "염병", "옘병", "엠창", "엿먹", "꺼져", "닥쳐",
		"미친놈", "미친년", "또라이", "똘아이", "개같", "개좆", "좇같",
		-- insults about parents (패드립)
		"니애미", "니엄마", "니앰", "느금", "느그엄", "니미", "애미", "애비", "엄창", "니아빠", "느개비",
		-- sexual
		"섹스", "쎅스", "보지", "자지", "꼬추", "젖가슴", "야동", "강간", "윤간",
		-- misogyny / misandry
		"김치녀", "된장녀", "보슬아치", "걸레년", "창녀", "삼일한", "맘충",
		"김치남", "한남충", "냄저", "재기해",
		-- hate communities / memes
		"일베", "메갈", "워마드", "운지", "노무현", "엠씨무현",
		-- racism / ethnic slurs
		"깜둥", "짱깨", "짱께", "쪽바리", "쪽발", "조센징", "똥남아", "니거",
		-- disability slurs
		"애자", "찐따", "장애새",
		-- English profanity / sexual
		"fuck", "fuk", "fck", "shit", "bitch", "biatch", "cunt", "dick", "cock", "pussy", "whore", "slut",
		"porn", "penis", "vagina", "boob", "titty", "dildo", "blowjob", "handjob", "horny", "orgasm", "rape",
		"motherfuck", "bastard", "jackass", "dumbass", "asshole",
		-- English parent insults
		"yourmom", "yomama", "urmom",
		-- English hate / slurs
		"niger", "nigga", "nigr", "faget", "fagot", "retard", "chink", "kike", "wetback", "tranny", "spic",
		"nazi", "hitler", "heil", "kkk", "whitepower", "siegheil",
	},
	word = {
		"ass", "fag", "fags", "cum", "tit", "tits", "sex", "gook", "coon", "jap", "spaz", "hoe", "hoes",
		"wtf", "stfu", "kys",
	},
	jamo = {
		"ㅅㅂ", "ㅆㅂ", "ㅄ", "ㅂㅅ", "ㅈㄹ", "ㅈㄴ", "ㄱㅅㄲ", "ㅅㄲ", "ㅁㅊ", "ㄴㄱㅁ", "ㅇㅁ", "ㅗ",
	},
	allow = {
		-- normal words that contain a blocked piece
		"시발점", "시발역", "새끼고양이", "새끼강아지", "새끼손가락", "애자일", "애비뉴",
		"보지마", "보지말", "보지도", "보지않", "자지마", "자지말", "자지않",
		-- (written normalized: no spaces, repeated letters squashed — "shiitake" -> "shitake")
		"scunthorpe", "cockpit", "cocktail", "peacock", "hancock", "dickens", "dickson", "shitake",
		"spice", "spick", "therapist", "grape", "drape", "scrape", "trapeze", "skyscraper", "nigeria", "nigeriver",
	},
}
