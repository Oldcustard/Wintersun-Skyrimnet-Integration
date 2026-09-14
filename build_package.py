#!/usr/bin/env python3
"""Build Wintersun-SkyrimNet-Integration.zip using the SkyrimNet Beta 25 plugin layout.

Content (prompts, triggers, knowledge pack) ships as an external plugin layer at
SKSE/Plugins/SkyrimNet/external/{id}/ — see docs/modding/MIGRATING_TO_BETA25.md
in the SkyrimNet-GamePlugin repo.

Usage:  python build_package.py
"""
import os
import sys
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
PLUGIN_ID = "oldcustard.wintersun"
PLUGIN_DIR = os.path.join(ROOT, "Plugin", PLUGIN_ID)
OUT_ZIP = os.path.join(ROOT, "Wintersun-SkyrimNet-Integration.zip")

EXTERNAL = "SKSE/Plugins/SkyrimNet/external/" + PLUGIN_ID
SETTINGS_DIR = "SKSE/Plugins/SkyrimNet/config/plugins/Wintersun Integration"
VOICE_EFFECTS_SRC = os.path.join(ROOT, "Voice Effects")
VOICE_EFFECTS_DEST = "SKSE/Plugins/SkyrimNet/config/voice_effects"

# Triggers that do not work: SkyrimNet's active_effect events cannot detect effects
# applied via Papyrus AddSpell(). Kept in the plugin folder as source only.
EXCLUDED_TRIGGERS = {
    "wintersun_deity_switch_narration.yaml",
    "wintersun_deity_abandonment_narration.yaml",
}

BANNED_EXTENSIONS = {".yml", ".YAML"}


def fail(msg):
    print("ERROR: " + msg)
    sys.exit(1)


def add(zf, src, arcname):
    ext = os.path.splitext(arcname)[1]
    if ext in BANNED_EXTENSIONS:
        fail("extension %r is rejected by SkyrimNet: %s" % (ext, arcname))
    if any(ord(c) > 127 for c in arcname):
        fail("non-ASCII path rejected by SkyrimNet: %s" % arcname)
    zf.write(src, arcname)
    print("  " + arcname)


def main():
    esp = os.path.join(ROOT, "WSN_SkyrimNet_Integration.esp")
    if not os.path.isfile(esp):
        fail("WSN_SkyrimNet_Integration.esp not built yet (run the toolkit first)")

    print("Building " + os.path.basename(OUT_ZIP))
    with zipfile.ZipFile(OUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        add(zf, esp, "WSN_SkyrimNet_Integration.esp")

        for name in sorted(os.listdir(os.path.join(ROOT, "Scripts"))):
            if name.endswith(".pex"):
                add(zf, os.path.join(ROOT, "Scripts", name), "Scripts/" + name)

        seq_dir = os.path.join(ROOT, "Seq")
        if os.path.isdir(seq_dir):
            for name in sorted(os.listdir(seq_dir)):
                if name.endswith(".seq"):
                    add(zf, os.path.join(seq_dir, name), "Seq/" + name)

        for base, _dirs, files in os.walk(PLUGIN_DIR):
            rel = os.path.relpath(base, PLUGIN_DIR)
            rel = "" if rel == "." else rel.replace(os.sep, "/")
            for name in sorted(files):
                if rel.startswith("triggers") and name in EXCLUDED_TRIGGERS:
                    print("  (skipped broken trigger: triggers/" + name + ")")
                    continue
                arc = (EXTERNAL + "/" + rel + "/" + name) if rel else (EXTERNAL + "/" + name)
                add(zf, os.path.join(base, name), arc)

        add(zf, os.path.join(ROOT, "manifest.yaml"), SETTINGS_DIR + "/manifest.yaml")

        if os.path.isdir(VOICE_EFFECTS_SRC):
            for name in sorted(os.listdir(VOICE_EFFECTS_SRC)):
                if name.endswith(".yaml"):
                    add(zf, os.path.join(VOICE_EFFECTS_SRC, name), VOICE_EFFECTS_DEST + "/" + name)
        else:
            print("  NOTE: 'Voice Effects/' source dir absent - voice effects NOT packaged")
            print("        (sources live on the feature branch; carried over from the previous")
            print("        release zip when this one was built)")

    size = os.path.getsize(OUT_ZIP)
    print("Done: %s (%d bytes, %d entries)" % (OUT_ZIP, size, len(zipfile.ZipFile(OUT_ZIP).namelist())))


if __name__ == "__main__":
    main()
