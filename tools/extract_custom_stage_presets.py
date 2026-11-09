#!/usr/bin/env python3
"""Merge selected custom stage presets from to_analyze into CustomStagePresets.json."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TO_ANALYZE = ROOT / "to_analyze"
OUT_PATH = ROOT / "assets/resources/CustomStagePresets.json"

PRESETS = [
    (
        "pvz1_s29_5_future",
        "PVZ1_S29_5_N.JSON",
        "FutureStage",
        "FutureLawnCustom",
        "customStagePreset_futureLawn",
        "customStagePresetSource_memoryLaneS28Level5",
        "Stage_Future.webp",
    ),
    (
        "pvz1_s27_61_roof_night",
        "PVZ1_S27_61_N.JSON",
        "RoofNightStage",
        "RoofNightCustom",
        "customStagePreset_roofNight",
        "customStagePresetSource_memoryLaneS27Level61",
        "Stage_RoofNight.webp",
    ),
    (
        "pvz1_s29_57_snow_modern",
        "PVZ1_S29_57_N.JSON",
        "SnowModernStage",
        "SnowModernCustom",
        "customStagePreset_snowModern",
        "customStagePresetSource_memoryLaneS29Level57",
        "Stage_SnowModern.webp",
    ),
    (
        "pvz1_s31_20_pool_day",
        "PVZ1_S31_20_N.JSON",
        "PoolDaylightStage",
        "PoolDaylightCustom",
        "customStagePreset_poolDaylight",
        "customStagePresetSource_memoryLaneS31Level20",
        "Stage_PoolDaylight.webp",
    ),
    (
        "pvz1_s30_31_renai",
        "PVZ1_S30_31_N.JSON",
        "RenaiStage",
        "RenaiCustom",
        "customStagePreset_renai",
        "customStagePresetSource_memoryLaneS30Level31",
        "Stage_Renai.webp",
    ),
    (
        "pvz1_s31_9_steam",
        "PVZ1_S31_9_N.JSON",
        "SteamStage",
        "SteamCustom",
        "customStagePreset_steam",
        "customStagePresetSource_memoryLaneS31Level9",
        "Stage_Steam.webp",
    ),
    (
        "pvz1_s30_boss_volcano",
        "PVZ1_S30_BOSS_ROBOT_6.JSON",
        "LostCityStage",
        "LostVolcanoCustom",
        "customStagePreset_lostVolcano",
        "customStagePresetSource_memoryLaneS30Boss6",
        "Stage_LostVolcano.webp",
    ),
    (
        "pvz1_minigame_summer_day",
        "PVZ1_MINIGAME_GAME_33.JSON",
        "SummerDaylightStage",
        "SummerDaylightCustom",
        "customStagePreset_summerDaylight",
        "customStagePresetSource_minigameGame33",
        "Stage_SummerDaylight.webp",
    ),
    (
        "pvz1_s30_1_newyear_night",
        "PVZ1_S30_1_H.JSON",
        "NewYearNightStage",
        "NewYearNightCustom",
        "customStagePreset_newYearNight",
        "customStagePresetSource_memoryLaneS30Hard1",
        "Stage_NewYearNight.webp",
    ),
    (
        "pvz1_s28_13_autumn_late",
        "PVZ1_S28_13_N.JSON",
        "AutumnLateStage",
        "AutumnLateCustom",
        "customStagePreset_autumnLate",
        "customStagePresetSource_memoryLaneS28Level13",
        "Stage_AutumnLate.webp",
    ),
]


def clean_objdata(data: dict) -> dict:
    out: dict = {}
    for key, value in data.items():
        if not isinstance(key, str) or " " in key or key.startswith("#"):
            continue
        out[key] = value
    return out


def main() -> None:
    entries: list[dict] = []
    for (
        preset_id,
        fname,
        alias,
        custom_alias,
        name_key,
        source_key,
        icon,
    ) in PRESETS:
        path = next(TO_ANALYZE.rglob(fname), None)
        if path is None:
            raise FileNotFoundError(fname)
        data = json.loads(path.read_text(encoding="utf-8"))
        stage = None
        for obj in data.get("objects", []):
            aliases = obj.get("aliases") or []
            if alias in aliases:
                stage = obj
                break
        if stage is None:
            raise ValueError(f"Stage {alias} not found in {fname}")
        entries.append(
            {
                "id": preset_id,
                "alias": custom_alias,
                "nameKey": name_key,
                "sourceKey": source_key,
                "iconName": icon,
                "objclass": stage["objclass"],
                "objdata": clean_objdata(stage.get("objdata") or {}),
            }
        )

    existing = json.loads(OUT_PATH.read_text(encoding="utf-8"))
    existing_ids = {entry["id"] for entry in existing}
    merged = existing + [entry for entry in entries if entry["id"] not in existing_ids]
    OUT_PATH.write_text(
        json.dumps(merged, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Added {len(merged) - len(existing)} presets; total {len(merged)}.")


if __name__ == "__main__":
    main()
