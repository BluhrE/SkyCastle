# Sky and the Sparkle Crown

Godot 4 desktop vertical slice for the first playable chapter of a long-form storybook adventure game.

## Run

1. Open this folder in Godot 4.2 or newer.
2. Let Godot import the placeholder assets.
3. Press `F5` to run the project.
4. The game starts at the castle intro on a fresh save and returns to the map on later launches.

Save data is written to `user://sky_save.json`.

## Automated Scene Captures

Run this from PowerShell to generate first-slice screenshots:

```powershell
& "C:\Users\Brand\OneDrive\Documents\Coding\Kids game\Godot_v4.6.1-stable_win64.exe" --path "C:\Users\Brand\OneDrive\Documents\Coding\Kids game" -- --capture-screenshots --capture-dir=res://debug/captures
```

The capture runner scene is [ScreenshotCapture.tscn](C:/Users/Brand/OneDrive/Documents/Coding/Kids%20game/scenes/dev/ScreenshotCapture.tscn) with logic in [ScreenshotCapture.gd](C:/Users/Brand/OneDrive/Documents/Coding/Kids%20game/scripts/dev/ScreenshotCapture.gd). Output goes to [debug/captures](C:/Users/Brand/OneDrive/Documents/Coding/Kids%20game/debug/captures) by default, and the runner restores the user save after the capture pass.

## Current Vertical Slice

- Princess Castle intro
- Rainbow Adventure Map room
- Glitterdrop Waterfall chapter
- Bibi the Frog introduction
- Four small preschool task interactions
- Final waterfall restoration task
- Reward flow with Heart Stars and the first Sunset Ribbon
- Map update and persistent progression

## Architecture Notes

- `scripts/autoload/` contains the reusable game-wide systems.
- `data/` stores world metadata, rewards, and task definitions.
- `dialogue/` stores voice-ready dialogue lines by key.
- `scenes/` contains scene flow and major locations.
- `ui/tasks/` contains reusable task overlays that can be attached to future worlds.
- `assets/art/first_slice/` contains the stable scene and UI art swap points for the first vertical slice.
- `assets/art/first_slice/ART_MANIFEST.md` lists required first-slice art files, dimensions, transparency needs, and layer notes.

## Adding Future Worlds

1. Add a new world entry in `data/worlds/worlds.json`.
2. Create a task file in `data/tasks/`.
3. Add dialogue keys to `dialogue/dialogue_lines.json`.
4. Build the world scene under `scenes/worlds/`.
5. Add a reward definition to `data/rewards/rewards.json`.
6. Reuse `QuestManager`, `GameState`, `DialogueBubble`, `RewardPanel`, and `SceneRouter`.

The current slice already reserves locked placeholders for forest, beach, zoo, and house chapters on the map.

## Art Replacement Notes

- Replace scene visuals by swapping the texture on the named art node, not by renaming gameplay buttons or hotspot nodes.
- For map markers and waterfall puzzle hotspots, replace the child `MarkerArt`, `DoorArt`, or `HotspotArt` node texture and leave the button node intact.
- Shared white panel art hooks are wired into dialogue, hints, pause, reward, and waterfall task overlays so a first-slice UI skin can be replaced consistently.
