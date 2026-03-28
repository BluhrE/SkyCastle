# First-Slice Asset Manifest

This manifest covers the real first playable slice: main menu, castle intro, map room, Glitterdrop Waterfall, shared UI, Sky, and Bibi.

| File | Purpose | Suggested Dimensions | Transparent | Type | Layer / Replacement Note |
| --- | --- | --- | --- | --- | --- |
| `backgrounds/menu/bg_main_menu_sky.svg` | Main menu storybook sky wash | 1280x720 | No | background | Replace the menu sky backdrop in `MainMenu.tscn` |
| `props/menu/prop_main_menu_castle.svg` | Main menu distant castle silhouette | 420x360 | Yes | prop | Replace the castle shape in `MainMenu.tscn` |
| `backgrounds/castle_intro/bg_castle_intro_sky.svg` | Castle intro sunset sky | 1280x720 | No | background | Background layer in `CastleIntro.tscn` |
| `backgrounds/castle_intro/bg_castle_intro_hills.svg` | Castle intro distant hills | 1280x360 | Yes | background | Background overlay in `CastleIntro.tscn` |
| `props/castle_intro/prop_castle_intro_castle.svg` | Main castle exterior set piece | 560x470 | Yes | prop | Midground castle exterior in `CastleIntro.tscn` |
| `props/castle_intro/prop_castle_intro_tower_door.svg` | Storybook tower door plaque | 180x210 | Yes | prop | Child art of `MapDoorButton` |
| `props/castle_intro/prop_castle_intro_foreground_grass.svg` | Foreground grass strip | 1280x220 | Yes | prop | Foreground layer in `CastleIntro.tscn` |
| `characters/sky/char_sky_main.png` | Main full-body Sky art used for first-slice scenes | 1024x1024 | Yes | character | Shared Sky source for preview, castle intro, and waterfall scenes |
| `characters/sky/char_sky_castle_idle.svg` | Legacy vector placeholder for intro pose | 160x190 | Yes | character | Replaced in active scene wiring by `char_sky_main.png` |
| `characters/sky/fx_sky_collar_glow.svg` | Collar glow / help signal | 84x84 | Yes | prop | `SkyCollarGlow` in `CastleIntro.tscn` |
| `backgrounds/map_room/bg_map_room_wall.svg` | Map room wall and warm room tone | 1280x720 | No | background | Root background in `MapRoom.tscn` |
| `backgrounds/map_room/bg_map_room_arch.svg` | Window/arch framing behind map | 960x620 | Yes | background | Background overlay in `MapRoom.tscn` |
| `props/map_room/prop_map_room_board.svg` | Rainbow Adventure Map board | 820x520 | Yes | prop | Midground board in `MapRoom.tscn` |
| `props/map_room/prop_map_room_waterfall_path.svg` | First glowing travel path | 180x54 | Yes | prop | Midground path glow in `MapRoom.tscn` |
| `props/map_room/prop_map_room_marker_castle.svg` | Castle map marker plaque | 170x140 | Yes | prop | Child art of `CastleMarker` |
| `props/map_room/prop_map_room_marker_waterfall.svg` | Waterfall map marker plaque | 240x170 | Yes | prop | Child art of `WaterfallMarker` |
| `props/map_room/prop_map_room_marker_locked.svg` | Locked future-world marker plaque | 170x140 | Yes | prop | Reused by forest, beach, zoo, and house markers |
| `backgrounds/waterfall/bg_waterfall_sky.svg` | Glitterdrop Waterfall sky | 1280x720 | No | background | Root background in `WaterfallWorld.tscn` |
| `backgrounds/waterfall/bg_waterfall_cliffs.svg` | Distant cliffs and treeline | 1280x400 | Yes | background | Background overlay in `WaterfallWorld.tscn` |
| `props/waterfall/prop_waterfall_setpiece.svg` | Main waterfall, pool, and mist cluster | 720x560 | Yes | prop | Midground set piece in `WaterfallWorld.tscn` |
| `props/waterfall/prop_waterfall_hotspot_plaque.svg` | Standard puzzle plaque for core tasks | 270x110 | Yes | prop | Reused for count, match, splash, and drag hotspots |
| `props/waterfall/prop_waterfall_crystal_hotspot.svg` | Final crystal ledge plaque | 300x96 | Yes | prop | Child art of `CrystalLedgeSpot` |
| `props/waterfall/prop_waterfall_foreground_grass.svg` | Waterfall foreground grass strip | 1280x120 | Yes | prop | Foreground layer in `WaterfallWorld.tscn` |
| `props/waterfall/prop_task_water_drop.svg` | Count-the-drops puzzle token | 64x96 | Yes | prop | Reused by all five drop tokens in `CountDropsTask.tscn` |
| `props/waterfall/prop_task_sparkle_piece.svg` | Drag-and-drop sparkle piece | 72x72 | Yes | prop | Reused by all sparkle pieces in `DragSparklesTask.tscn` |
| `props/waterfall/prop_task_crystal_piece.svg` | Final crystal restoration piece | 96x96 | Yes | prop | `CrystalPiece` in `CrystalRestoreTask.tscn` |
| `props/waterfall/prop_task_crystal_socket.svg` | Final crystal socket glow | 120x120 | Yes | prop | Child art of `CrystalSocket` in `CrystalRestoreTask.tscn` |
| `characters/sky/char_sky_waterfall_idle.svg` | Legacy vector placeholder for waterfall pose | 150x180 | Yes | character | Replaced in active scene wiring by `char_sky_main.png` |
| `characters/bibi/char_bibi_waterfall_idle.svg` | Bibi idle pose | 130x110 | Yes | character | `BibiBody` in `WaterfallWorld.tscn` |
| `ui/core/ui_story_panel_white.svg` | Shared readable white story panel skin | 960x260 | Yes | UI | Use for dialogue, pause, menu, confirm, and reward panel backgrounds |
| `ui/core/ui_hud_plaque.svg` | Small HUD plaque for hints and progress ribbons | 420x110 | Yes | UI | Use behind map totals and waterfall chapter progress |
| `ui/rewards/ui_badge_heart_star.svg` | Heart Star reward icon | 96x96 | Yes | UI | Reward badge and future HUD icon |
| `ui/rewards/ui_badge_sunset_ribbon.svg` | Sunset Ribbon reward icon | 96x96 | Yes | UI | Reward badge and future HUD icon |
| `backgrounds/reward/bg_reward_glow.svg` | Reward scene celebration glow | 1280x720 | No | background | Reward scene backdrop |

## Scene Layer Notes

### Castle Intro
- Background: `bg_castle_intro_sky`, `bg_castle_intro_hills`
- Midground: `prop_castle_intro_castle`
- Interactables: `prop_castle_intro_tower_door`
- Characters: `char_sky_castle_idle`, `fx_sky_collar_glow`
- Foreground: `prop_castle_intro_foreground_grass`
- UI: `ui_story_panel_white`, `ui_hud_plaque`

### Map Room
- Background: `bg_map_room_wall`, `bg_map_room_arch`
- Midground: `prop_map_room_board`, `prop_map_room_waterfall_path`
- Interactables: map marker plaque assets
- Characters: none in this slice
- Foreground: reserved for future framed decor
- UI: `ui_story_panel_white`, `ui_hud_plaque`

### Glitterdrop Waterfall
- Background: `bg_waterfall_sky`, `bg_waterfall_cliffs`
- Midground: `prop_waterfall_setpiece`
- Interactables: puzzle plaque assets
- Characters: `char_bibi_waterfall_idle`, `char_sky_waterfall_idle`
- Foreground: `prop_waterfall_foreground_grass`
- UI: `ui_story_panel_white`, `ui_hud_plaque`, reward badge assets
- Task overlays: `prop_task_water_drop`, `prop_task_sparkle_piece`, `prop_task_crystal_piece`, `prop_task_crystal_socket`

## Clean Replacement Workflow

1. Keep the named scene node and replace only its texture file or texture property.
2. For buttons and hotspots, replace the child `*Art` texture, not the button node.
3. For shared panels, replace the `PanelArt` texture first; the script-driven white `StyleBoxFlat` is the readability fallback.
4. If a final asset needs animation later, keep the art node name and swap the node type only inside the scene; scripts reference the gameplay button or container, not the art child.
