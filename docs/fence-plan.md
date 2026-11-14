1. The key idea: fences live on edges
The tile GridMap is indexed by cell. Fences need their own coordinate system for edges. Every edge in the grid runs in one of two directions:


        x=0      x=1      x=2
   z=0  +--------+--------+        "X-edge": runs along X, sits on line z
        |        |        |        "Z-edge": runs along Z, sits on line x
        | (0,0)  | (1,0)  |
        |        |        |
   z=1  +--------+--------+
So an edge can be stored as Vector3i(x, z, axis):

axis	meaning	separates cells	world centre (cs = cell size)
0	runs along X, on grid line z	(x, z-1) and (x, z)	((x+0.5)*cs, 0, z*cs)
1	runs along Z, on grid line x	(x-1, z) and (x, z)	(x*cs, 0, (z+0.5)*cs)
Each physical edge has exactly one key. That matters. If you stored it as "cell + side" instead, the same fence would have two names (north of A = south of B), and that causes bugs.

Write two small helper functions early and you'll reuse them all the time:

edge_to_world(edge) -> Vector3: where to put the model
edge_to_cells(edge) -> [Vector2i, Vector2i]: which tiles the fence separates (you'll need this for enclosures later)
2. Don't use the GridMap for fences
You might want to put fences in the MeshLibrary too. I'd advise against it:

GridMap puts items at cell centres. You could fake edges with offsets or a second GridMap at half the cell size, but it gets messy fast, and the two orientations need different offsets.
Fences will need their own data (type, health, which enclosure they belong to), and GridMap items can't hold it.
Recommended: a separate Fences node that owns a Dictionary (edge key → fence data/node) and instantiates a fence scene (PackedScene) for each segment. That's simple, easy to debug and fast enough for thousands of segments. If performance ever becomes a problem, you can switch the rendering to a MultiMeshInstance3D later without changing the data model.

3. Picking an edge from the mouse
You already have the hard part: the ray/plane hit point. From there:

Convert to grid units: fx = local.x / cs, fz = local.z / cs.
Measure how close you are to the nearest grid line in each direction: dx = abs(fx - round(fx)), dz = abs(fz - round(fz)).
Whichever is smaller wins:
dx < dz: you're nearest a vertical line, so it's a Z-edge: (round(fx), floor(fz), 1)
otherwise it's an X-edge: (floor(fx), round(fz), 0)
Try it on paper with a few points first. Near a corner the result flips between the two orientations. That's expected and feels fine in practice.

Check local_to_map / map_to_local with your cell_size (3, 0.1, 3) to confirm that cell (0,0) covers 0–3 m and not −1.5–1.5 m. The formulas above assume the first.

4. Separate input from the GridMap
Right now grid_map.gd owns left/right click. Once there are two things to build, both scripts would react to the same click. So bring in a build tool / mode concept:


Main
├── GridMap          (grid_map.gd: tiles only: set_tile(cell, name), no input)
├── Fences           (fences.gd: edge dictionary, place/remove, spawns models)
├── BuildController  (build_controller.gd: current tool, raycast, preview, routes clicks)
└── CameraRig
BuildController holds something like enum Tool { PATH, FENCE }, switched with keys or UI buttons later.
It does the raycast once, then calls grid.set_tile(...) or fences.place(edge) / fences.remove(edge).
Fences and GridMap expose methods and don't read input themselves. This also makes things like "undo", "load save game" and "AI builds a fence" easy later.
This is a good small refactor to do before adding fences. Move the existing gravel/grass logic over first and check that it still works.

5. The fence model (Blender)
Conventions that save you trouble in Godot:

Length = 3 m (one cell edge), running along Blender X, with the origin at the segment centre, on the ground (z = 0 in Blender).
Then an X-edge needs no rotation, and a Z-edge is the same model rotated 90° around Y.
Posts: the easiest start is a segment with half-posts (or a full post) at one end only. Cleaner, and closer to how it should look, is panels without posts plus a separate post model placed on corners (Vector2i grid points) wherever at least one fence touches. You get a free corner join and no z-fighting from doubled posts. I'd start simple and move to separate posts once single segments work.
Export to assets/fences/<name>/<name>.glb per the pipeline. It's used as a PackedScene rather than through tiles.tscn/MeshLibrary.
6. Interaction, in steps
Build it in layers so each step can be tested:

Data + debug draw: place/remove edges by click, shown as a simple BoxMesh (no Blender model yet).
Hover preview: a semi-transparent ghost segment that follows the picked edge, so you can see the picking is right.
Real model in place of the box.
Drag to build a line: remember the start edge on mouse down, lock the axis, and fill all edges up to the current mouse position on release. This is the feel players expect from the genre.
Rules: stay inside map bounds, no duplicates, and later no fence across a path, plus cost.
7. Why this pays off later
Because fences are stored as edges between known cells, an enclosure check becomes a simple flood fill: start at a cell, move to a neighbour only if the edge between them has no fence, and if you never reach the map border, it's closed. Animal movement and guest pathing will use the same "is this edge blocked?" question. (Note: AStarGrid2D only blocks whole cells, not edges. That's worth knowing now, and we can talk it through when you get there.)

Godot docs worth reading: PackedScene.instantiate(), Dictionary with Vector3i keys, GridMap.local_to_map / map_to_local, and later MultiMeshInstance3D.
