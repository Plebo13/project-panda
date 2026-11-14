# AGENTS.md

Guidance for AI agents (and humans) working in this repository.

## About the project

This repository holds the code and assets of a **zoo simulation game**. It is a
tribute to the first *Zoo Tycoon* game.

It is an **independent project**. It must not use anything from the original
game: no code, art, models, textures, sounds, music, names or other assets.
Code, models and animations are made for this project. Free third-party assets
such as materials and textures may be used under the rules in
[Third-party assets](#third-party-assets).

### Tech stack

- **Engine**: Godot 4.7, Forward+ renderer, Jolt Physics
- **Language**: GDScript
- **Art**: Blender, exported to glTF (`.glb`)
- **Editor**: VS Code with the godot-tools extension

### Repository layout

- `game/` – the Godot project
  - `assets/<category>/<name>/` – exported `.glb` models and their textures
  - `scripts/` – GDScript files
  - `mesh-libs/` – MeshLibrary resources used by the GridMap
  - `tiles.tscn` – scene the tile MeshLibrary is built from
  - `main.tscn` – main scene
- `art-source/<category>/` – Blender source files (`.blend`)
  - `assets/` – downloaded third-party materials and models
- `CREDITS.md` – sources and licenses of third-party assets

### Asset pipeline

1. Model in Blender, saved as `art-source/<category>/<name>.blend`.
2. Export to `game/assets/<category>/<name>/<name>.glb`.
3. Add the model to `game/tiles.tscn`.
4. Export the scene as a MeshLibrary to `game/mesh-libs/tiles.tres`.

### Working with Godot files

- Change `.tscn`, `.tres` and `project.godot` through the Godot editor, not by
  hand, unless it is a small, well-understood fix.
- Commit `.import` and `.uid` files. They keep import settings and resource IDs
  stable.
- Never commit the `.godot/` folder. It is a cache that Godot rebuilds.

### Git

- Binary files (`.blend`, `.glb`, images, audio, fonts) are stored with
  **Git LFS**. See `.gitattributes`. Run `git lfs install` once after cloning.
- Blender backup files (`.blend1`, …) are ignored and must not be committed.

## The role of AI in this project

This project is **not meant to be written entirely by AI**. The author uses it
to learn 3D modelling, animation and game development. Doing the work is the
point.

AI agents should:

- **Guide**: explain concepts and point to approaches and resources so the
  author can do the work themselves.
- **Advise**: suggest options, trade-offs and best practices when asked.
- **Review**: look at code, scenes and assets and give constructive feedback.
- **Document**: help write and maintain documentation.

AI agents should not:

- Implement features, write large amounts of game code or create assets unless
  explicitly asked to.
- Take over tasks the author wants to learn from. When unsure, explain how to do
  it rather than doing it.

## Third-party assets

Free third-party assets, such as materials, textures and HDRIs, may be used if:

- their license allows **redistribution in a public repository**. CC0 is
  preferred. CC BY is fine with credit. "Royalty free" licenses that allow use
  in a game but forbid sharing the raw files are **not** allowed.
- they are listed in [CREDITS.md](CREDITS.md) with source, author and license.
- they do not come from the original game or imitate it.

Store downloaded source files under `art-source/<category>/assets/`.

## Contributing

This is an **open source project**, and others are welcome to contribute. Keep
contributions original: do not add material taken from the original game.
Third-party assets must follow the rules in
[Third-party assets](#third-party-assets).
