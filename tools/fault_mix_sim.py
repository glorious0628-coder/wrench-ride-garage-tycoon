"""Fault-mix study (wr-design, 10-22): a Python port of FaultService.plan / planStars
(src/ServerScriptService/Modules/FaultService.luau + Shared/Faults.luau + Config.luau, 10-22) so the mix of customer faults
can be tried without Studio.  docs/design/fault_mix.md has the findings.

  py tools/fault_mix_sim.py            # current game (as coded) vs bug fixed vs the proposed mix, by level, stars off / on
  py tools/fault_mix_sim.py --extra    # + the three variant lines (BAT_SLOW, PAD_UNEVEN, TIRE_UNEVEN) and Muffler at Lv6

Each cell = the share of cars that carry the most common fault / the share of cars that repeat a fault seen in the last 4 cars.
NOTE (10-22): FaultService.plan's "avoid the variants of the last 2 cars" is broken in the code -- `history.variants = mine`
then appends prevVariants INTO `mine` and stores `mine` as prevVariants, so every car's list grows with all earlier ones and,
after a few cars, no variant is 'fresh' any more.  The sim's memory=0 (no avoiding) reproduces the wr-play DevCall numbers
(notes/playtest/wr-play/fault_mix_dump_1022.md); memory=2 is what the code was meant to do.
Rules ported: kind weights among the open kinds, banned = the last car's main kind, a variant is avoided for the last
`memory` cars, traps (Faults.TrapChance), star shapes (Config.CarStars / StarRules).  Part depth per kind = the longest
`needs` chain + 1 over the parts that exist in PartData/Cars/Sedan.luau (Radiator 3 only with P5 live).
"""
import random, collections, copy, sys


# ---- data (Faults.luau / Config.luau) -----------------------------------------------------------------------------
KIND_W0 = dict(Battery=25, Wheel=25, BrakePads=25, Bumper=10, Radiator=10, Muffler=10, Hood=5)
UNLOCK0 = dict(Battery=1, Wheel=1, BrakePads=2, Bumper=3, Radiator=5, Muffler=10**9, Hood=9)
UNLOCK_E2 = dict(Shock=7, Strut=9, Spring=9)

def V(id, kind, w, minLevel=1, trap=False, gear=None):
    return dict(id=id, kind=kind, w=w, minLevel=minLevel, trap=trap, gear=gear)

VARIANTS0 = [
    V("BAT_DEAD", "Battery", 70), V("BAT_CORROSION", "Battery", 20, 3, True), V("BAT_OLD", "Battery", 10),
    V("TIRE_FLAT", "Wheel", 40), V("TIRE_BALD", "Wheel", 40), V("TIRE_BULGE", "Wheel", 20, 3),
    V("WHEEL_IMBALANCE", "Wheel", 20, gear="WheelBalancer"),
    V("PAD_WORN", "BrakePads", 70), V("PAD_GONE", "BrakePads", 30),
    V("BUMPER_HANGING", "Bumper", 50), V("BODY_SCRATCH_LIGHT", "Bumper", 25, trap=True), V("BODY_SCRATCH_DEEP", "Bumper", 25),
    V("RAD_LEAK", "Radiator", 70), V("RAD_FAN", "Radiator", 30),
    V("MUF_HOLE", "Muffler", 50), V("MUF_HANGER", "Muffler", 35, trap=True), V("MUF_SHIELD", "Muffler", 15),
    V("BODY_DENT", "Hood", 100),
    V("STRUT_LEAK", "Strut", 100), V("SHOCK_LEAK", "Shock", 100), V("SPRING_BROKEN", "Spring", 100),
]
FAULTS_BY_LEVEL = [(5, (1, 1)), (15, (1, 2)), (10**9, (2, 3))]
TRAP = [(2, 0.0), (5, 0.05), (15, 0.10), (10**9, 0.10)]
CAR_STARS = [(2, [100]), (5, [65, 35]), (8, [30, 45, 25]), (12, [15, 35, 35, 15]), (15, [10, 25, 35, 25, 5]), (10**9, [10, 20, 30, 25, 15])]
STAR_RULES = [
    [dict(count=(1, 1), maxDepth=1)],
    [dict(count=(1, 1), maxDepth=2, needDepth=2), dict(count=(2, 2), maxDepth=2)],
    [dict(count=(1, 2), maxDepth=3, needDepth=3), dict(count=(3, 3), maxDepth=2)],
]
RHYTHM = dict(hardInARow=2, sameKindGap=2)
# PartGraph.depth("Sedan", ...) per kind (longest `needs` chain + 1, parts only; Radiator 2 only with P5 live)
DEPTH = dict(Battery=1, Wheel=1, BrakePads=2, Bumper=1, Radiator=1, Muffler=1, Hood=1, Strut=2, Shock=3, Spring=4)


class Sim:
    def __init__(self, level, rng, e2=False, p5=False, balancer=None, kind_w=None, var_w=None, unlock=None, depth_override=None, extra_variants=None, auto=None, memory=2, shape_w=None, bias=None,
                 penalty=None, stars=False, by_level_counts=None):
        self.level, self.rng = level, rng
        self.unlock = dict(UNLOCK0)
        if e2:
            self.unlock.update(UNLOCK_E2)
        if unlock:
            self.unlock.update(unlock)
        self.kind_w = dict(KIND_W0) if kind_w is None else dict(kind_w)
        self.variants = copy.deepcopy(VARIANTS0) + copy.deepcopy(extra_variants or [])
        if var_w:
            for v in self.variants:
                if v["id"] in var_w:
                    v["w"] = var_w[v["id"]]
        self.depth = dict(DEPTH)
        if p5:
            self.depth["Radiator"] = 3  # cover -> upper hose -> radiator (GPT r1)
        if depth_override:
            self.depth.update(depth_override)
        self.shape_w = shape_w  # {star: [weight per shape]} (the game: even)
        self.bias = bias or {}  # season/weather: kind -> weight multiplier (docs/design/calendar_seasons.md)
        self.memory = memory  # variants of the last `memory` cars are avoided (the game: 2)
        self.auto = auto  # dict(per=10, bias={kind: x}) -> kind weight = per x (open non-trap faults of the kind) x bias
        self.balancer = (level >= 6) if balancer is None else balancer
        self.penalty = penalty  # dict(window=6, factor=0.5) -> kind weight x factor^(appearances in the last `window` cars)
        self.stars_on = stars
        self.counts = by_level_counts
        self.h = dict(kinds=[], variants=[], prev=None, stars=[], recent=collections.deque(maxlen=10))

    # ---- helpers
    def weighted(self, items, wf):
        total = sum(wf(i) for i in items)
        if total <= 0:
            return None
        r = self.rng.random() * total
        for it in items:
            r -= wf(it)
            if r <= 0:
                return it
        return items[-1]

    def open_kinds(self):
        return sorted(k for k, at in self.unlock.items() if self.level >= at)

    def kw(self, k):
        if self.auto:
            w = self.auto['per'] * len(self.variants_of(k, False)) * self.auto.get('bias', {}).get(k, 1.0)
        else:
            w = self.kind_w.get(k, 1)
        w = w * self.bias.get(k, 1.0)
        if self.penalty:
            n = sum(1 for kinds in list(self.h["recent"])[-self.penalty.get("window", 10):] if k in kinds)
            w = w * (self.penalty["factor"] ** n)
        return w

    def variants_of(self, kind, trap):
        out = []
        for v in self.variants:
            geared = v["gear"] is None or self.balancer
            if v["kind"] == kind and self.level >= v["minLevel"] and v["trap"] == trap and geared:
                out.append(v)
        return out

    def pick_variant(self, kind, trap, avoid=None):
        allv = self.variants_of(kind, trap)
        if avoid:
            allv = [v for v in allv if v["id"] not in avoid]
        fresh = [v for v in allv if v["id"] not in self.h["variants"]]
        pool = fresh if fresh else allv
        w = lambda v: v["w"] * (1 if not self.penalty else self.penalty.get("vfactor", 1.0) ** sum(
            1 for ids in self.h.get("recent_v", []) if v["id"] in ids))
        return self.weighted(pool, w)

    def kind_depth(self, k):
        return self.depth.get(k, 1)

    # ---- FaultService.plan
    def plan(self, o=None):
        o = o or {}
        level, h = self.level, self.h
        opened = self.open_kinds()
        n = o.get("count")
        if n is None:
            rng_ = next(c for up, c in (self.counts or FAULTS_BY_LEVEL) if level <= up)
            n = self.rng.randint(rng_[0], rng_[1])
        kinds = h["kinds"]
        banned = kinds[-1] if kinds else None
        recent = set()
        if o.get("gap"):
            recent = set(kinds[max(0, len(kinds) - o["gap"]):])
        plan, used = [], set()
        for i in range(1, n + 1):
            choices = [k for k in opened if k != banned and k not in used and self.deep_ok(k, o)
                       and not (i == 1 and k in recent)]
            if i == 1 and o.get("needDepth"):
                deep = [k for k in choices if self.kind_depth(k) >= o["needDepth"]]
                if deep:
                    choices = deep
            if not choices:
                choices = [k for k in opened if k not in used and self.deep_ok(k, o)]
            kind = self.weighted(choices, self.kw)
            if kind is None:
                break
            used.add(kind)
            v = self.pick_variant(kind, False)
            if v:
                plan.append(dict(kind=kind, variant=v["id"]))
        p = next(pp for up, pp in TRAP if level <= up)
        if plan and not o.get("noTrap") and self.rng.random() < p:
            tk = [k for k in opened if self.variants_of(k, True) and (k != banned or len(plan) > 1)]
            kind = self.weighted(tk, self.kw)
            trap = self.pick_variant(kind, True) if kind else None
            if trap:
                i = self.rng.randint(1, len(plan)) - 1
                if kind == banned and len(plan) > 1:
                    i = self.rng.randint(2, len(plan)) - 1
                for j, f in enumerate(plan):
                    if f["kind"] == kind and not (kind == banned and j == 0):
                        i = j
                plan[i] = dict(kind=kind, variant=trap["id"])
        if plan:
            kinds.append(plan[0]["kind"])
            if len(kinds) > 5:
                kinds.pop(0)
            h["recent"].append({f["kind"] for f in plan})
            h.setdefault("recent_v", collections.deque(maxlen=10)).append({f["variant"] for f in plan})
        mine = [f["variant"] for f in plan]
        mem = h.setdefault("mem", collections.deque(maxlen=self.memory))
        mem.append(mine)
        h["variants"] = [v for ids in mem for v in ids]
        h["prev"] = mine
        return plan

    def deep_ok(self, k, o):
        return o.get("maxDepth") is None or self.kind_depth(k) <= o["maxDepth"]

    def stars_of(self, plan):
        deepest = max([self.kind_depth(f["kind"]) for f in plan] or [0])
        n = len(plan)
        if deepest >= 4:
            return 5
        if deepest == 3 or n >= 3:
            return 3
        if deepest == 2 or n == 2:
            return 2
        return 1

    def snapshot(self):
        h = self.h
        return dict(kinds=list(h["kinds"]), variants=list(h["variants"]), prev=None if h["prev"] is None else list(h["prev"]),
                    recent=collections.deque(h["recent"], maxlen=10),
                    recent_v=collections.deque(h.get("recent_v", []), maxlen=10))

    def restore(self, s):
        self.h.update(s)

    def aim(self):
        row = next(w for up, w in CAR_STARS if self.level <= up)
        w = list(row)
        top = len(STAR_RULES)
        while len(w) > top:
            w[top - 1] += w.pop()
        star = self.weighted(list(range(1, len(w) + 1)), lambda s: w[s - 1]) or 1
        st = self.h["stars"]
        hard = len(st) >= RHYTHM["hardInARow"] and all(x >= 3 for x in st[-RHYTHM["hardInARow"]:])
        if hard:
            star = min(star, 2)
        return star

    def plan_stars(self):
        target = self.aim()
        for star in range(target, 0, -1):
            shapes = list(STAR_RULES[star - 1])
            if self.shape_w and star in self.shape_w and len(shapes) > 1:
                w = self.shape_w[star]
                order = []
                pool = list(range(len(shapes)))
                while pool:
                    k = self.weighted(pool, lambda i: w[i])
                    order.append(shapes[k]); pool.remove(k)
                shapes = order
            else:
                self.rng.shuffle(shapes)
            for shape in shapes:
                before = self.snapshot()
                plan = self.plan(dict(noTrap=(star == 1), count=self.rng.randint(*shape["count"]),
                                      maxDepth=shape.get("maxDepth"), needDepth=shape.get("needDepth"), gap=RHYTHM["sameKindGap"]))
                if plan and self.stars_of(plan) == star:
                    return self.done(plan)
                self.restore(before)
        return self.done(self.plan())

    def done(self, plan):
        s = self.stars_of(plan)
        self.h["stars"].append(s)
        if len(self.h["stars"]) > 5:
            self.h["stars"].pop(0)
        return plan, s

    def car(self):
        if self.stars_on:
            return self.plan_stars()
        p = self.plan()
        return p, self.stars_of(p)


def run(level, cars=4000, seed=1, **kw):
    sim = Sim(level, random.Random(seed), **kw)
    for _ in range(40):  # warm up the history
        sim.car()
    per_id, per_kind, stars = collections.Counter(), collections.Counter(), collections.Counter()
    nfaults = 0
    runs = collections.Counter()
    last = None
    for _ in range(cars):
        plan, s = sim.car()
        stars[s] += 1
        nfaults += len(plan)
        for f in plan:
            pass
        for vid in {f["variant"] for f in plan}:
            per_id[vid] += 1
        for k in {f["kind"] for f in plan}:
            per_kind[k] += 1
        main = plan[0]["variant"] if plan else None
        if main == last and main:
            runs["same_main_in_row"] += 1
        last = main
    n = cars
    return dict(level=level, ids={k: v / n for k, v in per_id.items()}, kinds={k: v / n for k, v in per_kind.items()},
                stars={k: stars[k] / n for k in sorted(stars)}, faults=nfaults / n, rep=runs["same_main_in_row"] / n)


def show(r, title=""):
    ids = sorted(r["ids"].items(), key=lambda kv: -kv[1])
    top = ", ".join(f"{k} {v*100:.0f}%" for k, v in ids[:6])
    st = "/".join(f"{r['stars'].get(s,0)*100:.0f}" for s in (1, 2, 3, 4, 5))
    print(f"Lv{r['level']:>2} {title:<10} faults/car {r['faults']:.2f} ★ {st:<14} max id {ids[0][0]} {ids[0][1]*100:.0f}% | {top}")




def show(r, title=""):
    ids = sorted(r["ids"].items(), key=lambda kv: -kv[1])
    st = "/".join(f"{r['stars'].get(s,0)*100:.0f}" for s in (1, 2, 3, 4, 5))
    print(f"Lv{r['level']:>2} {title:<10} faults/car {r['faults']:.2f}  stars {st:<12} max {ids[0][0]} {ids[0][1]*100:.0f}%")


FLAT_VAR = dict(BAT_DEAD=50, BAT_OLD=50, TIRE_FLAT=25, TIRE_BALD=25, TIRE_BULGE=25, WHEEL_IMBALANCE=25,
                PAD_WORN=50, PAD_GONE=50, BUMPER_HANGING=50, BODY_SCRATCH_DEEP=50, RAD_LEAK=50, RAD_FAN=50,
                MUF_HOLE=50, MUF_SHIELD=50)
EXTRA = [V("BAT_SLOW", "Battery", 50), V("PAD_UNEVEN", "BrakePads", 50), V("TIRE_UNEVEN", "Wheel", 25, 3)]
AUTO = dict(per=10, bias=dict(Strut=0.8, Spring=0.8))  # kind weight = 10 x open non-trap faults of the kind (Strut/Spring x0.8)


def study(level, cars=5000, seed=5, **kw):
    sim = Sim(level, random.Random(seed), **kw)
    for _ in range(40):
        sim.car()
    ids, win, rep, nf = collections.Counter(), collections.deque(maxlen=4), 0, 0
    kwin, krep = collections.deque(maxlen=2), 0
    for _ in range(cars):
        plan, _s = sim.car()
        cur = {f["variant"] for f in plan}
        if any(c & cur for c in win):
            rep += 1
        win.append(cur)
        kcur = {f["kind"] for f in plan}
        if any(c & kcur for c in kwin):
            krep += 1
        kwin.append(kcur)
        nf += len(plan)
        for v in cur:
            ids[v] += 1
    top = ids.most_common(1)[0]
    return dict(faults=nf / cars, top=top[0], share=top[1] / cars, rep=rep / cars, krep=krep / cars)


if __name__ == "__main__":
    extra = "--extra" in sys.argv
    cases = {"current game (as coded: no avoiding)": dict(memory=0), "bug fixed only (last 2 cars)": dict(memory=2)}
    prop = dict(auto=AUTO, var_w=dict(FLAT_VAR), depth_override=dict(Spring=3), memory=4)
    if extra:
        prop = dict(prop, var_w=dict(FLAT_VAR, BAT_SLOW=50, PAD_UNEVEN=50, TIRE_UNEVEN=25), extra_variants=EXTRA)
        prop["unlock"] = dict(Muffler=6)
    cases["proposed" + (" +variants +muffler Lv6" if extra else "")] = prop
    for stars in (False, True):
        print(f"##### stars {'ON' if stars else 'off'}  (cell = most common fault / same fault in last 4 cars / same part kind in last 3 cars)")
        for name, cfg in cases.items():
            row = []
            for lv in (3, 4, 5, 6, 7, 9, 12, 16):
                r = study(lv, stars=stars, e2=(lv >= 7), **cfg)
                row.append(f"Lv{lv}:{r['share']*100:>3.0f}/{r['rep']*100:>2.0f}/{r['krep']*100:>2.0f}")
            print(f"{name:<38}", "  ".join(row))
