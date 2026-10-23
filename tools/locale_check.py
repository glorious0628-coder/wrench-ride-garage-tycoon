"""Which Locale.en keys have no Korean yet (and Korean keys English doesn't have).

    py -I tools/locale_check.py          # list missing keys
    py -I tools/locale_check.py --count  # just the numbers

English source: src/ReplicatedStorage/Shared/Locale.luau (Locale.en). Korean: src/ReplicatedStorage/Shared/LocaleKo.luau.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent / "src" / "ReplicatedStorage" / "Shared"
KEY = re.compile(r'^\s*\["([^"]+)"\]\s*=', re.M)


def en_keys() -> list[str]:
    text = (ROOT / "Locale.luau").read_text(encoding="utf-8")
    start = text.index("Locale.en = {")
    end = text.index("\n}\n", start)
    return KEY.findall(text[start:end])


def ko_keys() -> list[str]:
    return KEY.findall((ROOT / "LocaleKo.luau").read_text(encoding="utf-8"))


def main() -> None:
    en, ko = en_keys(), ko_keys()
    missing = [k for k in en if k not in set(ko)]
    extra = [k for k in ko if k not in set(en)]
    if "--count" not in sys.argv:
        for k in missing:
            print(k)
        if extra:
            print("\n# in Korean but not in English (typo or removed key):")
            for k in extra:
                print(k)
    print(f"\nEnglish {len(en)} keys, Korean {len(ko)} - missing {len(missing)}, extra {len(extra)}", file=sys.stderr)


if __name__ == "__main__":
    main()
