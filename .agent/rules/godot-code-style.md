---
trigger: always_on
---

# Godot 4.x Development Rules & Best Practices

This document establishes the ground rules for AI assistants generating code for the Godot Engine.

**Target Version:** Godot 4.x (GDScript 2.0)

**Strict Mode:** Enabled

---

## 1. Core Principles & Architecture

### 1.1 Node vs. Resource

- **Prefer Resources for Logic:** Do not use `Nodes` for pure data or non-visual logic states. Use `Resource` (or `RefCounted`) for State Machines, Behavior Tree nodes, and Item data. Resources are lighter and avoid SceneTree overhead.
    
- **Composition over Inheritance:** Avoid deep class hierarchies. Use child nodes (Components) to add functionality to a parent entity.
    
- **Manager Pattern:** Use Autoloads (Singletons) only for global state (GameState, MusicManager). Avoid tightly coupling local scenes to global singletons.
    

### 1.2 Static Typing

- **Mandatory Typing:** All variables and functions must be statically typed to improve performance and code safety.
    
    - **Right:** `var health: int = 10` or `var health := 10`
        
    - **Wrong:** `var health = 10`
        
- **Void Returns:** Explicitly state `-> void` for functions that do not return values.
    

---

## 2. GDScript Style Guide

### 2.1 Naming Conventions

- **Classes/Types:** PascalCase (`class_name EnemyController`)
    
- **Nodes:** PascalCase (`$Sprite2D`, `$CollisionShape`)
    
- **Folders/Files:** snake_case (`res://enemies/goblin_warrior.tscn`)
    
- **Variables/Functions:** snake_case (`var move_speed`, `func take_damage()`)
    
- **Signals:** snake_case, past tense (`signal door_opened`, `signal health_changed`)
    
- **Constants:** CONSTANT_CASE (`const GRAVITY = 9.8`)
    
- **Private Members:** Prefix with underscore (`var _internal_state`, `func _calculate_logic()`)
    

### 2.2 Code Order

Follow this strict ordering for script organization:

1. `@tool` / `class_name` / `extends`
    
2. Docstrings (`##`)
    
3. `signal` declarations
    
4. `enum` declarations
    
5. `const` declarations
    
6. `@export` variables
    
7. `public` variables
    
8. `private` variables (`_`)
    
9. `@onready` variables
    
10. `_init()` / `_ready()`
    
11. `_process()` / `_physics_process()`
    
12. Public methods
    
13. Private methods (`_`)
    

---

## 3. Anti-Hallucination Protocol (Godot 3 -> 4 Migration)

AI models frequently confuse Godot 3 syntax with Godot 4. **Reject the following patterns:**

|**Feature**|**REJECT (Godot 3 / Legacy)**|**USE (Godot 4 Standard)**|
|---|---|---|
|**Signals**|`button.connect("pressed", self, "_on_press")`|`button.pressed.connect(_on_press)`|
|**Tweening**|`var t = Tween.new(); add_child(t)`|`var tween = create_tween()` (Do not add as child)|
|**File I/O**|`var f = File.new(); f.open(...)`|`FileAccess.open("path", FileAccess.READ)`|
|**Kinematic**|`move_and_slide(velocity, up_vector)`|`move_and_slide()` (Velocity is a member var)|
|**Rotation**|`rotation_degrees` (often bugged in AI)|`rotation` (radians) is preferred for internal math|
|**Time**|`OS.get_ticks_msec()`|`Time.get_ticks_msec()`|
|**Instancing**|`PackedScene.instance()`|`PackedScene.instantiate()`|
|**Multiplayer**|`rpc("func_name")`|`rpc_id(id, "func_name")` or just `func_name.rpc()`|

---

## 4. Navigation & Spatial Logic

- **Server-Based Approach:** For high-performance queries (raycasting, pathfinding), prefer `NavigationServer3D` and `PhysicsServer3D` over node-based helpers if scaling beyond 100 agents.
    
- **Separation of Concerns:**
    
    - Use **Navigation** for global pathfinding (A*).
        
    - Use **Avoidance** (RVO) for local collision prevention.
        
    - _Note:_ Avoidance does not respect static walls; it only respects other agents/radius.
        
- **Dynamic Objects:** Do not rebake the entire `NavigationRegion3D` every frame. Use `NavigationObstacle3D` for dynamic moving blockers, or use chunked navigation meshes.
    

---

## 5. Threading & Performance

- **Heavy Processing:** Use `WorkerThreadPool` for expensive tasks (e.g., parsing large JSON payloads from GenAI APIs, pathfinding calculations).
    
- **Thread Safety:**
    
    - **NEVER** access the SceneTree or nodes directly from a thread.
        
    - Use `call_deferred("method_name", args)` to pass data back to the main thread for UI updates.
        
    - Resources are generally thread-safe if read-only; use `Mutex` if writing shared data.
        
- **Physics:**
    
    - Logic goes in `_physics_process` (fixed timestep).
        
    - Visual updates go in `_process` (variable timestep).
        
    - Use **Physics Interpolation** (Godot 4.3+) to smooth movement jitter.
        

---

## 6. Generative AI Implementation Safety

- **No Client-Side Keys:** Never embed LLM API keys (OpenAI, Anthropic) in GDScript or Export Presets. Use a backend proxy.
    
- **Parsing Safety:** When receiving JSON from an LLM:
    
    - Validate the JSON schema before usage.
        
    - Parse on a background thread if the response > 50kb.
        
    - Sanitize text before displaying (BBCode injection prevention).