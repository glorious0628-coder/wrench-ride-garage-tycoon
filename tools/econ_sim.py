"""Wrench & Ride economy simulation (numbers only, no plots) — wr-design.

  py tools/econ_sim.py [--players 1] [--runs 200] [--seed 1] [--hours 20] [--md out.md]

Plays the garage job by job with the numbers from docs/design/economy.md v0.2, alpha_scope.md v0.3 and
flip_loop.md v0.2 (all copied into the CONFIG block below, so the report says which numbers it used).
Each job: faults from FaultsByLevel, time from the tools owned, rep / cash from the payout rules, a customer mood
roll for the tip. The player buys every unlocked upgrade in a fixed priority as soon as it's affordable, and once the
Restoration Bay is owned spends about one job-slot in three on a junkyard flip. Co-op: the team shares the owner's
garage (cars at once capped by the alpha_scope table), each car with k players goes k**0.75 times faster, helpers
get CoopShare of labor + tips. Prints: time to each level, cash per hour per player by level band, loop A / B share,
when each purchase happens, and flags (a level that takes too long / too short, cash piling up unused).
"""
import argparse
import random
import statistics

# ---------------- numbers from the design docs ----------------
CONFIG = {
    "levels": [0, 12, 34, 80, 120, 230, 400, 620, 850, 1100, 1400, 1750, 2100, 2500, 2950, 3500],  # economy §1-2
    "rep": {"fault": 10, "spot": 3, "fast": 2, "flip": (30, 120)},  # economy §1-1
    "faults": [(5, 1, 1), (15, 1, 2), (99, 2, 3)],  # FaultsByLevel (up to level, min, max)
    "hidden_fault": (6, 0.10, 0.7),  # alpha_scope §2-4: from Lv6, 10% of cars, customer says yes 70%
    "labor": [(5, 120), (15, 160), (99, 200)],  # economy §1-3 LaborByLevel
    "markup": 0.3,  # parts x 1.3 -> 30% of the part price is profit
    "part_price": {"Battery": 90, "Wheel": 140, "BrakePads": 45, "Bumper": 160, "Radiator": 220, "Muffler": 150, "Hood": 260},
    "kind_weight": {"Battery": 25, "Wheel": 25, "BrakePads": 25, "Bumper": 10, "Radiator": 10, "Muffler": 10, "Hood": 5},
    "kind_unlock": {"Battery": 1, "Wheel": 1, "BrakePads": 2, "Bumper": 3, "Radiator": 5, "Muffler": "HydraulicLift", "Hood": 9},
    "first_job_bonus": 150,
    "start_money": 600,
    "spot_on": (0.80, 0.15),  # chance a job is Spot On, cash bonus = 15% of labor
    # tips (alpha_scope §1-1): mood -> (chance, regular tip, hurry tip); hurry customers 20% from Lv2
    "mood": {"Calm": (0.78, 80, 160), "Restless": (0.17, 40, 60), "Upset": (0.05, 0, 0)},
    "hurry": (2, 0.20),
    # job time in minutes (one player, one fault, Lv1 tools): diagnose + buy + swap + hand back, plus extra per fault
    "job_min": 5.0, "extra_fault_min": 2.6, "between_jobs_min": {1: 0.7, 2: 0.15},  # bays owned -> idle between cars
    "speedups": {"Ratchet": 0.92, "ImpactWrench": 0.85, "HydraulicLift": 0.95, "OBDReader": 0.95, "BatteryTester": 0.97},
    # upgrades: name -> (level, price)   (economy §1-2 + alpha_scope §3); buy order = this order
    "upgrades": [
        ("BatteryTester", 2, 250), ("Ratchet", 3, 500), ("PartsShelf", 3, 400), ("Bay2", 4, 1000), ("WheelBalancer", 5, 1200),
        ("HydraulicLift", 6, 2400), ("ImpactWrench", 6, 1800), ("OBDReader", 6, 2500), ("Stethoscope", 6, 400),
        ("TireChanger", 7, 2200), ("RestorationBay", 8, 3500), ("PressureTester", 8, 900), ("Washer", 9, 1500),
        ("Bay3", 10, 5000), ("SpringCompressor", 11, 2500), ("Sander", 12, 4000), ("EngineCrane", 13, 7500),
        ("CarCarrier", 14, 8000), ("AIMechanic", 15, 3000), ("Bay4", 16, 15000), ("PaintBooth", 16, 20000),
        ("Alignment", 16, 12000), ("Dyno", 16, 15000),
    ],
    # loop B (flip_loop §6): minutes, profit, share of time once the Restoration Bay is owned
    "flip": {"minutes": 40, "profit_instant": 1505, "profit_showroom": 1950, "showroom_level": 9, "every_n_jobs": 7},
    # co-op (alpha_scope §1-4 cars at once; economy §3 CoopShare; helpers' own garage gets 50% rep)
    "coop_share": [1.0, 0.7, 0.55, 0.45],
    "coop_cap": lambda lv, n: (2 if n <= 2 else (2 if lv <= 2 else 3 if lv <= 5 else 4)) if n > 1 else None,
    "coop_speed_exp": 0.75,
    # v2 (GPT econsim_r1): mood from real time, traps, flips by grade/title
    "patience": {"regular": (7.0, 11.0), "hurry": (5.0, 8.0)},  # minutes: end of Calm, end of Restless (alpha_scope 420/660 s, 300/480 s)
    "kid_speed_sigma": 0.35,  # each job takes job time x lognormal(0, sigma) — kids differ
    "trap_rate": [(2, 0.0), (5, 0.05), (99, 0.10)],  # alpha_scope §2-4: a trap fault needs no new part
    "grades": {"Bronze": (0.25, 0.70), "Silver": (0.55, 0.86), "Gold": (0.20, 0.97)},  # share, restored condition
    "grade_rep": {"Bronze": 15, "Silver": 25, "Gold": 40},  # code Config.FlipRep today
    "titles": {"Clean": (0.70, 700, 1.0), "Salvage": (0.30, 420, 0.65)},  # share, buy price, value x
    "team_bonus": 0.0,  # extra labor + tips when 2+ players share a car (GPT econsim_r1 idea)
    "market": 4200, "flip_parts": 550, "haggle_bonus": 0.04, "instant_x": 0.8, "flip_speed_players_max": 2,
}


def faults_for(level, rng):
    for up, lo, hi in CONFIG["faults"]:
        if level <= up:
            return rng.randint(lo, hi)


def labor_for(level):
    for up, l in CONFIG["labor"]:
        if level <= up:
            return l


def level_of(rep):
    lv = 1
    for i, need in enumerate(CONFIG["levels"]):
        if rep >= need:
            lv = i + 1
    if rep >= CONFIG["levels"][-1]:
        lv = 16 + int((rep - CONFIG["levels"][-1]) // 900)
    return lv


def part_price(level, owned, rng):
    kinds = [k for k, u in CONFIG["kind_unlock"].items() if (u in owned if isinstance(u, str) else level >= u)]
    w = [CONFIG["kind_weight"][k] for k in kinds]
    return CONFIG["part_price"][rng.choices(kinds, w)[0]]


def run(players, hours, rng):
    t = 0.0  # minutes of play
    rep = 0
    cash = [CONFIG["start_money"]] + [0] * (players - 1)  # owner's cash, helpers' cash (only the owner buys)
    helper_rep = 0
    owned = set()
    level_time = {1: 0.0}
    bought = {}
    earned_a = earned_b = 0.0
    jobs = 0
    first = True
    band_cash = {}  # band -> [cash per player, minutes]
    flipped = set()
    b_min = 0.0
    b_cash = 0.0
    last_lv = 1
    while t < hours * 60:
        lv = level_of(rep)
        for L in range(last_lv + 1, lv + 1):
            level_time[L] = t
        last_lv = max(last_lv, lv)
        bays = 1 + sum(b in owned for b in ("Bay2", "Bay3", "Bay4"))
        # spend: buy unlocked upgrades in order
        for name, need, price in CONFIG["upgrades"]:
            if name not in owned and lv >= need and cash[0] >= price:
                cash[0] -= price
                owned.add(name)
                bought[name] = t
        band = "Lv1-5" if lv <= 5 else ("Lv6-15" if lv <= 15 else "Lv16+")
        bc = band_cash.setdefault(band, [0.0, 0.0])
        # loop B: one flip every N customer jobs once the Restoration Bay is owned
        if "RestorationBay" in owned and jobs and jobs % CONFIG["flip"]["every_n_jobs"] == 0 and jobs not in flipped:
            flipped.add(jobs)
            f = CONFIG["flip"]
            g = rng.choices(list(CONFIG["grades"]), [v[0] for v in CONFIG["grades"].values()])[0]
            tname = rng.choices(list(CONFIG["titles"]), [v[0] for v in CONFIG["titles"].values()])[0]
            _, buy, tx = CONFIG["titles"][tname]
            value = CONFIG["market"] * CONFIG["grades"][g][1] * tx
            sale = value * (1 + CONFIG["haggle_bonus"]) if lv >= f["showroom_level"] else value * CONFIG["instant_x"]
            profit = sale - buy - CONFIG["flip_parts"]
            mins = f["minutes"] * rng.lognormvariate(0, CONFIG["kid_speed_sigma"] * 0.5) / (min(players, CONFIG["flip_speed_players_max"]) ** CONFIG["coop_speed_exp"])
            share = [0.55, 0.15, 0.15, 0.15] if players == 4 else [0.6, 0.2, 0.2] if players == 3 else [0.7, 0.3] if players == 2 else [1.0]
            for i in range(players):
                cash[i] += profit * share[i]
            r = CONFIG["grade_rep"][g]
            rep += r
            helper_rep += r * 0.5 * (players - 1)
            earned_b += profit
            b_min += mins * min(players, CONFIG["flip_speed_players_max"]) / players
            b_cash += profit / players
            team_min = mins * min(players, CONFIG["flip_speed_players_max"]) / players  # the rest keep doing customer cars
            bc[0] += profit / players
            bc[1] += team_min
            t += team_min
            continue
        # one 'round': the team works on up to `cars` cars at once
        # solo: one car at a time (a 2nd bay only cuts the wait between cars); co-op: up to `cap` cars side by side
        cars = 1 if players == 1 else max(1, min(CONFIG["coop_cap"](lv, players), max(bays, players), players))
        per_car = [players // cars + (1 if i < players % cars else 0) for i in range(cars)]
        round_min = 0.0
        for car_i, k in enumerate(per_car):
            n_f = faults_for(lv, rng)
            hf = CONFIG["hidden_fault"]
            if lv >= hf[0] and n_f == 1 and rng.random() < hf[1] and rng.random() < hf[2]:
                n_f += 1
            mins = CONFIG["job_min"] + CONFIG["extra_fault_min"] * (n_f - 1)
            for tool, m in CONFIG["speedups"].items():
                if tool in owned:
                    mins *= m
            mins /= k ** CONFIG["coop_speed_exp"]
            mins *= rng.lognormvariate(0, CONFIG["kid_speed_sigma"])
            labor = labor_for(lv) * n_f
            trap_p = next(p for up, p in CONFIG["trap_rate"] if lv <= up)
            n_parts = sum(0 if rng.random() < trap_p else 1 for _ in range(n_f))
            parts = sum(part_price(lv, owned, rng) for _ in range(n_parts)) * CONFIG["markup"]
            spot = rng.random() < CONFIG["spot_on"][0]
            hurry = lv >= CONFIG["hurry"][0] and rng.random() < CONFIG["hurry"][1]
            calm_end, rest_end = CONFIG["patience"]["hurry" if hurry else "regular"]
            mood = "Calm" if (first or mins <= calm_end) else ("Restless" if mins <= rest_end else "Upset")
            tip = CONFIG["mood"][mood][2 if hurry else 1]
            bonus = (labor * CONFIG["spot_on"][1] if spot else 0) + (CONFIG["first_job_bonus"] if first else 0)
            first = False
            share = CONFIG["coop_share"][min(k, 4) - 1]
            team_pay = (labor + tip + bonus) * share * (1 + CONFIG["team_bonus"] if k >= 2 else 1)
            # the k players on this car: the owner if on it, helpers otherwise — spread over the team evenly
            for i in range(players):
                cash[i] += team_pay * k / players
            cash[0] += parts
            r = CONFIG["rep"]["fault"] * n_f + (CONFIG["rep"]["spot"] if spot else 0) + (CONFIG["rep"]["fast"] if mood == "Calm" else 0)
            rep += r
            helper_rep += r * 0.5 * (k - (1 if car_i == 0 else 0))  # every helper on this car banks 50% at home
            earned_a += labor + tip + bonus + parts
            bc[0] += (team_pay * k + parts) / players
            jobs += 1
            round_min += mins / len(per_car)  # cars run side by side, each on its own clock (no waiting for the slowest)
        round_min += CONFIG["between_jobs_min"][2 if bays >= 2 else 1]
        bc[1] += round_min
        t += round_min
    return {"level_time": level_time, "bought": bought, "a": earned_a, "b": earned_b, "band": band_cash, "cash_left": cash[0], "helper_rep": helper_rep, "b_rate": (b_cash / (b_min / 60)) if b_min else None}


def fmt(m):
    return f"{int(m // 60)}h {int(m % 60):02d}m" if m is not None else "—"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--players", type=int, default=1)
    ap.add_argument("--runs", type=int, default=200)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--hours", type=float, default=20)
    ap.add_argument("--flip-rep", default=None, help="min,max rep per flip (default from CONFIG)")
    ap.add_argument("--grade-rep", default=None, help="Bronze,Silver,Gold rep per flip")
    ap.add_argument("--market", type=float, default=None, help="restored plain sedan value")
    ap.add_argument("--team-bonus", type=float, default=None)
    a = ap.parse_args()
    rng = random.Random(a.seed)
    if a.flip_rep:
        CONFIG["rep"]["flip"] = tuple(int(x) for x in a.flip_rep.split(","))
    if a.grade_rep:
        CONFIG["grade_rep"] = dict(zip(("Bronze", "Silver", "Gold"), (int(x) for x in a.grade_rep.split(","))))
    if a.team_bonus is not None:
        CONFIG["team_bonus"] = a.team_bonus
    if a.market:
        CONFIG["market"] = a.market
    res = [run(a.players, a.hours, rng) for _ in range(a.runs)]
    print(f"## players = {a.players}, runs = {a.runs}, {a.hours} h each")
    print("| Lv | median time | 10%-90% | gap from previous |")
    print("|---|---|---|---|")
    prev = 0.0
    for L in range(2, 21):
        ts = [r["level_time"].get(L) for r in res if r["level_time"].get(L) is not None]
        if len(ts) < a.runs * 0.5:
            break
        med = statistics.median(ts)
        q = statistics.quantiles(ts, n=10)
        print(f"| {L} | {fmt(med)} | {fmt(q[0])} ~ {fmt(q[-1])} | {fmt(med - prev)} |")
        prev = med
    print("\n| band | cash per hour per player (median) |")
    print("|---|---|")
    for band in ("Lv1-5", "Lv6-15", "Lv16+"):
        v = [r["band"][band][0] / (r["band"][band][1] / 60) for r in res if band in r["band"] and r["band"][band][1] > 0]
        if v:
            print(f"| {band} | ${statistics.median(v):,.0f} |")
    fl = [r["b_rate"] for r in res if r.get("b_rate")]
    if fl:
        print(f"loop B money per hour per player while flipping (median): ${statistics.median(fl):,.0f}")
    share_b = statistics.median([r["b"] / (r["a"] + r["b"]) for r in res if r["a"] + r["b"] > 0])
    print(f"\nloop B share of all money earned (customers = loop A): {share_b:.0%}")
    print("\n| purchase | median time bought |")
    print("|---|---|")
    for name, _, price in CONFIG["upgrades"]:
        ts = [r["bought"][name] for r in res if name in r["bought"]]
        if len(ts) >= a.runs * 0.5:
            print(f"| {name} (${price:,}) | {fmt(statistics.median(ts))} |")
    print(f"\nowner cash left unspent at the end (median): ${statistics.median([r['cash_left'] for r in res]):,.0f}")
    if a.players > 1:
        print(f"each helper's own-garage rep earned (median): {statistics.median([r['helper_rep'] for r in res]) / (a.players - 1):,.0f}")


if __name__ == "__main__":
    main()
