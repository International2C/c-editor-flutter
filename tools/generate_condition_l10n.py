#!/usr/bin/env python3
"""Generate plantCondition_* / zombieCondition_* keys in resource_*.json."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONDITIONS_PATH = ROOT / "conditions.txt"
RESOURCE_DIR = ROOT / "assets/l10n"

PLANT_CONDITION_IDS = ("icecubed", "chill", "shadowboosted", "shroomboosted")
CONDITION_EN: dict[str, str] = {
    "chill": "Chill (slow)",
    "freeze": "Frozen",
    "stun": "Stunned",
    "butter": "Butter",
    "butter9": "Buttercup tier-5 butter",
    "numb": "Numb (Electric Peashooter satellite)",
    "stucked": "Paralyzed",
    "bleeding": "Critical low HP",
    "lightning": "Lightning aura (VFX)",
    "rush": "Rush",
    "speedup1": "1.25× speed",
    "speedup2": "1.5× speed",
    "speedup3": "2× speed",
    "speedup4": "2.5× speed",
    "tossed": "Airborne (knocked up)",
    "potionspeed1": "Orange potion 1.5× speed",
    "potionspeed2": "Orange potion 2× speed",
    "potionspeed3": "Orange potion 2.5× speed",
    "potiontoughness1": "Pink potion 15% damage reduction",
    "potiontoughness2": "Pink potion 30% damage reduction",
    "potiontoughness3": "Pink potion 45% damage reduction",
    "potioninvisible": "Potion invisibility / burglar stealth",
    "potionpoison": "Potion poison",
    "potionsuper1": "Treadmill heart 15% DR and 1.5× speed",
    "potionsuper2": "Treadmill heart 30% DR and 2× speed",
    "potionsuper3": "Treadmill heart 45% DR and 2.5× speed",
    "buffattack": "Zomboss tile 1.5× attack",
    "buffspeed": "Zomboss tile 2× speed",
    "fogshieldlvl1": "Fairy forest 25% DR white fog",
    "fogshieldlvl2": "Fairy forest 50% DR blue fog",
    "fogshieldlvl3": "Fairy forest 75% DR purple fog",
    "hypnotized": "Hypnotized (VFX)",
    "sunbeaned": "Sun Bean aura (VFX)",
    "morphedtogargantuar": "Enlarged (VFX)",
    "damageflash": "Hit flash (VFX)",
    "zombossstun": "Zomboss stun",
    "haunted": "Haunted (Ghost Pepper VFX)",
    "icecubed": "Ice cubed",
    "shadowboosted": "Shadow boosted",
    "shroomboosted": "Shroom boosted",
    "present_boxed": "Gift boxed",
    "sapped": "Sap slow",
    "unsuspendable": "Unknown",
    "stalled": "Stallia slow",
    "slowdown": "Olive pit oil slow",
    "invincible": "Invincible",
    "warpingIn": "Warping in (Thyme Warp VFX)",
    "warpingOut": "Warping out (Thyme Warp VFX)",
    "poisoned": "Shadow-shroom poison",
    "shadowpoisoned": "Poisoned in shadow state",
    "chemist_poison": "Chemist poison",
    "contagiouspoison": "Contagious poison",
    "chemist_contagiouspoison": "Chemist contagious poison",
    "lotus_poison": "Lotus wastewater poison",
    "venom": "Chemist venom pool poison",
    "eagleclawLock": "Eagleclaw lock",
    "shrinking": "Shrinking (Violet)",
    "shrunken": "Shrunken (Violet)",
    "onfire": "Burning",
    "bloomingheartdebuff": "Blooming Heart debuff",
    "ghostlantern": "Ghost Lantern tier-5 possession",
    "negative": "Lightning gun negative charge",
    "positive": "Lightning gun positive charge",
    "dripwater": "Water gun wet",
    "water": "Sea Pea buff",
    "hasplantfood": "Carrying Plant Food",
    "gummed": "Gummed (Eucalypt)",
    "stackableslow": "Stackable slow",
    "cardgame_shield": "Elite healer / card game shield",
    "icebound": "Icebound (white radish)",
    "dazeystunned": "Dazed stun",
}

CONDITION_RU: dict[str, str] = {
    "chill": "Замедление (холод)",
    "freeze": "Заморожен",
    "stun": "Оглушение",
    "butter": "Масло",
    "butter9": "Масло Buttercup 5 ранг",
    "numb": "Онемение (спутник электrogoroha)",
    "stucked": "Паралич",
    "bleeding": "Критически низкое HP",
    "lightning": "Электрическая аура (VFX)",
    "rush": "Рывок",
    "speedup1": "Ускорение ×1.25",
    "speedup2": "Ускорение ×1.5",
    "speedup3": "Ускорение ×2",
    "speedup4": "Ускорение ×2.5",
    "tossed": "В воздухе (подброшен)",
    "potionspeed1": "Оранжевое зелье ×1.5 скорости",
    "potionspeed2": "Оранжевое зелье ×2 скорости",
    "potionspeed3": "Оранжевое зелье ×2.5 скорости",
    "potiontoughness1": "Розовое зелье 15% сопр. урона",
    "potiontoughness2": "Розовое зелье 30% сопр. урона",
    "potiontoughness3": "Розовое зелье 45% сопр. урона",
    "potioninvisible": "Невидимость зелья / вор",
    "potionpoison": "Яд зелья",
    "potionsuper1": "Сердце беговой дорожки 15% СУ и ×1.5 скорости",
    "potionsuper2": "Сердце беговой дорожки 30% СУ и ×2 скорости",
    "potionsuper3": "Сердце беговой дорожки 45% СУ и ×2.5 скорости",
    "buffattack": "Плитка Zomboss ×1.5 атаки",
    "buffspeed": "Плитка Zomboss ×2 скорости",
    "fogshieldlvl1": "Сказочный лес 25% СУ белый туман",
    "fogshieldlvl2": "Сказочный лес 50% СУ синий туман",
    "fogshieldlvl3": "Сказочный лес 75% СУ фиолетовый туман",
    "hypnotized": "Гипноз (VFX)",
    "sunbeaned": "Аура Sun Bean (VFX)",
    "morphedtogargantuar": "Увеличение (VFX)",
    "damageflash": "Вспышка при ударе (VFX)",
    "zombossstun": "Оглушение Zomboss",
    "haunted": "Преследование (Ghost Pepper VFX)",
    "icecubed": "Заморожен в льду",
    "shadowboosted": "Теневое усиление",
    "shroomboosted": "Усиление грибом-стражем",
    "present_boxed": "Упакован в подарок",
    "sapped": "Замедление смолой",
    "unsuspendable": "Неизвестно",
    "stalled": "Замедление Stallia",
    "slowdown": "Замедление маслом Olive Pit",
    "invincible": "Неуязвимость",
    "warpingIn": "Телепортация вход (Thyme Warp VFX)",
    "warpingOut": "Телепортация выход (Thyme Warp VFX)",
    "poisoned": "Яд Shadow-shroom",
    "shadowpoisoned": "Яд в теневом состоянии",
    "chemist_poison": "Яд химика",
    "contagiouspoison": "Заразный яд",
    "chemist_contagiouspoison": "Заразный яд химика",
    "lotus_poison": "Яд лотосовых стоков",
    "venom": "Яд от лужи химика",
    "eagleclawLock": "Блокировка Eagleclaw",
    "shrinking": "Уменьшение (Violet)",
    "shrunken": "Уменьшен (Violet)",
    "onfire": "Горение",
    "bloomingheartdebuff": "Дебафф Blooming Heart",
    "ghostlantern": "Вселение Ghost Lantern 5 ранг",
    "negative": "Отрицательный заряд молнии",
    "positive": "Положительный заряд молнии",
    "dripwater": "Увлажнение водяным пистолетом",
    "water": "Бафф Sea Pea",
    "hasplantfood": "Несёт Plant Food",
    "gummed": "Приклеен (Eucalypt)",
    "stackableslow": "Накапливаемое замедление",
    "cardgame_shield": "Щит элитного лекаря / карточная игра",
    "icebound": "Ледяная связь (white radish)",
    "dazeystunned": "Оглушение Dazey",
}


def parse_conditions_zh() -> dict[str, str]:
    out: dict[str, str] = {"dazeystunned": "眩晕"}
    if not CONDITIONS_PATH.is_file():
        return out
    for line in CONDITIONS_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        cond_id = parts[-1]
        label = " ".join(parts[:-1])
        out[cond_id] = label
    return out


def label_for(locale: str, cid: str, zh: dict[str, str]) -> str:
    if locale == "zh":
        return zh.get(cid, CONDITION_EN.get(cid, cid))
    if locale == "ru":
        return CONDITION_RU.get(cid, CONDITION_EN.get(cid, cid))
    return CONDITION_EN.get(cid, cid)


def build_zombie_entries(locale: str) -> dict[str, str]:
    zh = parse_conditions_zh()
    entries: dict[str, str] = {}
    ids = sorted(set(zh) | set(CONDITION_EN))
    for cid in ids:
        entries[f"zombieCondition_{cid}"] = label_for(locale, cid, zh)
    return entries


def build_plant_entries(locale: str) -> dict[str, str]:
    zh = parse_conditions_zh()
    return {
        f"plantCondition_{cid}": label_for(locale, cid, zh)
        for cid in PLANT_CONDITION_IDS
    }


def load_json(path: Path) -> dict[str, str]:
    with path.open(encoding="utf-8") as f:
        return {str(k): str(v) for k, v in json.load(f).items()}


def save_json(path: Path, data: dict[str, str]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(dict(sorted(data.items(), key=lambda x: x[0].lower())), f, ensure_ascii=False, indent=2)
        f.write("\n")


def migrate_locale(path: Path, locale: str) -> tuple[int, int]:
    existing = load_json(path)
    removed = 0
    updated = 0

    # Prefer existing condition_* translations over legacy zombieCondition_*.
    for key, value in list(existing.items()):
        if key.startswith("condition_"):
            cid = key.removeprefix("condition_")
            zombie_key = f"zombieCondition_{cid}"
            if existing.get(zombie_key) != value:
                existing[zombie_key] = value
                updated += 1
            del existing[key]
            removed += 1

    for cid in PLANT_CONDITION_IDS:
        plant_key = f"plantCondition_{cid}"
        zombie_key = f"zombieCondition_{cid}"
        if zombie_key in existing and plant_key not in existing:
            existing[plant_key] = existing[zombie_key]
            updated += 1

    for key, value in build_zombie_entries(locale).items():
        if key not in existing:
            existing[key] = value
            updated += 1

    for key, value in build_plant_entries(locale).items():
        if key not in existing:
            existing[key] = value
            updated += 1

    save_json(path, existing)
    return removed, updated


def main() -> None:
    total_removed = 0
    total_updated = 0
    for locale in ("en", "ru", "zh"):
        path = RESOURCE_DIR / f"resource_{locale}.json"
        removed, updated = migrate_locale(path, locale)
        total_removed += removed
        total_updated += updated
        print(f"{path.name}: removed {removed} condition_* keys, updated {updated} entries")
    print(f"Done: {total_removed} legacy keys removed, {total_updated} values written")


if __name__ == "__main__":
    main()
