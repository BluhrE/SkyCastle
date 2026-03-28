## First-Slice Art Pipeline

This folder is the stable swap point for first-slice art.

Naming rules:
- `bg_<scene>_<layer>.*` for non-transparent scene backdrops
- `prop_<scene>_<name>.*` for set dressing, markers, puzzle plaques, and foreground pieces
- `char_<character>_<pose>.*` for character sprites
- `fx_<character>_<name>.*` for glow or magic overlays tied to a character
- `ui_<group>_<name>.*` for shared interface art

Replacement rules:
- Keep file names stable when possible so scenes continue to load the same assets.
- Replace transparent placeholder files with transparent final PNG/WebP art when ready.
- If final art must use a different extension, update only the texture reference on the named art node in the relevant scene; gameplay scripts do not depend on the art file type.
- Do not rename gameplay buttons or hotspot nodes. Their child `*Art` nodes are the safe visual swap points.

Layering convention for scene art:
- `Background`: sky, walls, distant scenery
- `Midground`: major set pieces like castles, map boards, waterfall bodies
- `PlayLayer` / `Interactables`: marker plaques, puzzle plaques, door signs
- `Characters`: Sky, Bibi, future friends
- `Foreground`: grass, framing leaves, decorative trims
- `UI`: dialogue, hints, reward badges, pause/menu panels

See `assets/art/first_slice/ART_MANIFEST.md` for the per-file breakdown.
