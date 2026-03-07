## Arena Survivors - Godot Architecture Improvement Plan

This plan applies Godot 4 GDScript patterns (state machines, components, pooling, autoloads, save system) to the existing project in **incremental phases**. Each phase is designed to be shippable on its own and to avoid gameplay regressions.

---

## Phase 1 - Low‑risk code quality & typing

- **Goal**: Improve safety and performance without changing behavior.
- **Scope (main files)**: `HealthComponent`, `HurtboxComponent`, `HitboxComponent`, `VelocityComponent`, `BaseEnemy`, `player.gd`, managers in `scenes/manager`, autoloads in `scenes/autoload`, resource scripts in `resources/*`.

### Tasks
- **Static typing pass**
  - Add explicit types to signals, member variables, function parameters and return values (e.g. `signal hit(hitbox: HitboxComponent)`, `func on_player_health_changed(health: float) -> void`).
  - Use `Node2D`, `CharacterBody2D`, `PackedScene`, `Timer`, `Dictionary`, `Array[AbilityUpgrade]`, etc. instead of untyped `var`.
- **Signal/API consistency**
  - Standardize signal names and payloads on components (`HealthComponent`, `HurtboxComponent`, `HitboxComponent`) and managers (`ExperienceManager`, `ArenaTimeManager`, `UpgradeManager`) so they are self‑describing and typed.
  - Ensure autoloads like `GameEvents` only expose high‑level, game‑domain events (no UI‑specific details).
- **Minor performance cleanups**
  - Confirm one‑time `get_tree().get_first_node_in_group()` lookups are cached via `@onready` (already mostly done) and remove any repeated lookups in hot paths if they exist.
  - Prefer `process_mode`/`set_physics_process(false)` over ad‑hoc booleans where appropriate, aligning with current `BaseEnemy`/`SpatialManager` usage.

### Success criteria
- No gameplay changes.
- Scripts compile with static typing, and Godot's warnings are reduced.
- Event payloads are clear and consistent across systems.

---

## Phase 2 - Combat components & UI decoupling

- **Goal**: Make damage, hit detection, and feedback follow a reusable component pattern.
- **Scope**: `HealthComponent`, `HurtboxComponent`, `HitboxComponent`, floating damage text UI, any enemy/player hit feedback.

### Tasks
- **Refine `HitboxComponent`**
  - Extend to include typed exported properties such as `@export var damage: int`, optional `@export var knockback_force: float`, and an `owner_node: Node` reference.
  - Optionally add a `hit(hurtbox: HurtboxComponent)` signal mirroring the pattern in the skill so combat logic can listen instead of tightly coupling nodes.
- **Refine `HurtboxComponent`**
  - Adjust `signal hit` to carry information (e.g. `signal hit(hitbox: HitboxComponent)`).
  - Move UI responsibilities (floating text creation, positioning) out of the hurtbox into a dedicated damage feedback system:
    - Option A: A scene‑local "damage text spawner" node that listens to `hit` signals.
    - Option B: Emit a global event on `GameEvents` (e.g. `damage_number_spawned`) and let a UI/autoload node create floating text.
- **Tighten `HealthComponent` responsibilities**
  - Keep it focused on health math, signals, and simple effects, avoiding direct UI responsibilities.
  - Ensure any audio/visual feedback (e.g. potion sounds, particles) can be swapped without changing callers (via signals or exported references).

### Success criteria
- Combat logic (who takes damage and how much) is implemented via components and signals, not direct scene‑tree wiring.
- UI elements like floating damage numbers can be changed or removed without touching core combat code.

---

## Phase 3 - Enemy spawning, pooling, and spatial management

- **Goal**: Scale enemy count smoothly by using proper pooling and the existing spatial grid, reducing GC and CPU spikes.
- **Scope**: `EnemyManager`, `BaseEnemy`, `ObjectPoolManager`, `SpatialManager`, enemy scenes in `scenes/game_object/*_enemy`.

### Tasks
- **Wire `EnemyManager` to `ObjectPoolManager`**
  - Replace direct `enemy_scene.instantiate()` in `EnemyManager` with calls to `ObjectPoolManager.get_object("enemy", scene_path)` (or use per‑enemy keys).
  - Define clear pool keys per enemy family (e.g. `"rat_enemy"`, `"bat_enemy"`) and configure `POOL_SIZES` accordingly.
- **Standardize enemy lifecycle with pooling**
  - Ensure all enemies extend `BaseEnemy` and implement a consistent "on death" path:
    - Use `HealthComponent.died` (or equivalent) to trigger either `queue_free()` (current behavior) or `ObjectPoolManager.release_object(self, key)`.
    - Make sure `BaseEnemy.reset_enemy()` fully resets state when reused from the pool (including `HealthComponent`, visual state, and collision).
- **Integrate with `SpatialManager`**
  - Confirm all enemy scenes register/unregister with `SpatialManager` via `BaseEnemy` (already partly done).
  - Validate `set_active` / `set_semi_active` behavior for enemies so distant enemies are cheap to keep in the scene.

### Success criteria
- Spawning large numbers of enemies does not produce noticeable hitches.
- Enemies reuse pooled instances (visible in debugger: object count stabilizes after ramp‑up).
- Enemy activation/deactivation around the player is handled by `SpatialManager` plus `BaseEnemy` APIs.

---

## Phase 4 - Player state machine & ability controllers

- **Goal**: Make player behavior (idle, move, dash, dead, etc.) explicit and extensible using a state machine pattern; standardize ability controller APIs.
- **Scope**: `player.gd`, ability controller scripts under `scenes/ability/*_ability_controller.gd`, related UI feedback if needed.

### Tasks
- **Introduce a reusable state machine**
  - Add `StateMachine` and `State` scripts (as in the skill) to a `scenes/component` or `scenes/state` folder.
  - Attach a `StateMachine` node under the player, with states such as `PlayerIdle`, `PlayerMove`, `PlayerDash`, `PlayerDead`.
  - Move dash‑related fields (`is_dashing`, timers, direction, cooldown) and animation branching from `player.gd` into dedicated state scripts.
- **Simplify `player.gd`**
  - Reduce `_physics_process` to high‑level input reading and delegating to the state machine (movement, dash decision, death handling).
  - Keep combat and upgrade handling (hooks into `GameEvents` and `UpgradeManager`) but ensure they are state‑aware where necessary.
- **Normalize ability controller interfaces**
  - For each ability controller (`sword`, `axe`, `hammer`, `dagger`, etc.), ensure a consistent API:
    - Properties like `base_damage`, `projectile_scene`, and rate via a `Timer`.
    - Optional `on_spawn()` / `on_despawn()` hooks if pooled.
  - Update `player.gd` and `UpgradeManager` to rely on this shared interface instead of per‑ability special cases where possible.

### Success criteria
- Player behavior changes (new movement types, special states) can be added by adding state scripts, not editing a giant `_physics_process`.
- Abilities share a common interface, making it easy to add or balance new abilities.

---

## Phase 5 - Save system & meta‑progression consolidation

- **Goal**: Replace ad‑hoc save logic with a single, testable save system that cleanly handles meta‑progression and persistent player stats.
- **Scope**: `MetaProgression`, `SaveGame`, any other scripts touching `user://` directly.

### Tasks
- **Design a unified `SaveManager` autoload**
  - Create a `SaveManager` script following the save pattern from the skill (encrypted file, clear API: `save_game(data: Dictionary)`, `load_game()`, `has_save()`, `delete_save()`).
  - Move current responsibilities of `MetaProgression` and `SaveGame` into this manager, while keeping their high‑level domain methods (e.g. `add_meta_upgrade`, `get_upgrade_count`) as thin wrappers or separate domain services.
- **Introduce a save data schema**
  - Define a single `Dictionary` structure for:
    - Meta upgrades and currency.
    - Player‑persistent stats (unlocked characters, last selected character, meta upgrades like `health_regeneration`).
  - Avoid spreading knowledge of the internal save format across multiple scripts; interact via `SaveManager` or small domain APIs only.
- **(Optional) `Saveable` component for world objects**
  - If you need to persist in‑run scene state (e.g. unlocked chests, map progress), add a `Saveable` script similar to the skill pattern and attach to relevant nodes.

### Success criteria
- Only the save system module touches `FileAccess`; game code interacts via clear, high‑level APIs.
- Save/load errors are surfaced via signals (e.g. `save_error`) and can be debugged easily.

---

## Phase 6 - Autoload & scene management cleanup

- **Goal**: Clarify global responsibilities and centralize scene transitions.
- **Scope**: Autoloads in `project.godot` (`GameEvents`, `MusicPlayer`, `ScreenTransition`, `MetaProgression`, `GameOptions`, `Globals`, `SaveGame`, `SpatialManager`) and scene change logic in UI and game flows.

### Tasks
- **Audit and streamline autoloads**
  - Confirm which autoloads are still used (`Globals` appears unused; consider removing or merging into more focused systems).
  - Ensure each autoload has a single clear responsibility:
    - `GameEvents`: global event bus only.
    - `MusicPlayer`: music lifecycle only.
    - `SpatialManager`: spatial partitioning / activation only.
    - `SaveManager` (from Phase 5): saving and loading only.
- **Introduce a `SceneManager`**
  - Create a `SceneManager` autoload based on the pattern in the skill, responsible for:
    - Loading/unloading scenes (optionally async) and owning the current scene node.
    - Emitting `scene_loading_started`, `scene_loaded`, and transition‑related signals.
    - Coordinating with the existing `ScreenTransition` CanvasLayer to play in/out transitions.
  - Update main menu, meta menu, and game flow scripts to request scene changes via `SceneManager` instead of loading scenes directly.

### Success criteria
- Global state is limited to a small, well‑defined set of autoloads.
- Scene changes (menu → game → end screen → menu) are routed through a single `SceneManager`, making transitions easier to adjust and debug.

---

## Suggested implementation order

1. **Phase 1** - Typing and signal cleanup (foundation for safer refactors).
2. **Phase 2** - Combat components and UI decoupling.
3. **Phase 3** - Enemy pooling and spatial integration (biggest performance win).
4. **Phase 4** - Player state machine and ability controller normalization.
5. **Phase 5** - Unified save system for meta‑progression and persistent stats.
6. **Phase 6** - Autoload and scene management cleanup.

Each phase can be developed and tested independently, with gameplay regression tests focused on the affected systems.

