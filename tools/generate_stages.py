#!/usr/bin/env python3
"""Generate:
1) assets/resources/Stages_helper.json (DelayLoad_Background -> display metadata)
2) assets/resources/Stages_objclass_helper.json (stage objclass -> round icon)
3) assets/resources/Stages.json (stage property schemas + implementations + tags)
"""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LEVEL_MODULES_PATH = ROOT / "assets/reference/LevelModules.json"
STAGES_TAGS_PATH = ROOT / "assets/resources/Stages_tags.json"
CUSTOM_PRESETS_PATH = ROOT / "assets/resources/CustomStagePresets.json"
ROUND_ICONS_DIR = ROOT / "assets/images/round_icons"
HELPER_OUT_PATH = ROOT / "assets/resources/Stages_helper.json"
OBJCLASS_HELPER_OUT_PATH = ROOT / "assets/resources/Stages_objclass_helper.json"
STAGES_OUT_PATH = ROOT / "assets/resources/Stages.json"
LEGACY_IMAGES_OUT_PATH = ROOT / "assets/resources/Stages_images.json"

STAGE_NAME_KEY_PREFIX = "stage_"

UNKNOWN_ICON = "unknown.webp"
EXCLUDED_OBJCLASSES = frozenset({"ZombossFinalStageTimeLimitedChallengeProperties"})

# Parameter names whose values are zombie type aliases in game data.
ZOMBIE_TYPE_PARAM_NAMES = {
    "BasicZombieTypeName",
    "FlagZombieTypeName",
    "Armor1ZombieTypeName",
    "Armor2ZombieTypeName",
    "Armor3ZombieTypeName",
    "FlagVeteranZombieTypeNames",
    "SpawnZombieTypes",
    "SpawnZombieType",
    "SpawnDinoType",
    "ZombieNames",
    "ZombieName",
    "SpiderZombieName",
    "PortalZombieType",
}

# BackgroundImagePrefix -> preferred stage alias when several share the same prefix.
PREFIX_ALIAS_OVERRIDES: dict[str, str] = {
    "IMAGE_BACKGROUNDS_AUTUMN_LATE": "AutumnLateStage",
    "IMAGE_BACKGROUNDS_BEACH": "BeachStage",
    "IMAGE_BACKGROUNDS_EGYPT": "EgyptStage",
    "IMAGE_BACKGROUNDS_ICEAGE": "IceageStage",
    "IMAGE_BACKGROUNDS_MODERN": "ModernStage",
    "IMAGE_BACKGROUNDS_SKYCITY": "SkycityStage",
    "IMAGE_BACKGROUNDS_SNOW_MODERN": "SnowModernStage",
    "IMAGE_BACKGROUNDS_SNOW_NIGHT": "SnowNightStage",
    "IMAGE_BACKGROUNDS_SNOW_ROOF": "SnowRoofStage",
}

# BackgroundImagePrefix -> icon when it differs from the chosen alias icon.
PREFIX_ICON_OVERRIDES: dict[str, str] = {}

# Stage properties objclass -> preferred catalog alias when several share the objclass.
OBJCLASS_ALIAS_OVERRIDES: dict[str, str] = {
    "BeachStageProperties": "BeachStage",
    "DarkStageProperties": "DarkStage",
    "FrontLawnStageProperties": "FrontLawnSpringStage",
    "IceAgeStageProperties": "IceageStage",
    "KongFuStageProperties": "KongfuStage",
    "ModernStageProperties": "ModernStage",
    "PoolDaylightStageProperties": "PoolDaylightStage",
    "RoofStageProperties": "RoofStage",
    "SkyCityStageProperties": "SkycityStage",
    "StageModuleProperties": "ModernStage",
}


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def is_stage_entry(objclass: str) -> bool:
    if objclass in EXCLUDED_OBJCLASSES:
        return False
    return "Stage" in objclass and objclass.endswith("Properties")


def primitive_type(value: Any) -> str:
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int) and not isinstance(value, bool):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        if value.startswith("RTID("):
            return "rtid"
        return "string"
    return "dynamic"


def semantic_type(name: str, value: Any) -> str | None:
    if name in ZOMBIE_TYPE_PARAM_NAMES:
        if isinstance(value, list):
            return "List<zombieType>"
        if isinstance(value, str):
            return "zombieType"
    if name.endswith("ZombieTypes") or name.endswith("ZombieNames"):
        if isinstance(value, list):
            return "List<zombieType>"
        if isinstance(value, str):
            return "zombieType"
    if name.endswith("ZombieTypeName") or name.endswith("ZombieName"):
        if isinstance(value, str):
            return "zombieType"
    return None


def list_element_type(items: list[Any]) -> str:
    if not items:
        return "dynamic"
    types = {primitive_type(item) for item in items}
    if len(types) == 1:
        return next(iter(types))
    if types.issubset({"int", "float"}):
        return "num"
    return "dynamic"


def describe_parameter(name: str, value: Any) -> dict[str, Any]:
    override = semantic_type(name, value)
    if override is not None:
        return {"name": name, "type": override, "default": value}

    if isinstance(value, list):
        return {
            "name": name,
            "type": f"List<{list_element_type(value)}>",
            "default": value,
        }

    if isinstance(value, dict):
        fields = [
            describe_parameter(field_name, field_value)
            for field_name, field_value in value.items()
            if not field_name.startswith("#")
        ]
        return {
            "name": name,
            "type": "object",
            "fields": fields,
            "default": value,
        }

    return {"name": name, "type": primitive_type(value), "default": value}


def ensure_ambient_audio_suffix(fields: list[dict[str, Any]]) -> list[dict[str, Any]]:
    if any(field.get("name") == "AmbientAudioSuffix" for field in fields):
        return fields
    return [
        *fields,
        {
            "name": "AmbientAudioSuffix",
            "type": "string",
            "default": "",
        },
    ]


def merge_fields_from_objdata(objdata_maps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    field_map: dict[str, dict[str, Any]] = {}
    for values in objdata_maps:
        if not isinstance(values, dict):
            continue
        for key, value in values.items():
            if key.startswith("#"):
                continue
            spec = describe_parameter(key, value)
            if key not in field_map:
                field_map[key] = spec
    return [field_map[name] for name in sorted(field_map)]


def clean_objdata(objdata: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value
        for key, value in objdata.items()
        if not key.startswith("#")
    }


def build_implementation_entry(
    alias: str,
    objdata: dict[str, Any],
    stage_metadata: dict[str, dict[str, str | None]],
) -> dict[str, Any]:
    entry: dict[str, Any] = {
        "alias": alias,
        "objdata": clean_objdata(objdata),
    }
    meta = stage_metadata.get(alias, {})
    icon = meta.get("icon")
    tag = meta.get("tag")
    if isinstance(icon, str) and icon:
        entry["image"] = icon
    if isinstance(tag, str) and tag:
        entry["tag"] = tag
    return entry


def load_stage_metadata() -> dict[str, dict[str, str | None]]:
    """Load alias -> {icon, tag} from Stages_tags.json (legacy flat catalog)."""
    if not STAGES_TAGS_PATH.is_file():
        return {}
    raw = load_json(STAGES_TAGS_PATH)
    if not isinstance(raw, list):
        raise ValueError(f"Expected array in {STAGES_TAGS_PATH}")
    metadata: dict[str, dict[str, str | None]] = {}
    for item in raw:
        if not isinstance(item, dict):
            continue
        alias = item.get("alias")
        if not isinstance(alias, str):
            continue
        icon = item.get("iconName")
        tag = item.get("type") or item.get("tag")
        metadata[alias] = {
            "icon": icon if isinstance(icon, str) else None,
            "tag": tag if isinstance(tag, str) else None,
        }
    return metadata


def build_objclass_section(
    objclass: str,
    implementations: list[dict[str, Any]],
) -> dict[str, Any]:
    objdata_maps = [
        impl["objdata"]
        for impl in implementations
        if isinstance(impl.get("objdata"), dict)
    ]
    return {
        "objclass": objclass,
        "fields": ensure_ambient_audio_suffix(
            merge_fields_from_objdata(objdata_maps)
        ),
        "implementations": implementations,
    }


def load_round_icons() -> set[str]:
    if not ROUND_ICONS_DIR.is_dir():
        return set()
    return {path.name for path in ROUND_ICONS_DIR.iterdir() if path.is_file()}


def icon_from_bg_token(token: str, round_icons: set[str]) -> str | None:
    candidates = [
        f"Stage_{token}.webp",
        f"Stage_{token.replace('_', '')}.webp",
    ]
    for candidate in candidates:
        if candidate in round_icons:
            return candidate

    token_lower = token.lower()
    for icon in round_icons:
        if not icon.startswith("Stage_"):
            continue
        icon_token = icon.removeprefix("Stage_").removesuffix(".webp").lower()
        if icon_token == token_lower:
            return icon
        if token_lower in icon_token or icon_token in token_lower:
            return icon
    return None


def normalize_prefix_token(prefix: str) -> str:
    return prefix.removeprefix("IMAGE_BACKGROUNDS_")


def icon_from_prefix(prefix: str, round_icons: set[str]) -> str | None:
    return icon_from_bg_token(normalize_prefix_token(prefix), round_icons)


def stage_name_key(alias: str) -> str:
    return f"{STAGE_NAME_KEY_PREFIX}{alias}"


def pick_representative_alias(
    prefix: str,
    aliases: list[str],
    stage_catalog: dict[str, str | None],
) -> str:
    if prefix in PREFIX_ALIAS_OVERRIDES:
        return PREFIX_ALIAS_OVERRIDES[prefix]

    catalog_aliases = [alias for alias in aliases if alias in stage_catalog]
    if catalog_aliases:
        return sorted(catalog_aliases, key=len)[0]

    return sorted(aliases, key=len)[0]


def pick_alias_for_objclass(
    objclass: str,
    aliases: list[str],
    stage_catalog: dict[str, str | None],
) -> str:
    if objclass in OBJCLASS_ALIAS_OVERRIDES:
        return OBJCLASS_ALIAS_OVERRIDES[objclass]

    stem_candidates = [
        objclass.removesuffix("Properties"),
        objclass.removesuffix("StageProperties") + "Stage",
        objclass.replace("KongFu", "Kongfu").removesuffix("Properties"),
        objclass.replace("IceAge", "Iceage").removesuffix("Properties"),
    ]
    if objclass == "DeepseaStageLandProperties":
        stem_candidates.insert(0, "DeepseaLandStage")
    if objclass == "SkyCityStageProperties":
        stem_candidates.insert(0, "SkycityStage")
    if objclass == "AtlantisStageProperties":
        stem_candidates.insert(0, "AtlantisStage")

    for candidate in stem_candidates:
        if candidate in aliases:
            return candidate

    catalog_aliases = [alias for alias in aliases if alias in stage_catalog]
    if len(catalog_aliases) == 1:
        return catalog_aliases[0]
    if catalog_aliases:
        return sorted(catalog_aliases, key=len)[0]

    return sorted(aliases, key=len)[0]


def icon_from_objclass_name(objclass: str, round_icons: set[str]) -> str | None:
    token = objclass.removesuffix("Properties").removesuffix("Stage")
    if objclass.startswith("KongFu"):
        token = "Kongfu"
    elif objclass.startswith("IceAge"):
        token = "Iceage"
    elif objclass == "SkyCityStageProperties":
        token = "Skycity"
    elif objclass == "DeepseaStageLandProperties":
        token = "Atlantis"
    elif objclass == "DeepseaStageProperties":
        token = "Atlantis"
    elif objclass == "AtlantisStageProperties":
        token = "Atlantis"
    elif objclass == "RunningSubwayStageProperties":
        token = "Subway"

    return icon_from_bg_token(token, round_icons)


def pick_icon_for_alias(
    prefix: str,
    alias: str,
    stage_catalog: dict[str, str | None],
    round_icons: set[str],
) -> str:
    if prefix in PREFIX_ICON_OVERRIDES:
        return PREFIX_ICON_OVERRIDES[prefix]

    icon = stage_catalog.get(alias)
    if isinstance(icon, str) and icon:
        return icon

    matched = icon_from_prefix(prefix, round_icons)
    if matched:
        return matched

    return UNKNOWN_ICON


def build_helper_leaf(
    prefix: str,
    alias: str,
    stage_catalog: dict[str, str | None],
    round_icons: set[str],
) -> dict[str, str]:
    return {
        "image": pick_icon_for_alias(prefix, alias, stage_catalog, round_icons),
        "nameKey": stage_name_key(alias),
    }


def delay_load_background_groups(objdata: dict[str, Any]) -> list[str]:
    groups = objdata.get("ResourceGroupNames") or []
    if not isinstance(groups, list):
        return []
    return [
        group
        for group in groups
        if isinstance(group, str) and group.startswith("DelayLoad_Background_")
    ]


def infer_background_resource_group(objdata: dict[str, Any]) -> str | None:
    """Resolve BackgroundResourceGroup, inferring from ResourceGroupNames when absent."""
    brg = objdata.get("BackgroundResourceGroup")
    if isinstance(brg, str) and brg:
        return brg

    delay_loads = delay_load_background_groups(objdata)
    if not delay_loads:
        return None

    prefix = objdata.get("BackgroundImagePrefix")
    if not isinstance(prefix, str) or not prefix:
        return delay_loads[0]

    token = prefix.removeprefix("IMAGE_BACKGROUNDS_").lower()
    token_aliases = {
        "oldwest": "west",
        "kongfu": "kongfu",
    }
    search = token_aliases.get(token, token)

    best: str | None = None
    for group in delay_loads:
        if search not in group.lower():
            continue
        if best is None or len(group) < len(best):
            best = group
    return best or delay_loads[0]


def collect_stage_entries(
    level_modules: dict[str, Any],
) -> tuple[
    dict[tuple[str, str], set[str]],
    dict[str, dict[str, dict[str, Any]]],
]:
    """Return (delayLoad, imagePrefix)->aliases, objclass->alias->objdata."""
    brg_prefix_to_aliases: dict[tuple[str, str], set[str]] = defaultdict(set)
    by_objclass: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)

    for entry in level_modules.get("objects", []):
        objclass = entry.get("objclass")
        if not isinstance(objclass, str) or not is_stage_entry(objclass):
            continue

        objdata = entry.get("objdata") or {}
        if not isinstance(objdata, dict):
            objdata = {}

        brg = infer_background_resource_group(objdata)
        prefix = objdata.get("BackgroundImagePrefix")
        aliases = entry.get("aliases") or []

        for alias in aliases:
            if not isinstance(alias, str):
                continue
            by_objclass[objclass][alias] = dict(objdata)
            if isinstance(brg, str) and isinstance(prefix, str):
                brg_prefix_to_aliases[(brg, prefix)].add(alias)

    return brg_prefix_to_aliases, by_objclass


def build_stages_helper(
    brg_prefix_to_aliases: dict[tuple[str, str], set[str]],
    stage_catalog: dict[str, str | None],
    round_icons: set[str],
    custom_presets: list[dict[str, Any]] | None = None,
) -> dict[str, dict[str, dict[str, str]]]:
    """Map DelayLoad_Background -> BackgroundImagePrefix -> { image, nameKey }."""
    by_brg: dict[str, dict[str, dict[str, str]]] = defaultdict(dict)

    for (brg, prefix), alias_set in sorted(brg_prefix_to_aliases.items()):
        aliases = sorted(alias_set)
        alias = pick_representative_alias(prefix, aliases, stage_catalog)
        by_brg[brg][prefix] = build_helper_leaf(
            prefix, alias, stage_catalog, round_icons
        )

    for preset in custom_presets or []:
        objdata = preset["objdata"]
        brg = infer_background_resource_group(objdata)
        prefix = objdata.get("BackgroundImagePrefix")
        if not isinstance(brg, str) or not isinstance(prefix, str):
            continue
        by_brg[brg].setdefault(
            prefix,
            {"image": preset["iconName"], "nameKey": preset["nameKey"]},
        )

    return {brg: dict(sorted(prefix_map.items())) for brg, prefix_map in sorted(by_brg.items())}


def iter_helper_leaves(
    helper: dict[str, dict[str, dict[str, str]]],
) -> list[dict[str, str]]:
    leaves: list[dict[str, str]] = []
    for prefix_map in helper.values():
        for leaf in prefix_map.values():
            if isinstance(leaf, dict):
                leaves.append(leaf)
    return leaves


def verify_stages_helper(
    helper: dict[str, dict[str, dict[str, str]]],
) -> list[str]:
    issues: list[str] = []
    for brg, prefix_map in helper.items():
        if not isinstance(prefix_map, dict) or not prefix_map:
            issues.append(f"{brg}: helper entry must be a non-empty object")
            continue

        for prefix, leaf in prefix_map.items():
            label = f"{brg}/{prefix}"
            if not isinstance(leaf, dict):
                issues.append(f"{label}: helper leaf must be an object")
                continue
            image = leaf.get("image")
            name_key = leaf.get("nameKey")
            if not isinstance(image, str) or not image:
                issues.append(f"{label}: missing image")
            if not isinstance(name_key, str) or not name_key.startswith(
                (STAGE_NAME_KEY_PREFIX, "customStagePreset_")
            ):
                issues.append(f"{label}: invalid nameKey '{name_key}'")
    return issues


def build_stages_objclass_helper(
    by_objclass: dict[str, dict[str, dict[str, Any]]],
    stage_catalog: dict[str, str | None],
    round_icons: set[str],
) -> dict[str, str]:
    helper: dict[str, str] = {}
    for objclass in sorted(by_objclass):
        alias_map = by_objclass[objclass]
        aliases = sorted(alias_map)
        alias = pick_alias_for_objclass(objclass, aliases, stage_catalog)
        objdata = alias_map.get(alias) or next(iter(alias_map.values()))
        prefix = objdata.get("BackgroundImagePrefix") if isinstance(objdata, dict) else None

        if isinstance(prefix, str) and prefix:
            icon = pick_icon_for_alias(prefix, alias, stage_catalog, round_icons)
        else:
            icon = None

        if not isinstance(icon, str) or not icon or icon == UNKNOWN_ICON:
            catalog_icon = stage_catalog.get(alias)
            icon = (
                catalog_icon
                if isinstance(catalog_icon, str) and catalog_icon
                else icon_from_objclass_name(objclass, round_icons)
            )
        if not icon:
            icon = UNKNOWN_ICON

        helper[objclass] = icon
    return helper


def verify_stages_objclass_helper(
    helper: dict[str, str],
    round_icons: set[str],
) -> list[str]:
    issues: list[str] = []
    for objclass, icon in helper.items():
        if not isinstance(icon, str) or not icon:
            issues.append(f"{objclass}: missing image")
            continue
        if icon != UNKNOWN_ICON and icon not in round_icons:
            issues.append(f"{objclass}: image '{icon}' missing from round_icons")
    return issues


def build_stages_new(
    by_objclass: dict[str, dict[str, dict[str, Any]]],
    stage_metadata: dict[str, dict[str, str | None]],
) -> list[dict[str, Any]]:
    sections: list[dict[str, Any]] = []
    for objclass in sorted(by_objclass):
        raw_impls = by_objclass[objclass]
        implementations = [
            build_implementation_entry(alias, objdata, stage_metadata)
            for alias, objdata in sorted(raw_impls.items())
        ]
        sections.append(build_objclass_section(objclass, implementations))
    return sections


def verify_stages_new(
    stages_new: list[dict[str, Any]],
    stage_metadata: dict[str, dict[str, str | None]],
) -> list[str]:
    issues: list[str] = []
    for section in stages_new:
        objclass = section.get("objclass")
        fields = section.get("fields") or []
        if not any(field.get("name") == "AmbientAudioSuffix" for field in fields):
            issues.append(f"{objclass}: missing AmbientAudioSuffix field")

        implementations = section.get("implementations") or []
        if not isinstance(implementations, list):
            issues.append(f"{objclass}: implementations must be an array")
            continue

        for impl in implementations:
            if not isinstance(impl, dict):
                issues.append(f"{objclass}: implementation entry must be an object")
                continue
            alias = impl.get("alias")
            if not isinstance(alias, str):
                issues.append(f"{objclass}: implementation missing alias")
                continue
            if "objdata" not in impl or not isinstance(impl["objdata"], dict):
                issues.append(f"{objclass}/{alias}: missing objdata")
                continue
            if "image" in impl.get("objdata", {}):
                issues.append(f"{objclass}/{alias}: image must not be inside objdata")
            if alias in stage_metadata and "image" not in impl:
                issues.append(f"{objclass}/{alias}: missing image for catalog stage")
            if alias in stage_metadata and "tag" not in impl:
                issues.append(f"{objclass}/{alias}: missing tag for catalog stage")
            if alias not in stage_metadata and "image" in impl:
                issues.append(f"{objclass}/{alias}: unexpected image for non-catalog stage")
            if alias not in stage_metadata and "tag" in impl:
                issues.append(f"{objclass}/{alias}: unexpected tag for non-catalog stage")
    return issues


def main() -> None:
    level_modules = load_json(LEVEL_MODULES_PATH)
    custom_presets = load_json(CUSTOM_PRESETS_PATH)
    stage_metadata = load_stage_metadata()
    stage_catalog: dict[str, str | None] = {
        alias: meta.get("icon") for alias, meta in stage_metadata.items()
    }

    round_icons = load_round_icons()
    brg_prefix_to_aliases, by_objclass = collect_stage_entries(level_modules)

    stages_helper = build_stages_helper(
        brg_prefix_to_aliases, stage_catalog, round_icons, custom_presets
    )
    stages = build_stages_new(by_objclass, stage_metadata)
    stages_objclass_helper = build_stages_objclass_helper(
        by_objclass, stage_catalog, round_icons
    )

    helper_issues = verify_stages_helper(stages_helper)
    if helper_issues:
        print("Helper verification issues:")
        for issue in helper_issues:
            print(f"  - {issue}")
        raise SystemExit(1)

    objclass_helper_issues = verify_stages_objclass_helper(
        stages_objclass_helper, round_icons
    )
    if objclass_helper_issues:
        print("Objclass helper verification issues:")
        for issue in objclass_helper_issues:
            print(f"  - {issue}")
        raise SystemExit(1)

    issues = verify_stages_new(stages, stage_metadata)
    if issues:
        print("Verification issues:")
        for issue in issues:
            print(f"  - {issue}")
        raise SystemExit(1)

    with HELPER_OUT_PATH.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(stages_helper, f, ensure_ascii=False, indent=2)
        f.write("\n")

    with OBJCLASS_HELPER_OUT_PATH.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(stages_objclass_helper, f, ensure_ascii=False, indent=2)
        f.write("\n")

    if LEGACY_IMAGES_OUT_PATH.exists():
        LEGACY_IMAGES_OUT_PATH.unlink()

    with STAGES_OUT_PATH.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(stages, f, ensure_ascii=False, indent=2)
        f.write("\n")

    legacy_new = ROOT / "assets/resources/Stages_new.json"
    if legacy_new.exists():
        legacy_new.unlink()

    leaves = iter_helper_leaves(stages_helper)
    unknown_count = sum(1 for leaf in leaves if leaf.get("image") == UNKNOWN_ICON)
    impl_count = sum(
        len(section.get("implementations") or [])
        for section in stages
    )
    print(f"Wrote {len(leaves)} helper entries to {HELPER_OUT_PATH}")
    print(f"Unknown icons: {unknown_count}")
    print(
        f"Wrote {len(stages_objclass_helper)} objclass icons to "
        f"{OBJCLASS_HELPER_OUT_PATH}"
    )
    print(
        f"Wrote {len(stages)} stage objclasses "
        f"({impl_count} implementations) to {STAGES_OUT_PATH}"
    )


if __name__ == "__main__":
    main()
