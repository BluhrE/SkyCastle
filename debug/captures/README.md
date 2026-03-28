# Automated Screenshot Captures

This folder is the default output location for automated first-slice screenshot captures.

Run from PowerShell:

```powershell
& "C:\Users\Brand\OneDrive\Documents\Coding\Kids game\Godot_v4.6.1-stable_win64.exe" --path "C:\Users\Brand\OneDrive\Documents\Coding\Kids game" -- --capture-screenshots --capture-dir=res://debug/captures
```

Default outputs:
- `01_main_menu_fresh.png`
- `02_castle_intro_dialogue.png`
- `03_castle_intro_ready.png`
- `04_map_room_unlocked.png`
- `05_waterfall_gameplay.png`
- `06_reward_scene.png`
- `07_map_room_restored.png`

The capture runner backs up the active save, stages temporary progress states for each shot, and restores the original save when it finishes.

On this Windows setup, normal rendering mode produced the captures reliably. `--headless` booted the project but did not emit the PNG files.
